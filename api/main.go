package main

import (
	"context"
	"database/sql"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"

	"github.com/joho/godotenv"
	_ "github.com/lib/pq" // Importação anônima do driver do PostgreSQL
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

const batchSize = 3

func main() {
	// Carregar variáveis de ambiente do arquivo .env
	err := godotenv.Load()
	if err != nil {
		log.Fatalf("Error loading .env file: %v", err)
	}

	databaseURL := os.Getenv("DATABASE_URL") + "?sslmode=disable"
	rabbitmqURL := os.Getenv("RABBITMQ_URL")

	// Setup database connection
	db, err = sql.Open("postgres", databaseURL)
	if err != nil {
		log.Fatalf("Failed to connect to database: %v", err)
	}
	defer db.Close()

	// Setup RabbitMQ connection
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

	// Setup HTTP server
	http.HandleFunc("/location", locationHandler)
	server := &http.Server{Addr: ":4242"}

	// Handle shutdown signals
	sigs := make(chan os.Signal, 1)
	signal.Notify(sigs, syscall.SIGINT, syscall.SIGTERM)

	go func() {
		<-sigs
		log.Println("Shutting down server...")
		server.Shutdown(context.Background())
	}()

	go locationWorker(queueName)

	log.Println("Server is running on port 4242")
	if err := server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
		log.Fatalf("ListenAndServe(): %v", err)
	}
}

func locationHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Invalid request method", http.StatusMethodNotAllowed)
		return
	}

	var message TLocation
	err := json.NewDecoder(r.Body).Decode(&message)
	if err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	body, err := json.Marshal(message)
	if err != nil {
		http.Error(w, "Failed to marshal message", http.StatusInternalServerError)
		return
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
		http.Error(w, "Failed to publish message", http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusCreated)
	fmt.Fprintln(w, `{"message": "Message published"}`)
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

	log.Printf("Consuming messages from queue %s", queueName)

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

	tx, err := db.Begin()
	if err != nil {
		log.Printf("Error starting transaction: %v", err)
		nackMessages()
		return
	}

	stmt, err := tx.Prepare(`
		INSERT INTO localizacao (
			latitude, longitude, velocidade, horario_rastreador,
			bateria, bateria_veiculo, ignicao, altitude, direcao, odometro
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
	`)
	if err != nil {
		log.Printf("Error preparing statement: %v", err)
		tx.Rollback()
		nackMessages()
		return
	}
	defer stmt.Close()

	for _, message := range messagesBuffer {
		_, err := stmt.Exec(
			message.Latitude, message.Longitude, message.Velocidade, message.HorarioRastreador,
			message.Bateria, message.BateriaVeiculo, message.Ignicao, message.Altitude,
			message.Direcao, message.Odometro,
		)
		if err != nil {
			log.Printf("Error executing statement: %v", err)
			tx.Rollback()
			nackMessages()
			return
		}
	}

	err = tx.Commit()
	if err != nil {
		log.Printf("Error committing transaction: %v", err)
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
