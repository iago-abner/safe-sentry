package main

import (
	"gocql/handlers"
	"log"
	"os"

	"github.com/joho/godotenv"
	"github.com/streadway/amqp"
)

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

	channel, err := conn.Channel()
	if err != nil {
		log.Fatalf("Failed to open a channel: %v", err)
	}
	defer channel.Close()

	_, err = channel.QueueDeclare(
		"location_queue",
		true,
		false,
		false,
		false,
		nil,
	)
	if err != nil {
		log.Fatalf("Failed to declare a queue: %v", err)
	}

	go handlers.LocationWorker(channel, session)
}

