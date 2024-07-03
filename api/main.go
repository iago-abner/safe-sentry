package main

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"log"
	"os"
	"os/signal"
	"syscall"

	"github.com/gofiber/fiber/v2"
	"github.com/joho/godotenv"
	"github.com/lib/pq"
	"github.com/streadway/amqp"
)

type TLocation struct {
    Latitude         float64 `json:"latitude"`
    Longitude        float64 `json:"longitude"`
    Velocidade       float64 `json:"velocidade"`
    HorarioRastreador string `json:"horario_rastreador"`
    Bateria          float64 `json:"bateria"`
    BateriaVeiculo   float64 `json:"bateria_veiculo"`
    Ignicao          bool    `json:"ignicao"`
    Altitude         float64 `json:"altitude"`
    Direcao          float64 `json:"direcao"`
    Odometro         float64 `json:"odometro"`
}

var db *sql.DB
var channel *amqp.Channel
var messagesBuffer []TLocation
var messageObjects []*amqp.Delivery

func failOnError(err error, msg string) {
    if err != nil {
        log.Fatalf("%s: %s", msg, err)
    }
}

func setupPostgres() {
    var err error
    db, err = sql.Open("postgres", os.Getenv("DATABASE_URL"))
    failOnError(err, "Failed to connect to PostgreSQL")
}

func setupRabbitMQ() {
    conn, err := amqp.Dial(os.Getenv("RABBITMQ_URL"))
    failOnError(err, "Failed to connect to RabbitMQ")

    channel, err = conn.Channel()
    failOnError(err, "Failed to open a channel")

    _, err = channel.QueueDeclare(
        "location_queue",
        true,
        false,
        false,
        false,
        nil,
    )
    failOnError(err, "Failed to declare a queue")
}

func processBatch(messages []TLocation) {
    if len(messages) == 0 {
        return
    }

    tx, err := db.Begin()
    if err != nil {
        log.Fatalf("Failed to begin transaction: %s", err)
    }

    stmt, err := tx.Prepare(pq.CopyIn("localizacao", "latitude", "longitude", "velocidade", "horario_rastreador", "bateria", "bateria_veiculo", "ignicao", "altitude", "direcao", "odometro"))
    if err != nil {
        log.Fatalf("Failed to prepare statement: %s", err)
    }

    for _, msg := range messages {
        _, err = stmt.Exec(msg.Latitude, msg.Longitude, msg.Velocidade, msg.HorarioRastreador, msg.Bateria, msg.BateriaVeiculo, msg.Ignicao, msg.Altitude, msg.Direcao, msg.Odometro)
        if err != nil {
            log.Fatalf("Failed to execute statement: %s", err)
        }
    }

    _, err = stmt.Exec()
    if err != nil {
        log.Fatalf("Failed to execute statement: %s", err)
    }

    err = stmt.Close()
    if err != nil {
        log.Fatalf("Failed to close statement: %s", err)
    }

    err = tx.Commit()
    if err != nil {
        log.Fatalf("Failed to commit transaction: %s", err)
    }
}

func consumeMessages() {
    queueName := "location_queue"
    batchSize := 100
    messagesBuffer = []TLocation{}
    messageObjects = []*amqp.Delivery{}

    msgs, err := channel.Consume(
        queueName,
        "",
        false,
        false,
        false,
        false,
        nil,
    )
    failOnError(err, "Failed to register a consumer")

    go func() {
        for msg := range msgs {
            var message TLocation
            err := json.Unmarshal(msg.Body, &message)
            if err != nil {
                log.Printf("Failed to unmarshal message: %s", err)
                continue
            }

            messagesBuffer = append(messagesBuffer, message)
            messageObjects = append(messageObjects, &msg)

            if len(messagesBuffer) >= batchSize {
                processBatch(messagesBuffer)
                for _, msgObj := range messageObjects {
                    msgObj.Ack(false)
                }
                messagesBuffer = []TLocation{}
                messageObjects = []*amqp.Delivery{}
            }
        }
    }()
}

func setup() {
    setupPostgres()
    setupRabbitMQ()
    consumeMessages()

    c := make(chan os.Signal, 1)
    signal.Notify(c, syscall.SIGINT, syscall.SIGTERM)
    go func() {
        <-c
        if len(messagesBuffer) > 0 {
            processBatch(messagesBuffer)
        }
        os.Exit(0)
    }()
}

func main() {
    err := godotenv.Load()
    failOnError(err, "Error loading .env file")

    app := fiber.New()

    app.Post("/location", func(c *fiber.Ctx) error {
        var message TLocation
        if err := c.BodyParser(&message); err != nil {
            return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
        }

        body, err := json.Marshal(message)
        if err != nil {
            return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
        }

        err = channel.Publish(
            "",
            "location_queue",
            false,
            false,
            amqp.Publishing{
                ContentType: "application/json",
                Body:        body,
            },
        )
        if err != nil {
            return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
        }

        return c.Status(fiber.StatusCreated).JSON(fiber.Map{"message": "Location data sent to queue"})
    })

    setup()

    port := 4242
    log.Printf("Server is running on port %d", port)
    log.Fatal(app.Listen(fmt.Sprintf(":%d", port)))
}
