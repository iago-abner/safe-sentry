package routes

import (
	"api/handlers"

	"github.com/gofiber/fiber/v2"
)

func SetupRoutes(app *fiber.App) {
    app.Get("/api/v1/hello", handlers.Hello)
		app.Get("/", handlers.Home)
}
