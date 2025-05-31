#!/bin/bash

# Cost-Optimized Azure Container Deployment Script for stratocraft.dev
# This script minimizes costs while maintaining functionality

set -e

# Configuration optimized for cost
RESOURCE_GROUP="${AZURE_RESOURCE_GROUP:-stratocraft-rg}"
CONTAINER_REGISTRY="${AZURE_CONTAINER_REGISTRY:-stratocraftacr}"
IMAGE_NAME="stratocraft-dev"
IMAGE_TAG="${IMAGE_TAG:-minimal}"
CONTAINER_NAME="stratocraft-app"
DNS_NAME_LABEL="${DNS_NAME_LABEL:-stratocraft-dev}"
# Use cheaper region
LOCATION="${AZURE_LOCATION:-southcentralus}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}💰 Starting cost-optimized Azure deployment for stratocraft.dev${NC}"

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

echo -e "${GREEN}📦 Building optimized Docker image...${NC}"
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
docker tag "$IMAGE_NAME":"$IMAGE_TAG" "$LOGIN_SERVER"/"$IMAGE_NAME":"$IMAGE_TAG"

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

# Deploy container with minimal resources
echo -e "${GREEN}💰 Deploying with cost-optimized settings...${NC}"
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
    --cpu 0.25 \
    --memory 0.5 \
    --restart-policy OnFailure \
    --location "$LOCATION" \
    --output none

# Get the FQDN
FQDN=$(az container show --resource-group "$RESOURCE_GROUP" --name "$CONTAINER_NAME" --query ipAddress.fqdn --output tsv)

echo -e "${GREEN}✅ Cost-optimized deployment complete!${NC}"
echo -e "${GREEN}🌐 Your application is available at: http://$FQDN${NC}"
echo -e "${GREEN}💰 Estimated monthly cost: ~$12-15${NC}"
echo -e "${GREEN}📊 Monitor your container:${NC}"
echo "   az container logs --resource-group $RESOURCE_GROUP --name $CONTAINER_NAME --follow"
echo -e "${GREEN}🔄 Webhook endpoint:${NC}"
echo "   http://$FQDN/webhook/github"

echo ""
echo -e "${YELLOW}💡 Cost optimization features enabled:${NC}"
echo "• Minimal CPU (0.25 vCPU) and memory (0.5GB)"
echo "• OnFailure restart policy (stops when not needed)"
echo "• Optimized health checks (60s intervals)"
echo "• Smaller Docker image with only essential files"
echo "• Cost-effective region (South Central US)" 