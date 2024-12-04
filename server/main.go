package main

import (
	"github.com/labstack/echo/v4"
	"github.com/labstack/echo/v4/middleware"
	"github.com/stratocraft/stratocraft.dev/internal/application"
)

func main() {
	// Instantiate a new echo app
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

	// Instantiate a new instance of Application
	//app := application.NewApplication(repoOwner, repoName, token, secret)
	app := application.NewApplication()

	// Define routes
	e.GET("/", app.Home)
	e.GET("/posts", app.Posts)
	e.GET("/posts/:slug", app.Post)
	//e.GET("/about", app.About)
	//e.GET("/contact", app.Contact)
	e.GET("/sitemap.xml", app.SiteMap)
	e.GET("/health", app.Health)

	// Start the app
	e.Logger.Fatal(e.Start(":8080"))
}
