# stratocraft.dev

A modern, high-performance blog built with Go, Templ templates, and Tailwind CSS. Features real-time search, GitHub-based content management, and automatic post updates via webhooks.

## 🚀 Features

- **Modern Go Stack**: Go 1.24 + Echo v4 + Templ templates + Tailwind CSS v4
- **GitHub Content Management**: Posts stored as Markdown in GitHub repository
- **Real-time Search**: HTMX-powered search with tag and title filtering
- **Webhook Auto-Updates**: Automatically refreshes content when posts are added to GitHub
- **Responsive Design**: Mobile-first design with dark/light mode support
- **Syntax Highlighting**: Code blocks with tokyo-night theme
- **SEO Optimized**: Structured data, meta tags, and semantic HTML
- **Production Ready**: Docker containerization for Azure deployment

## 🏗️ Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   GitHub Posts  │    │   stratocraft.dev│    │   GitHub        │
│   Repository    │───▶│   Application    │◀───│   Webhook       │
│   (Markdown)    │    │   (Go + Templ)   │    │   (Auto-refresh)│
└─────────────────┘    └──────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Content API   │    │   Azure          │    │   Real-time     │
│   (GitHub API)  │    │   Container      │    │   Search        │
│                 │    │   Instances      │    │   (HTMX)        │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

## 🛠️ Technology Stack

**Backend:**
- Go 1.24 with Echo v4 framework
- Templ for type-safe HTML templates
- GitHub API for content management
- HTMX for dynamic interactions

**Frontend:**
- Tailwind CSS v4 for styling
- Vanilla JavaScript for theme switching
- Highlight.js for syntax highlighting
- Responsive design with mobile navigation

**Infrastructure:**
- Docker for containerization
- Azure Container Instances for hosting
- Azure Container Registry for image storage
- GitHub webhooks for automatic updates

## 📁 Project Structure

```
stratocraft.dev/
├── docs/
│   ├── manual-azure-deployment-guide.md    # Azure deployment guide
│   └── webhook-setup-guide.md              # GitHub webhook setup
├── internal/
│   ├── application/                        # HTTP handlers
│   │   ├── home.go                         # Home page handler
│   │   ├── posts.go                        # Posts listing handler
│   │   ├── post.go                         # Individual post handler
│   │   ├── search.go                       # Search functionality
│   │   ├── about.go                        # About page handler
│   │   └── webhook.go                      # GitHub webhook handler
│   ├── contentmanager/                     # GitHub integration
│   │   ├── contentmanager.go               # Content fetching logic
│   │   └── parsemarkdown.go                # Markdown parsing
│   ├── views/
│   │   ├── pages/                          # Page templates
│   │   ├── components/                     # Reusable components
│   │   └── shared/                         # Layout and navigation
│   └── site/                               # Site configuration
├── public/
│   ├── css/                                # Stylesheets
│   ├── js/                                 # JavaScript files
│   └── img/                                # Images and assets
├── scripts/
│   ├── deploy-azure.sh                     # Standard Azure deployment
│   ├── deploy-azure-minimal.sh             # Cost-optimized deployment
│   ├── run-dev.sh                          # Development setup
│   └── test-webhook.sh                     # Webhook testing
├── server/
│   └── main.go                             # Application entry point
├── Dockerfile                              # Container configuration
├── package.json                            # Tailwind CSS dependencies
└── README.md                               # This file
```

## 🚀 Quick Start

### Prerequisites

- Go 1.24+
- Docker (for deployment)
- Node.js (for Tailwind CSS)
- GitHub Personal Access Token

### Local Development

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/stratocraft.dev.git
   cd stratocraft.dev
   ```

2. **Install dependencies**
   ```bash
   go mod download
   go install github.com/a-h/templ/cmd/templ@latest
   go install github.com/cosmtrek/air@latest
   npm install
   ```

3. **Set environment variables**
   ```bash
   export GITHUB_TOKEN=your_github_token_here
   export GITHUB_WEBHOOK_SECRET=$(openssl rand -hex 32)  # Optional
   ```

4. **Start development servers** (in separate terminals)
   
   **Terminal 1 - Templ Watch:**
   ```bash
   ./scripts/templ-watch.sh
   ```
   
   **Terminal 2 - Tailwind Watch:**
   ```bash
   ./scripts/tailwind-watch.sh
   ```
   
   **Terminal 3 - Go Server with Air:**
   ```bash
   air
   ```

5. **Visit** http://localhost:8080

   The application will automatically reload when you make changes to:
   - Go files (via Air)
   - Templ templates (via templ-watch.sh)
   - CSS styles (via tailwind-watch.sh)

### Alternative: All-in-One Development Script

For convenience, you can also use the unified development script:

```bash
./scripts/run-dev.sh
```

This script handles the initial build but doesn't provide hot reloading. For active development, use the watch scripts above.

### Manual Setup (No Hot Reloading)

If you prefer to run each step manually without hot reloading:

```bash
# Generate templates
templ generate

# Build CSS
npx tailwindcss -i ./public/css/style.css -o ./public/css/site.css --minify

