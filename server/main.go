package main

import (
	"github.com/labstack/echo/v4"
	"github.com/labstack/echo/v4/middleware"
	"github.com/stratocraft/stratocraft.dev/internal/application"
	"log"
	"os"
)

func main() {
	// Read environment variables on startup
	repoOwner := os.Getenv("GH_REPO_OWNER")
	if repoOwner == "" {
		log.Fatal("GH_REPO_OWNER environment variable not set!")
	}

	repoName := os.Getenv("GH_REPO_NAME")
	if repoName == "" {
		log.Fatal("GH_REPO_NAME environment variable not set!")
	}

	token := os.Getenv("GH_TOKEN")
	if token == "" {
		log.Fatal("GH_TOKEN environment variable not set!")
	}

	secret := os.Getenv("GH_WEBHOOK_SECRET")
	if secret == "" {
		log.Fatal("GH_WEBHOOK_SECRET environment variable not set!")
	}

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
	app := application.NewApplication(repoOwner, repoName, token, secret)

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
