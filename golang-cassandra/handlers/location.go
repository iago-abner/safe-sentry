package handlers

import (
	"api/models"
	"encoding/json"

	"github.com/gofiber/fiber/v2"
	"github.com/streadway/amqp"
)

func LocationHandlerxx(channel *amqp.Channel) fiber.Handler {
	return func(c *fiber.Ctx) error {

		var message models.TLocation
		err := json.Unmarshal(c.Body(), &message)
		if err != nil {
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

		return c.Status(fiber.StatusCreated).JSON(fiber.Map{"message": "Message published"})
	}
}
