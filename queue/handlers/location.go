package handlers

import (
	"encoding/json"
	"goqueue/models"

	"github.com/gofiber/fiber/v2"
	"github.com/streadway/amqp"
)

func LocationHandler(c *fiber.Ctx, channel *amqp.Channel) error {
	var message models.TLocation
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
