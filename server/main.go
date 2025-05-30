package main

import (
	"github.com/labstack/echo/v4"
	"github.com/labstack/echo/v4/middleware"
	"github.com/stratocraft/stratocraft.dev/internal/application"
)

func main() {
	e := echo.New()

	// Configure middleware
	e.Use(middleware.Recover())
	e.Use(middleware.GzipWithConfig(middleware.GzipConfig{
		Level: 5,
	}))

	// Static assets bundling
	e.Static("/public", "public")
	e.File("/favicon.ico", "public/img/favicon.ico")
	e.File("/robots.txt", "public/txt/robots.txt")

	app := application.New()

	// Routes
	e.GET("/", app.Home)
	//e.GET("/about", app.About)
	//e.GET("/contact", app.Contact)
	//e.GET("/services", app.Services)

	// Start the application
	e.Logger.Fatal(e.Start(":8080"))
}
