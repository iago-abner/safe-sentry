package routes

import (
	"api/handlers"

	"github.com/gofiber/fiber/v2"
	"github.com/streadway/amqp"
)

func LocationRoutes(app *fiber.App, channel *amqp.Channel) {
		app.Post("/location", handlers.LocationHandler(channel))
}
