#!/bin/bash

# Development script for running stratocraft.dev

# Check if GITHUB_TOKEN is set
if [ -z "$GITHUB_TOKEN" ]; then
    echo "Warning: GITHUB_TOKEN environment variable is not set."
    echo "To avoid GitHub API rate limiting, please:"
    echo "1. Create a Personal Access Token at: https://github.com/settings/tokens"
    echo "2. Export it: export GITHUB_TOKEN=your_token_here"
    echo "3. Run this script again"
    echo ""
    echo "Continuing without authentication (rate limited to 60 requests/hour)..."
    echo ""
fi

# Check if GITHUB_WEBHOOK_SECRET is set
if [ -z "$GITHUB_WEBHOOK_SECRET" ]; then
    echo "Notice: GITHUB_WEBHOOK_SECRET environment variable is not set."
    echo "This is only needed if you plan to use GitHub webhooks for auto-refresh."
    echo "To set up webhooks:"
    echo "1. Generate a secret: openssl rand -hex 32"
    echo "2. Export it: export GITHUB_WEBHOOK_SECRET=your_secret_here"
    echo "3. Configure it in your GitHub repo webhook settings"
    echo ""
fi

# Generate templates
echo "Generating templates..."
templ generate

# Build CSS
echo "Building CSS..."
npx tailwindcss -i ./public/css/style.css -o ./public/css/site.css --minify

# Run the server
echo "Starting server on http://localhost:8080"
echo "Webhook endpoint available at: http://localhost:8080/webhook/github"
cd server && go run main.go 