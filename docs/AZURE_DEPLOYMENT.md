# 🚀 Azure Deployment Guide

This guide explains how to deploy [stratocraft.dev](https://stratocraft.dev) to Azure Container Instances using the optimized Docker container.

## Overview

The deployment uses:
- **Azure Container Registry (ACR)** to store the Docker image
- **Azure Container Instances (ACI)** to run the application
- **Multi-stage Docker build** for optimized image size and security
- **Environment variables** for configuration

## Prerequisites

1. **Azure CLI** installed and configured
2. **Docker** installed locally
3. **Azure subscription** with appropriate permissions
4. **GitHub Personal Access Token** for API access
5. **GitHub Webhook Secret** (optional, for auto-refresh)

## Quick Start

```bash
# Required: export these environment variables for your Token and Webhook Secret configured on GitHub
export GITHUB_TOKEN=your_github_token_here
export GITHUB_WEBHOOK_SECRET=your_webhook_secret_here

# Optional: export these variables to override the defaults shown below
export AZURE_RESOURCE_GROUP=stratocraft-rg
export AZURE_CONTAINER_REGISTRY=stratocraft-acr
export DNS_NAME_LABEL=stratocraft-dev
export AZURE_LOCATION=southcentralus

# Deploy to Azure
./scripts/deploy-azure.sh
```

## Environment Variables

### Required
- `GITHUB_TOKEN`: Personal access token for GitHub API (avoid rate limiting)

### Optional
- `GITHUB_WEBHOOK_SECRET`: Secret for webhook signature verification, required for live post updates
- `AZURE_RESOURCE_GROUP`: Resource group name (default: `stratocraft-rg`)
- `AZURE_CONTAINER_REGISTRY`: Container registry name (default: `stratocraf-acr`)
- `DNS_NAME_LABEL`: DNS label for public IP (default: `stratocraft-dev`)
- `AZURE_LOCATION`: Azure region (default: `southcentralus`)

## Step-by-Step Deployment

### 1. Install Azure CLI

**macOS:**
```bash
brew install azure-cli
```

**Windows:**
```bash
winget install Microsoft.AzureCLI
```

**Linux:**
```bash
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

### 2. Login to Azure

```bash
az login
```

### 3. Set Environment Variables

See the [Webhook Setup Guide](WEBHOOK_SETUP.md) for information about configuring the Webhook if you want to use live post updates.

```bash
# Required: provide your Token you generated under Settings > Developer Settings > Personal access tokens > Tokens (classic)
export GITHUB_TOKEN=your_github_token_here

# Generate webhook secret. 
export GITHUB_WEBHOOK_SECRET=$(openssl rand -hex 32)

# Optional customizations
export AZURE_RESOURCE_GROUP=my-stratocraft-rg
export DNS_NAME_LABEL=my-blog
```

### 4. Run Deployment Script

```bash
./scripts/deploy-azure.sh
```

The script will:
1. ✅ Build the Docker image locally
2. ✅ Create Azure resource group and container registry
3. ✅ Push image to Azure Container Registry
4. ✅ Deploy to Azure Container Instances
5. ✅ Provide you with the public URL

## Docker Image Optimization

The Dockerfile uses several optimization techniques:

### Multi-Stage Build
- **CSS Builder**: Compiles Tailwind CSS in Node.js container
- **Go Builder**: Generates templ files and builds Go binary
- **Final**: Minimal Alpine Linux container with only runtime dependencies

### Size Optimization
- Static binary compilation (`CGO_ENABLED=0`)
- Symbol stripping (`-ldflags='-w -s'`)
- Alpine Linux base (< 10MB)
- Only necessary files copied to final image

### Security Features
- Non-root user execution
- Minimal attack surface
- Health checks included
- Updated base image with security patches

## Container Configuration

| Setting            | Value     | Description                                     |
|--------------------|-----------|-------------------------------------------------|
| **CPU**            | 1 core    | Sufficient for Go web application               |
| **Memory**         | 1 GB      | Handles content caching and concurrent requests |
| **Port**           | 8080      | Application listening port                      |
| **Restart Policy** | Always    | Automatic restart on failure                    |
| **Health Check**   | Every 30s | Monitors application health                     |

## Monitoring and Maintenance

### View Container Logs
```bash
az container logs \
  --resource-group stratocraft-rg \
  --name stratocraft-app \
  --follow
```

### Check Container Status
```bash
az container show \
  --resource-group stratocraft-rg \
  --name stratocraft-app \
  --query "{status:instanceView.state,fqdn:ipAddress.fqdn,ip:ipAddress.ip}"
```

### Restart Container
```bash
az container restart \
  --resource-group stratocraft-rg \
  --name stratocraft-app
```

### Update Deployment
```bash
# Build new image
docker build -t stratocraft-dev:v2 .

# Update the deployment (requires manual steps)
# See "Updating the Application" section below
```

## Updating the Application

To update your deployment with new code:

```bash
# Set new image tag
export IMAGE_TAG=v$(date +%Y%m%d-%H%M%S)

# Run deployment script (it will create new version)
./scripts/deploy-azure.sh

# Optional: Clean up old container instances
az container delete \
  --resource-group stratocraft-rg \
  --name stratocraft-app-old \
  --yes
```

## Cost Optimization

### Estimated Monthly Costs (East US)
- **Container Registry**: ~$5/month (Basic tier)
- **Container Instance**: ~$15/month (1 vCPU, 1GB RAM)
- **Networking**: ~$2/month (data transfer)
- **Total**: ~$22/month

### Cost Reduction Options
1. **Use smaller regions** if acceptable for your users
2. **Scale down during low traffic** periods
3. **Use Azure Container Apps** for auto-scaling (may reduce costs)
4. **Monitor and right-size** resources based on actual usage

## Custom Domain Setup

### 1. Configure DNS
Point your domain to the container's public IP:
```bash
# Get the public IP
az container show \
  --resource-group stratocraft-rg \
  --name stratocraft-app \
  --query ipAddress.ip
```

### 2. SSL Certificate
For production, use Azure Application Gateway or Azure Front Door for SSL termination.

## Troubleshooting

### Container Won't Start
```bash
# Check container logs
az container logs --resource-group stratocraft-rg --name stratocraft-app

# Common issues:
# - Missing environment variables
# - Image pull failures
# - Port conflicts
```

### High Memory Usage
```bash
# Monitor resource usage
az monitor metrics list \
  --resource /subscriptions/{subscription}/resourceGroups/stratocraft-rg/providers/Microsoft.ContainerInstance/containerGroups/stratocraft-app \
  --metric "MemoryUsage"
```

### Webhook Issues
```bash
# Test webhook endpoint
curl -X POST https://your-domain.com/webhook/github \
  -H "Content-Type: application/json" \
  -d '{"test":"webhook"}'

# Check logs for webhook processing
az container logs --resource-group stratocraft-rg --name stratocraft-app | grep -i webhook
```

## Security Considerations

### Production Checklist
- [ ] Use strong webhook secrets
- [ ] Enable Azure Network Security Groups
- [ ] Set up Azure Key Vault for secrets
- [ ] Enable container registry admin user restrictions
- [ ] Configure Azure Monitor alerts
- [ ] Regular security updates (rebuild images)
- [ ] Implement backup strategy for container registry

### Network Security
Consider using Azure Virtual Network for additional isolation:
```bash
az container create \
  --resource-group stratocraft-rg \
  --name stratocraft-app \
  --vnet my-vnet \
  --subnet my-subnet \
  # ... other parameters
```

## Support and Resources

- [Azure Container Instances Documentation](https://docs.microsoft.com/en-us/azure/container-instances/)
- [Azure Container Registry Documentation](https://docs.microsoft.com/en-us/azure/container-registry/)
- [Azure CLI Reference](https://docs.microsoft.com/en-us/cli/azure/)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/) 