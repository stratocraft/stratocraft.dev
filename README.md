# StratoCraft.dev

A high-performance, SEO-optimized website built with Go, a-h/templ, and Tailwind CSS. Designed to achieve a perfect 100 Lighthouse score while maintaining modern design principles and accessibility standards.

## 🚀 Features

- **Perfect Performance**: Optimized for 100 Lighthouse score
- **Modern Stack**: Go + a-h/templ + Tailwind CSS
- **Responsive Design**: Mobile-first, looks great on all devices
- **Dark/Light Mode**: Automatic theme switching with system preference detection
- **SEO Optimized**: Structured data, meta tags, and semantic HTML
- **PWA Ready**: Service worker for offline functionality
- **Accessibility**: WCAG 2.1 AA compliant
- **Security**: Security headers, CSP, and best practices
- **CI/CD**: Comprehensive GitHub Actions pipeline
- **Infrastructure as Code**: Terraform for Azure deployment

## 🏗️ Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   GitHub        │    │   Azure          │    │   Monitoring    │
│   Repository    │───▶│   Container Apps │───▶│   & Alerting    │
│                 │    │                  │    │                 │
└─────────────────┘    └──────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   CI/CD         │    │   Azure CDN      │    │   Application   │
│   Pipeline      │    │   + DNS          │    │   Insights      │
│                 │    │                  │    │                 │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

## 🛠️ Technology Stack

- **Backend**: Go 1.21
- **Templating**: a-h/templ
- **Styling**: Tailwind CSS
- **Containerization**: Docker
- **Cloud Platform**: Microsoft Azure
- **Infrastructure**: Terraform
- **CI/CD**: GitHub Actions
- **Monitoring**: Azure Application Insights
- **CDN**: Azure CDN

## 📁 Project Structure

```
stratocraft.dev/
├── .github/
│   └── workflows/
│       └── ci-cd.yml          # GitHub Actions pipeline
├── infrastructure/
│   ├── main.tf                # Terraform main configuration
│   ├── variables.tf           # Terraform variables
│   └── outputs.tf             # Terraform outputs
├── static/
│   ├── css/
│   │   └── tailwind.css       # Compiled Tailwind CSS
│   ├── js/
│   │   └── theme.js           # Theme toggle & interactions
│   └── images/                # Images and assets
├── content/
│   └── posts/                 # Blog posts in Markdown
├── templates/
│   └── components.templ       # Templ components
├── main.go                    # Go application entry point
├── Dockerfile                # Container configuration
├── go.mod                    # Go modules
├── tailwind.config.js        # Tailwind configuration
└── README.md                 # This file
```

## 🚀 Quick Start

### Prerequisites

- Go 1.21+
- Docker
- Azure CLI
- Terraform
- Node.js (for Tailwind CSS)

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
   npm install -g @tailwindcss/cli
   ```

3. **Generate templates**
   ```bash
   templ generate
   ```

4. **Build Tailwind CSS**
   ```bash
   tailwindcss -i ./static/css/input.css -o ./static/css/tailwind.css --watch
   ```

5. **Run the application**
   ```bash
   go run .
   ```

6. **Visit** http://localhost:8080

### Docker Development

1. **Build the image**
   ```bash
   docker build -t stratocraft .
   ```

2. **Run the container**
   ```bash
   docker run -p 8080:8080 stratocraft
   ```

## 🌐 Deployment

### Azure Setup

1. **Create Azure resources**
   ```bash
   cd infrastructure
   terraform init
   terraform plan
   terraform apply
   ```

2. **Configure GitHub Secrets**
    - `AZURE_CREDENTIALS`: Azure service principal
    - `ACR_USERNAME`: Container registry username
    - `ACR_PASSWORD`: Container registry password
    - `SONAR_TOKEN`: SonarCloud token
    - `SLACK_WEBHOOK_URL`: Slack notifications

3. **Deploy via GitHub Actions**
    - Push to `main` branch triggers automatic deployment
    - Pull requests trigger testing and security scans

### Custom Domain Setup

1. **Update DNS records** to point to Azure CDN
2. **Configure SSL certificate** in Azure CDN
3. **Update Terraform** with your domain name

## 📊 Performance Optimization

### Lighthouse Scores Target: 100/100

- **Performance**:
    - Optimized images with WebP format
    - Minimal JavaScript, loaded defer/async
    - Critical CSS inlined
    - Service worker for caching

- **Accessibility**:
    - Semantic HTML structure
    - ARIA labels and roles
    - Keyboard navigation support
    - High contrast ratios

- **Best Practices**:
    - HTTPS everywhere
    - Security headers
    - No deprecated APIs
    - Proper error handling

- **SEO**:
    - Structured data (JSON-LD)
    - Meta descriptions and titles
    - Sitemap and robots.txt
    - Open Graph and Twitter Cards

## 🔒 Security

- **Container Security**: Non-root user, minimal base image
- **Network Security**: HTTPS only, security headers
- **Code Security**: Static analysis with gosec and SonarCloud
- **Dependency Security**: Trivy vulnerability scanning
- **Runtime Security**: Azure Container Apps security features

## 📈 Monitoring & Observability

- **Application Insights**: Performance and error tracking
- **Azure Monitor**: Infrastructure monitoring and alerting
- **Log Analytics**: Centralized logging
- **Uptime Monitoring**: Health checks and availability alerts

## 🧪 Testing

### Automated Testing

```bash
# Unit tests
go test -v ./...

# Coverage report
go test -coverprofile=coverage.out ./...
go tool cover -html=coverage.out

# Security scanning
gosec ./...

# Static analysis
staticcheck ./...
```

### Performance Testing

```bash
# Lighthouse CI
npm install -g @lhci/cli
lhci autorun

# Load testing
artillery run load-test.yml
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Commit changes: `git commit -m 'Add amazing feature'`
4. Push to branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

### Code Quality Standards

- Go code must pass `go vet`, `gosec`, and `staticcheck`
- All tests must pass with >80% coverage
- Security scans must pass
- Lighthouse scores must maintain 100/100

## 📚 Content Management

### Adding Blog Posts

1. Create a new `.md` file in `content/posts/`
2. Add frontmatter:
   ```yaml
   ---
   title: "Your Post Title"
   description: "Brief description"
   date: "2024-01-15"
   tags: "go,devops,cloud"
   ---
   ```
3. Write your content in Markdown
4. Commit and push - the post will be automatically deployed

## 🚨 Troubleshooting

### Common Issues

1. **Templ generation fails**
    - Ensure templ CLI is installed: `go install github.com/a-h/templ/cmd/templ@latest`
    - Run `templ generate` before building

2. **Tailwind styles not loading**
    - Check if CSS file is generated: `tailwindcss -i ./static/css/input.css -o ./static/css/tailwind.css`
    - Verify file path in HTML template

3. **Container fails to start**
    - Check logs: `docker logs <container-id>`
    - Verify environment variables
    - Ensure port 8080 is exposed

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Support

- **Documentation**: Check this README and inline code comments
- **Issues**: Open a GitHub issue for bugs or feature requests
- **Contact**: hello@stratocraft.dev

---

Built with ❤️ for the cloud-native community