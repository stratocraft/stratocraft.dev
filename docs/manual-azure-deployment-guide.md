# 🚀 Manual Azure Deployment Guide with Bash scripts

This guide explains how to deploy [stratocraft.dev](https://stratocraft.dev) to Azure Container Instances using the optimized Docker container and deployment script(s).

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

# Deploy to Azure using one of the two provided scripts:

# [Standard] Slightly more expensive than the cost optimized version.
./scripts/deploy-azure.sh

# [Cost Optimized] About $3 per month or $36 per year cheaper to run.
./scripts/deploy-azure-minimal.sh
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

See the [Webhook Setup Guide](webhook-setup-guide.md) for information about configuring the Webhook if you want to use live post updates.

```bash
# Required: provide your Token you generated under Settings > Developer Settings > Personal access tokens > Tokens (classic)
export GITHUB_TOKEN=your_github_token_here

# Recommended: generate webhook secret and follow the steps in the Webhook Setup Guide 
export GITHUB_WEBHOOK_SECRET=$(openssl rand -hex 32)

# Optional: override the Azure deployment environment variables with your preferences, example:
export AZURE_RESOURCE_GROUP=my-rg-name
export AZURE_CONTAINER_REGISTRY=my-acr-name
export DNS_NAME_LABEL=my-blog-name
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

I provide two deployment options to balance performance and cost based on your needs:

### 🚀 Standard Deployment (`./scripts/deploy-azure.sh`)

**Configuration:**
- CPU: 0.5 vCPU
- Memory: 0.5 GB
- Restart Policy: Always
- Health Checks: Every 60s

**Estimated Monthly Costs (South Central US):**
- **Container Registry**: ~$5/month (Basic tier)
- **Container Instance**: ~$10/month (0.5 vCPU, 0.5GB RAM)
- **Networking**: ~$1/month (data transfer)
- **Total**: ~$16/month

### 💰 Cost-Optimized Deployment (`./scripts/deploy-azure-minimal.sh`)

**Configuration:**
- CPU: 0.25 vCPU
- Memory: 0.5 GB
- Restart Policy: OnFailure (stops when not needed)
- Health Checks: Every 60s

**Estimated Monthly Costs (South Central US):**
- **Container Registry**: ~$5/month (Basic tier)
- **Container Instance**: ~$7/month (0.25 vCPU, 0.5GB RAM)
- **Networking**: ~$1/month (data transfer)
- **Total**: ~$13/month

### 📊 Cost Comparison

| Feature             | Standard         | Cost-Optimized | Savings            |
|---------------------|------------------|----------------|--------------------|
| **Monthly Cost**    | ~$16             | ~$13           | ~$3/month          |
| **CPU Performance** | Better           | Good           | -                  |
| **Memory**          | Same             | Same           | -                  |
| **Uptime**          | 100%             | 95-99%*        | Better reliability |
| **Best For**        | Production sites | Personal blogs | -                  |

*OnFailure restart policy may cause brief downtime during failures vs. immediate restart

### 🎯 Which Option Should You Choose?

**Choose Standard Deployment if:**
- You expect consistent traffic
- You need maximum uptime (99.9%+)
- You're running in production
- $3/month difference isn't significant

**Choose Cost-Optimized Deployment if:**
- You're running a personal blog or side project
- You want to minimize costs
- Occasional brief downtime is acceptable
- You're experimenting or in development

### 💡 Additional Cost Reduction Strategies

Beyond choosing between deployment options, you can further reduce costs:

1. **Regional Selection**
   - South Central US: Cheapest option (used in scripts)
   - East US: Standard pricing
   - West US: Slightly more expensive

2. **Image Optimization** (Already implemented)
   - Multi-stage Docker builds
   - Minimal Alpine Linux base
   - Only essential files copied
   - Optimized health check frequency

3. **Monitoring and Right-Sizing**
   ```bash
   # Monitor actual resource usage
   az monitor metrics list \
     --resource /subscriptions/{subscription}/resourceGroups/stratocraft-rg/providers/Microsoft.ContainerInstance/containerGroups/stratocraft-app \
     --metric "CpuUsage,MemoryUsage"
   
   # If consistently low usage, consider switching to cost-optimized
   ```

4. **Scheduled Scaling** (Manual)
   ```bash
   # Stop container during low-traffic hours (if acceptable)
   az container stop --resource-group stratocraft-rg --name stratocraft-app
   
   # Start when needed
   az container start --resource-group stratocraft-rg --name stratocraft-app
   ```

### 🔄 Switching Between Options

You can easily switch between deployment types:

```bash
# Switch to cost-optimized
az container delete --resource-group stratocraft-rg --name stratocraft-app --yes
./scripts/deploy-azure-minimal.sh

# Switch back to standard
az container delete --resource-group stratocraft-rg --name stratocraft-app --yes
./scripts/deploy-azure.sh
```

### 💰 Annual Cost Summary

| Deployment Type    | Monthly | Annual | Use Case                       |
|--------------------|---------|--------|--------------------------------|
| **Cost-Optimized** | $13     | $156   | Personal blogs, side projects  |
| **Standard**       | $16     | $192   | Production sites, business use |
| **Difference**     | $3      | $36    | -                              |

Both options are significantly cheaper than traditional hosting solutions while providing enterprise-grade reliability and scalability.

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