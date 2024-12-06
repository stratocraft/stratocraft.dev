package application

import (
	"github.com/stratocraft/stratocraft.dev/internal/contentmanager"
	"log"
	"os"
)

type Application struct {
	ContentManager *contentmanager.ContentManager
}

func NewApplication() *Application {
	repoOwner := os.Getenv("GH_OWNER")
	if repoOwner == "" {
		log.Fatal("GH_REPO_OWNER environment variable not set!")
	}

	repoName := os.Getenv("GH_REPO")
	if repoName == "" {
		log.Fatal("GH_REPO_NAME environment variable not set!")
	}

	token := os.Getenv("GH_TOKEN")
	if token == "" {
		log.Fatal("GH_TOKEN environment variable not set!")
	}

	secret := os.Getenv("WEBHOOK_SECRET")
	if secret == "" {
		log.Fatal("GH_WEBHOOK_SECRET environment variable not set!")
	}

	cm := contentmanager.NewContentManger(repoOwner, repoName, token, secret)
	if err := cm.RefreshContent(); err != nil {
		log.Printf("Failed to load initial content: %v", err)
	}

	return &Application{
		ContentManager: cm,
	}
}
