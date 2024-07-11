package main

import (
	"api/handlers"
	"api/routes"
	"log"
	"os"
	"os/signal"
	"syscall"

	"github.com/gofiber/fiber/v2"
	"github.com/joho/godotenv"
)

func main() {
	// Carregar variáveis de ambiente do arquivo .env
	err := godotenv.Load()
	if err != nil {
		log.Fatalf("Error loading .env file: %v", err)
	}

	// Setup database connection
	databaseURL := os.Getenv("DATABASE_URL") + "?sslmode=disable"
	db, err := handlers.ConnectDB(databaseURL)
	if err != nil {
		log.Fatalf("Failed to connect to database: %v", err)
	}
	defer db.Close()

	// Setup RabbitMQ connection
	rabbitmqURL := os.Getenv("RABBITMQ_URL")
	channel, err := handlers.ConnectQueue(rabbitmqURL)
	if err != nil {
		log.Fatalf("Failed to connect to RabbitMQ: %v", err)
	}
	defer channel.Close()

	// Setup Fiber app
	app := fiber.New()

	routes.LocationRoutes(app, channel)

	// Handle shutdown signals
	sigs := make(chan os.Signal, 1)
	signal.Notify(sigs, syscall.SIGINT, syscall.SIGTERM)

	go func() {
		<-sigs
		log.Println("Shutting down server...")
		app.Shutdown()
	}()

	queueName := "location_queue"
	go handlers.LocationWorker(channel, queueName, db)

	log.Println("Server is running on port 4242")
	if err := app.Listen(":4242"); err != nil {
		log.Fatalf("ListenAndServe(): %v", err)
	}
}
