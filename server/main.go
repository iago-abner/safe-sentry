package main

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"log"
	"os"
	"os/signal"
	"strings"
	"syscall"

	"github.com/gofiber/fiber/v2"
	"github.com/joho/godotenv"
	_ "github.com/lib/pq"
	"github.com/streadway/amqp"
)

type TLocation struct {
	Latitude         json.Number `json:"latitude"`
	Longitude        json.Number `json:"longitude"`
	Velocidade       json.Number `json:"velocidade"`
	HorarioRastreador string      `json:"horario_rastreador"`
	Bateria          json.Number `json:"bateria"`
	BateriaVeiculo   json.Number `json:"bateria_veiculo"`
	Ignicao          bool        `json:"ignicao"`
	Altitude         json.Number `json:"altitude"`
	Direcao          int         `json:"direcao"`
	Odometro         json.Number `json:"odometro"`
}

var db *sql.DB
var channel *amqp.Channel
var messagesBuffer []TLocation
var messageObjects []*amqp.Delivery

const batchSize = 100

func main() {
	err := godotenv.Load()
	if err != nil {
		log.Fatalf("Error loading .env file: %v", err)
	}

	databaseURL := os.Getenv("DATABASE_URL") + "?sslmode=disable"
	rabbitmqURL := os.Getenv("RABBITMQ_URL")

	db, err = sql.Open("postgres", databaseURL)
	if err != nil {
		log.Fatalf("Failed to connect to database: %v", err)
	}
	defer db.Close()

	conn, err := amqp.Dial(rabbitmqURL)
	if err != nil {
		log.Fatalf("Failed to connect to RabbitMQ: %v", err)
	}
	defer conn.Close()

	channel, err = conn.Channel()
	if err != nil {
		log.Fatalf("Failed to open a channel: %v", err)
	}
	defer channel.Close()

	queueName := "location_queue"
	_, err = channel.QueueDeclare(
		queueName,
		true,
		false,
		false,
		false,
		nil,
	)
	if err != nil {
		log.Fatalf("Failed to declare a queue: %v", err)
	}

	app := fiber.New()

	app.Post("/location", locationHandler)

	go locationWorker(queueName)

	sigs := make(chan os.Signal, 1)
	signal.Notify(sigs, syscall.SIGINT, syscall.SIGTERM)

	go func() {
		<-sigs
		log.Println("Shutting down server...")
		if err := app.Shutdown(); err != nil {
			log.Fatalf("Server Shutdown Failed:%+v", err)
		}
	}()

	log.Println("Server is running on port 4242")
	if err := app.Listen(":4242"); err != nil {
		log.Fatalf("ListenAndServe(): %v", err)
	}
}

func locationHandler(c *fiber.Ctx) error {
	var message TLocation
	if err := c.BodyParser(&message); err != nil {
		return c.Status(fiber.StatusBadRequest).SendString("Invalid request body")
	}

	body, err := json.Marshal(message)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).SendString("Failed to marshal message")
	}

	err = channel.Publish(
		"",
		"location_queue",
		false,
		false,
		amqp.Publishing{
			ContentType:  "application/json",
			Body:         body,
			DeliveryMode: amqp.Transient,
		},
	)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).SendString("Failed to publish message")
	}

	return c.Status(fiber.StatusCreated).JSON(fiber.Map{
		"message": "Message published",
	})
}

func locationWorker(queueName string) {
	msgs, err := channel.Consume(
		queueName,
		"",
		false,
		false,
		false,
		false,
		nil,
	)
	if err != nil {
		log.Fatalf("Failed to register a consumer: %v", err)
	}

	for msg := range msgs {
		var message TLocation
		err := json.Unmarshal(msg.Body, &message)
		if err != nil {
			log.Printf("Error unmarshalling message: %v", err)
			msg.Nack(false, true)
			continue
		}

		messagesBuffer = append(messagesBuffer, message)
		messageObjects = append(messageObjects, &msg)

		if len(messagesBuffer) >= batchSize {
			processMessages()
		}
	}
}

func processMessages() {
	if len(messagesBuffer) == 0 {
		return
	}

	valueStrings := make([]string, 0, len(messagesBuffer))
	valueArgs := make([]interface{}, 0, len(messagesBuffer)*10)

	for i, message := range messagesBuffer {
		valueStrings = append(valueStrings, fmt.Sprintf("($%d, $%d, $%d, $%d, $%d, $%d, $%d, $%d, $%d, $%d)",
			i*10+1, i*10+2, i*10+3, i*10+4, i*10+5, i*10+6, i*10+7, i*10+8, i*10+9, i*10+10))
		valueArgs = append(valueArgs, message.Latitude, message.Longitude, message.Velocidade, message.HorarioRastreador,
			message.Bateria, message.BateriaVeiculo, message.Ignicao, message.Altitude, message.Direcao, message.Odometro)
	}

	stmt := fmt.Sprintf("INSERT INTO localizacao (latitude, longitude, velocidade, horario_rastreador, bateria, bateria_veiculo, ignicao, altitude, direcao, odometro) VALUES %s",
		strings.Join(valueStrings, ","))
	_, err := db.Exec(stmt, valueArgs...)

	if err != nil {
		log.Printf("Error executing batch insert: %v", err)
		nackMessages()
		return
	}

	ackMessages()
}

func ackMessages() {
	for _, msg := range messageObjects {
		msg.Ack(false)
	}
	messagesBuffer = nil
	messageObjects = nil
}

func nackMessages() {
	for _, msg := range messageObjects {
		msg.Nack(false, true)
	}
	messagesBuffer = nil
	messageObjects = nil
}
