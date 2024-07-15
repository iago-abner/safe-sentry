package main

import (
	"api/handlers"
	"api/models"
	"encoding/json"
	"log"
	"os"
	"os/signal"
	"syscall"

	"github.com/gocql/gocql"
	"github.com/gofiber/fiber/v2"
	"github.com/joho/godotenv"
	"github.com/streadway/amqp"
)

var channel *amqp.Channel
var messagesBuffer []models.TLocation
var messageObjects []*amqp.Delivery

const batchSize = 5

func main() {
	err := godotenv.Load()
	if err != nil {
		log.Fatalf("Error loading .env file: %v", err)
	}

	host := os.Getenv("CASSANDRA_URL")
	keyspace := os.Getenv("CASSANDRA_KEYSPACE")
	username := os.Getenv("CASSANDRA_USER")
	password := os.Getenv("CASSANDRA_PASSWORD")

	session, err := handlers.ConnectDB(host, keyspace, username, password)
	if err != nil {
		log.Fatalf("Failed to connect to Cassandra: %v", err)
	}
	defer session.Close()

	rabbitmqURL := os.Getenv("RABBITMQ_URL")
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

	sigs := make(chan os.Signal, 1)
	signal.Notify(sigs, syscall.SIGINT, syscall.SIGTERM)

	go func() {
		<-sigs
		log.Println("Shutting down server...")
		if err := app.Shutdown(); err != nil {
			log.Fatalf("Server Shutdown Failed:%+v", err)
		}
	}()

	go locationWorker(queueName, session)

	log.Println("Server is running on port 4242")
	if err := app.Listen(":4242"); err != nil {
		log.Fatalf("ListenAndServe(): %v", err)
	}
}

func locationHandler(c *fiber.Ctx) error {
	if c.Method() != fiber.MethodPost {
		return c.Status(fiber.StatusMethodNotAllowed).JSON(fiber.Map{"error": "Invalid request method"})
	}

	var message models.TLocation
	if err := c.BodyParser(&message); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "Invalid request body"})
	}

	body, err := json.Marshal(message)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": "Failed to marshal message"})
	}

	err = channel.Publish(
		"",
		"location_queue",
		false,
		false,
		amqp.Publishing{
			ContentType:  "application/json",
			Body:         body,
			DeliveryMode: amqp.Persistent,
		},
	)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": "Failed to publish message"})
	}

	log.Printf("Message published to queue")
	return c.Status(fiber.StatusCreated).JSON(fiber.Map{"message": "Message published"})
}

func locationWorker(queueName string, session *gocql.Session) {
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

	log.Println("Worker started, waiting for messages...")

	for msg := range msgs {
		log.Printf("Received a message")

		var message models.TLocation
		err := json.Unmarshal(msg.Body, &message)
		if err != nil {
			log.Printf("Error unmarshalling message: %v", err)
			msg.Nack(false, true)
			continue
		}

		// log.Printf("Message unmarshalled successfully: %+v", message.RastreadorId)

		messagesBuffer = append(messagesBuffer, message)
		messageObjects = append(messageObjects, &msg)

		// log.Printf("Current buffer length: %d", len(messagesBuffer))
		if len(messagesBuffer) >= batchSize {
			processMessages(session)
		}
	}

	log.Println("Worker stopped.")
}

func processMessages(session *gocql.Session) {
	if len(messagesBuffer) == 0 {
		return
	}
	log.Printf("Processing %d messages", len(messagesBuffer))

	batch := session.NewBatch(gocql.UnloggedBatch)
	for i, message := range messagesBuffer {
		log.Printf("Inserting message %d: %+v", i, message)

		batch.Query(`
			INSERT INTO Localizacao (rastreador_id, data, horario_rastreador, latitude, longitude, velocidade, bateria, bateria_veiculo, ignicao, altitude, direcao, odometro, criado_em)
			VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
			message.RastreadorId,
			message.Data,
			message.HorarioRastreador,
			message.Latitude,
			message.Longitude,
			message.Velocidade,
			message.Bateria,
			message.BateriaVeiculo,
			message.Ignicao,
			message.Altitude,
			message.Direcao,
			message.Odometro,
			message.CriadoEm)
	}

	if err := session.ExecuteBatch(batch); err != nil {
		log.Printf("Error executing batch: %v", err)
		nackMessages()
		return
	}

	ackMessages()
}

func ackMessages() {
	for _, msg := range messageObjects {
		msg.Ack(false)
	}
	log.Println("Messages acknowledged")
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
