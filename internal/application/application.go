package application

import "github.com/stratocraft/stratocraft.dev/internal/contentmanager"

type Application struct {
	ContentManager *contentmanager.ContentManager
}

func NewApplication(repoOwner, repoName, token, secret string) *Application {
	return &Application{
		ContentManager: contentmanager.NewContentManger(repoOwner, repoName, token, secret),
	}
}
