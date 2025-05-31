#!/bin/bash

# Azure Container Deployment Script for stratocraft.dev
# This script builds the Docker image and deploys it to Azure Container Instances

set -e

# Configuration (update these values for your deployment)
RESOURCE_GROUP="${AZURE_RESOURCE_GROUP:-stratocraft-rg}"
CONTAINER_REGISTRY="${AZURE_CONTAINER_REGISTRY:-stratocraf-acr}"
IMAGE_NAME="stratocraft-dev"
IMAGE_TAG="${IMAGE_TAG:-latest}"
CONTAINER_NAME="stratocraft-app"
DNS_NAME_LABEL="${DNS_NAME_LABEL:-stratocraft-dev}"
LOCATION="${AZURE_LOCATION:-southcentralus}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 Starting Azure deployment for stratocraft.dev${NC}"

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    echo -e "${RED}❌ Azure CLI is not installed. Please install it first.${NC}"
    exit 1
fi

# Check if user is logged in to Azure
if ! az account show &> /dev/null; then
    echo -e "${YELLOW}⚠️  Not logged in to Azure. Please log in first.${NC}"
    az login
fi

# Check required environment variables
if [ -z "$GITHUB_TOKEN" ]; then
    echo -e "${RED}❌ GITHUB_TOKEN environment variable is required${NC}"
    exit 1
fi

if [ -z "$GITHUB_WEBHOOK_SECRET" ]; then
    echo -e "${YELLOW}⚠️  GITHUB_WEBHOOK_SECRET not set. Webhooks will not work.${NC}"
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo -e "${GREEN}📦 Building Docker image...${NC}"
docker build -t "$IMAGE_NAME":"$IMAGE_TAG" .

# Create resource group if it doesn't exist
echo -e "${GREEN}🏗️  Creating resource group (if needed)...${NC}"
az group create --name "$RESOURCE_GROUP" --location "$LOCATION" --output none

# Create container registry if it doesn't exist
echo -e "${GREEN}📝 Creating container registry (if needed)...${NC}"
az acr create \
    --resource-group "$RESOURCE_GROUP" \
    --name "$CONTAINER_REGISTRY" \
    --sku Basic \
    --location "$LOCATION" \
    --output none || true

# Get login server
LOGIN_SERVER=$(az acr show --name "$CONTAINER_REGISTRY" --resource-group "$RESOURCE_GROUP" --query loginServer --output tsv)

# Tag image for registry
echo -e "${GREEN}🏷️  Tagging image for registry...${NC}"
# shellcheck disable=SC2086
docker tag "$IMAGE_NAME":"$IMAGE_TAG" "$LOGIN_SERVER"/"$IMAGE_NAME":$IMAGE_TAG

# Log in to container registry
echo -e "${GREEN}🔐 Logging in to container registry...${NC}"
az acr login --name "$CONTAINER_REGISTRY"

# Push image to registry
echo -e "${GREEN}⬆️  Pushing image to container registry...${NC}"
docker push "$LOGIN_SERVER"/"$IMAGE_NAME":"$IMAGE_TAG"

# Get registry credentials
echo -e "${GREEN}🔑 Getting registry credentials...${NC}"
ACR_USERNAME=$(az acr credential show --name "$CONTAINER_REGISTRY" --query username --output tsv)
ACR_PASSWORD=$(az acr credential show --name "$CONTAINER_REGISTRY" --query passwords[0].value --output tsv)

# Prepare environment variables
ENV_VARS="GITHUB_TOKEN=$GITHUB_TOKEN"
if [ -n "$GITHUB_WEBHOOK_SECRET" ]; then
    ENV_VARS="$ENV_VARS GITHUB_WEBHOOK_SECRET=$GITHUB_WEBHOOK_SECRET"
fi

# Deploy container to Azure Container Instances
echo -e "${GREEN}🚀 Deploying to Azure Container Instances...${NC}"
az container create \
    --resource-group "$RESOURCE_GROUP" \
    --name "$CONTAINER_NAME" \
    --image "$LOGIN_SERVER"/"$IMAGE_NAME":"$IMAGE_TAG" \
    --registry-login-server "$LOGIN_SERVER" \
    --registry-username "$ACR_USERNAME" \
    --registry-password "$ACR_PASSWORD" \
    --dns-name-label "$DNS_NAME_LABEL" \
    --ports 8080 \
    --environment-variables "$ENV_VARS" \
    --cpu 1 \
    --memory 1 \
    --restart-policy Always \
    --location "$LOCATION" \
    --output none

# Get the FQDN
FQDN=$(az container show --resource-group "$RESOURCE_GROUP" --name "$CONTAINER_NAME" --query ipAddress.fqdn --output tsv)

echo -e "${GREEN}✅ Deployment complete!${NC}"
echo -e "${GREEN}🌐 Your application is available at: https://$FQDN${NC}"
echo -e "${GREEN}📊 Monitor your container:${NC}"
echo "   az container logs --resource-group $RESOURCE_GROUP --name $CONTAINER_NAME --follow"
echo -e "${GREEN}🔄 Webhook endpoint:${NC}"
echo "   https://$FQDN/webhook/github"

echo ""
echo -e "${YELLOW}📝 Next steps:${NC}"
echo "1. Configure your GitHub webhook with URL: https://$FQDN/webhook/github"
echo "2. Set up custom domain and SSL certificate if needed"
echo "3. Configure monitoring and alerts" 