package main

import (
	"api/handlers"
	"api/models"
	"encoding/json"
	"log"
	"os"

	"github.com/gocql/gocql"
	"github.com/joho/godotenv"
	"github.com/streadway/amqp"
)

var channel *amqp.Channel
var messagesBuffer []models.TLocation
var messageObjects []*amqp.Delivery

const batchSize = 100

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

	go locationWorker(queueName, session)

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

	for msg := range msgs {
		var message models.TLocation
		err := json.Unmarshal(msg.Body, &message)
		if err != nil {
			log.Printf("Error unmarshalling message: %v", err)
			msg.Nack(false, true)
			continue
		}

		messagesBuffer = append(messagesBuffer, message)
		messageObjects = append(messageObjects, &msg)

		if len(messagesBuffer) >= batchSize {
			processMessages(session)
		}
	}
}

func processMessages(session *gocql.Session) {
	if len(messagesBuffer) == 0 {
		return
	}

	batch := session.NewBatch(gocql.UnloggedBatch)
	for _, message := range messagesBuffer {
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