# Run the server
cd server && go run main.go
```

## 🌐 Deployment to Azure

We provide two deployment options with different cost profiles:

### Standard Deployment (~$16/month)
```bash
export GITHUB_TOKEN=your_token
export GITHUB_WEBHOOK_SECRET=your_webhook_secret
./scripts/deploy-azure.sh
```

### Cost-Optimized Deployment (~$13/month)
```bash
export GITHUB_TOKEN=your_token
export GITHUB_WEBHOOK_SECRET=your_webhook_secret
./scripts/deploy-azure-minimal.sh
```

📖 **Detailed Instructions**: See [Azure Deployment Guide](docs/manual-azure-deployment-guide.md) for complete setup instructions, cost comparison, and configuration options.

## 🔄 GitHub Webhook Setup

Enable automatic content updates when you add new blog posts:

1. Generate a webhook secret: `openssl rand -hex 32`
2. Configure the webhook in your GitHub posts repository
3. Set the webhook URL to: `https://yourdomain.com/webhook/github`

📖 **Detailed Instructions**: See [Webhook Setup Guide](docs/webhook-setup-guide.md) for step-by-step configuration.

## ✨ Key Features

### Content Management
- **GitHub Integration**: Posts stored as Markdown files in a separate GitHub repository
- **Automatic Refresh**: Webhook-triggered content updates without server restarts
- **Frontmatter Support**: YAML frontmatter for post metadata (title, date, tags, etc.)

### Search & Navigation
- **Real-time Search**: HTMX-powered search across post titles and tags
- **Posts Listing**: Paginated view of all posts, sorted by date
- **Individual Post Pages**: Clean, readable post layout with syntax highlighting
- **Mobile Navigation**: Hamburger menu with smooth animations

### Performance & SEO
- **Fast Loading**: Optimized Docker images and efficient Go backend
- **Syntax Highlighting**: Code blocks with tokyo-night-dark theme
- **Dark/Light Mode**: Automatic theme detection with manual toggle
- **Responsive Design**: Mobile-first approach with Tailwind CSS

## 🔧 Configuration

### Environment Variables

**Required:**
- `GITHUB_TOKEN`: Personal access token for GitHub API access

**Optional:**
- `GITHUB_WEBHOOK_SECRET`: Secret for webhook signature verification
- `PORT`: Server port (default: 8080)

### Site Configuration

Edit `internal/site/site.go` to configure:
- Post repository owner and name
- Site metadata and branding
- Navigation links

## 📝 Content Management

### Adding Blog Posts

1. **Create a Markdown file** in your posts repository
2. **Add frontmatter**:
   ```yaml
   ---
   id: unique-post-id
   title: "Your Post Title"
   date: 2024-01-15T00:00:00Z
   tags: ["go", "web-development", "azure"]
   slug: your-post-slug
   published: true
   ---
   ```
3. **Write your content** in Markdown
4. **Commit and push** - the site will automatically update via webhook

### Supported Frontmatter Fields

- `id`: Unique identifier for the post
- `title`: Post title (required)
- `date`: Publication date in RFC3339 format
- `tags`: Array of tags for categorization
- `slug`: URL slug (auto-generated if not provided)
- `published`: Boolean to control post visibility

## 🐳 Docker

### Build Image
```bash
docker build -t stratocraft-dev .
```

### Run Container
```bash
docker run -p 8080:8080 \
  -e GITHUB_TOKEN=your_token \
  -e GITHUB_WEBHOOK_SECRET=your_secret \
  stratocraft-dev
```

## 🧪 Testing

### Test Webhook Locally
```bash
export GITHUB_WEBHOOK_SECRET=your_secret
./scripts/test-webhook.sh
```

### Run Application Tests
```bash
go test ./...
```

## 🚨 Troubleshooting

### Common Issues

1. **Templ generation fails**
   - Install templ CLI: `go install github.com/a-h/templ/cmd/templ@latest`
   - Run `templ generate` before building

2. **Tailwind styles not loading**
   - Build CSS: `npx tailwindcss -i ./public/css/style.css -o ./public/css/site.css --minify`
   - Check file paths in templates

3. **GitHub API rate limiting**
   - Set `GITHUB_TOKEN` environment variable
   - Verify token has repository read permissions

4. **Webhook not working**
   - Check webhook secret matches environment variable
   - Verify webhook URL is publicly accessible
   - Check server logs for error messages

## 📚 Documentation

- **[Azure Deployment Guide](docs/manual-azure-deployment-guide.md)**: Complete Azure deployment instructions with cost optimization
- **[Webhook Setup Guide](docs/webhook-setup-guide.md)**: GitHub webhook configuration for automatic updates

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Commit changes: `git commit -m 'Add amazing feature'`
4. Push to branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Support

- **Documentation**: Check the guides in the `docs/` folder
- **Issues**: Open a GitHub issue for bugs or feature requests
- **Contact**: [Open an issue](https://github.com/yourusername/stratocraft.dev/issues) for support

---

Built with ❤️ using Go, Templ, and Tailwind CSS