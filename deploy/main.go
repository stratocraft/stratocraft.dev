package main

import (
	"github.com/pulumi/pulumi-digitalocean/sdk/v4/go/digitalocean"
	"github.com/pulumi/pulumi/sdk/v3/go/pulumi"
)

func main() {
	pulumi.Run(func(ctx *pulumi.Context) error {
		// Create a new app on DigitalOcean
		app, err := digitalocean.NewApp(ctx, "stratocraft-app", &digitalocean.AppArgs{
			Spec: &digitalocean.AppSpecArgs{
				Name:   pulumi.String("stratocraft-dev"),
				Region: pulumi.String("nyc"),
				Services: digitalocean.AppSpecServiceArray{
					&digitalocean.AppSpecServiceArgs{
						Name: pulumi.String("web"),
						Git: &digitalocean.AppSpecServiceGitArgs{
							RepoCloneUrl: pulumi.String("https://github.com/stratocraft/stratocraft.dev.git"),
							Branch:       pulumi.String("main"),
						},
						SourceDir:       pulumi.String("/"),
						BuildCommand:    pulumi.String("go mod download && CGO_ENABLED=0 go build -o /app/server server/main.go"),
						RunCommand:      pulumi.String("/app/server"),
						HttpPort:        pulumi.Int(8080),
						EnvironmentSlug: pulumi.String("go"),
					},
				},
				DomainNames: digitalocean.AppSpecDomainNameArray{
					&digitalocean.AppSpecDomainNameArgs{
						Name: pulumi.String("stratocraft.dev"),
					},
				},
			},
		})
		if err != nil {
			return err
		}

		ctx.Export("appURL", app.LiveUrl)
		return nil
	})
}
