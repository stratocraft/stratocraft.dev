#!/bin/bash

# Azure App Service Deployment Script for stratocraft.dev
# Deploys as a containerized web app with better performance and reliability

set -e

# Configuration
RESOURCE_GROUP="${AZURE_RESOURCE_GROUP:-stratocraft-rg}"
CONTAINER_REGISTRY="${AZURE_CONTAINER_REGISTRY:-stratocraftacr}"
APP_NAME="${AZURE_APP_NAME:-stratocraft-webapp}"
APP_SERVICE_PLAN="${AZURE_APP_SERVICE_PLAN:-stratocraft-plan}"
IMAGE_NAME="stratocraft-dev"
IMAGE_TAG="${IMAGE_TAG:-latest}"
LOCATION="${AZURE_LOCATION:-eastus}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 Starting Azure App Service deployment for stratocraft.dev${NC}"

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

# Show current subscription for verification
echo -e "${BLUE}Current Azure subscription:${NC}"
SUBSCRIPTION_NAME=$(az account show --query name --output tsv)
SUBSCRIPTION_ID=$(az account show --query id --output tsv)
echo -e "${BLUE}  Name: $SUBSCRIPTION_NAME${NC}"
echo -e "${BLUE}  ID: $SUBSCRIPTION_ID${NC}"
echo ""

# Check required environment variables
if [ -z "$GITHUB_TOKEN" ]; then
    echo -e "${RED}❌ GITHUB_TOKEN environment variable is required${NC}"
    echo "Please set it with: export GITHUB_TOKEN=your_token_here"
    exit 1
fi

echo -e "${GREEN}✓ Environment check passed${NC}"

echo -e "${GREEN}📦 Building optimized Docker image for App Service...${NC}"
# Use buildx to ensure AMD64 architecture
docker buildx create --use --name appservice-builder &> /dev/null || true
docker buildx build --platform linux/amd64 -t "$IMAGE_NAME":"$IMAGE_TAG" --load .

# Create resource group if it doesn't exist
echo -e "${GREEN}🏗️  Creating resource group (if needed)...${NC}"
if ! az group show --name "$RESOURCE_GROUP" &> /dev/null; then
    echo -e "${BLUE}Creating new resource group: $RESOURCE_GROUP${NC}"
    az group create --name "$RESOURCE_GROUP" --location "$LOCATION" --output none
    echo -e "${GREEN}✓ Resource group created${NC}"
else
    echo -e "${BLUE}Resource group $RESOURCE_GROUP already exists${NC}"
fi

# Create container registry if it doesn't exist
echo -e "${GREEN}📝 Creating container registry (if needed)...${NC}"
if ! az acr show --name "$CONTAINER_REGISTRY" --resource-group "$RESOURCE_GROUP" &> /dev/null; then
    echo -e "${BLUE}Creating new container registry: $CONTAINER_REGISTRY${NC}"
    if ! az acr create \
        --resource-group "$RESOURCE_GROUP" \
        --name "$CONTAINER_REGISTRY" \
        --sku Basic \
        --location "$LOCATION" \
        --output none; then
        echo -e "${RED}❌ Failed to create container registry${NC}"
        exit 1
    fi
    echo -e "${GREEN}✓ Container registry created${NC}"
else
    echo -e "${BLUE}Container registry $CONTAINER_REGISTRY already exists${NC}"
fi

# Enable admin user for the registry
echo -e "${GREEN}🔧 Enabling admin access on container registry...${NC}"
if ! az acr update -n "$CONTAINER_REGISTRY" --admin-enabled true --output none; then
    echo -e "${RED}❌ Failed to enable admin access on container registry${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Admin access enabled${NC}"

# Get login server
echo -e "${GREEN}🔍 Getting container registry login server...${NC}"
LOGIN_SERVER=$(az acr show --name "$CONTAINER_REGISTRY" --resource-group "$RESOURCE_GROUP" --query loginServer --output tsv)
if [ -z "$LOGIN_SERVER" ]; then
    echo -e "${RED}❌ Failed to get container registry login server${NC}"
    exit 1
fi
echo -e "${BLUE}Login server: $LOGIN_SERVER${NC}"

# Tag image for registry
echo -e "${GREEN}🏷️  Tagging image for registry...${NC}"
docker tag "$IMAGE_NAME":"$IMAGE_TAG" "$LOGIN_SERVER"/"$IMAGE_NAME":"$IMAGE_TAG"

# Log in to container registry
echo -e "${GREEN}🔐 Logging in to container registry...${NC}"
az acr login --name "$CONTAINER_REGISTRY"

# Push image to registry
echo -e "${GREEN}⬆️  Pushing image to container registry...${NC}"
docker push "$LOGIN_SERVER"/"$IMAGE_NAME":"$IMAGE_TAG"

# Create App Service Plan (B1 - cost-effective for small apps)
echo -e "${GREEN}📋 Creating App Service Plan (B1 tier)...${NC}"
if ! az appservice plan show --name "$APP_SERVICE_PLAN" --resource-group "$RESOURCE_GROUP" &> /dev/null; then
    echo -e "${BLUE}Creating new App Service Plan: $APP_SERVICE_PLAN${NC}"
    if ! az appservice plan create \
        --name "$APP_SERVICE_PLAN" \
        --resource-group "$RESOURCE_GROUP" \
        --location "$LOCATION" \
        --sku B1 \
        --is-linux \
        --output none; then
        echo -e "${RED}❌ Failed to create App Service Plan${NC}"
        exit 1
    fi
    echo -e "${GREEN}✓ App Service Plan created${NC}"
else
    echo -e "${BLUE}App Service Plan $APP_SERVICE_PLAN already exists${NC}"
fi

# Create the Web App
echo -e "${GREEN}🌐 Creating Web App...${NC}"
if ! az webapp show --name "$APP_NAME" --resource-group "$RESOURCE_GROUP" &> /dev/null; then
    echo -e "${BLUE}Creating new Web App: $APP_NAME${NC}"
    if ! az webapp create \
        --resource-group "$RESOURCE_GROUP" \
        --plan "$APP_SERVICE_PLAN" \
        --name "$APP_NAME" \
        --deployment-container-image-name "$LOGIN_SERVER/$IMAGE_NAME:$IMAGE_TAG" \
        --output none; then
        echo -e "${RED}❌ Failed to create Web App${NC}"
        exit 1
    fi
    echo -e "${GREEN}✓ Web App created${NC}"
else
    echo -e "${BLUE}Web App $APP_NAME already exists${NC}"
fi

# Configure container settings
echo -e "${GREEN}🔧 Configuring container settings...${NC}"
echo -e "${BLUE}Image: $LOGIN_SERVER/$IMAGE_NAME:$IMAGE_TAG${NC}"
if ! az webapp config container set \
    --name "$APP_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --docker-custom-image-name "$LOGIN_SERVER/$IMAGE_NAME:$IMAGE_TAG" \
    --docker-registry-server-url "https://$LOGIN_SERVER" \
    --docker-registry-server-user "$CONTAINER_REGISTRY" \
    --docker-registry-server-password "$(az acr credential show --name $CONTAINER_REGISTRY --query passwords[0].value --output tsv)" \
    --output none; then
    echo -e "${RED}❌ Failed to configure container settings${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Container settings configured${NC}"

# Set environment variables
echo -e "${GREEN}⚙️  Setting environment variables...${NC}"
ENV_SETTINGS="GITHUB_TOKEN=$GITHUB_TOKEN"
if [ -n "$GITHUB_WEBHOOK_SECRET" ]; then
    ENV_SETTINGS="$ENV_SETTINGS GITHUB_WEBHOOK_SECRET=$GITHUB_WEBHOOK_SECRET"
fi
ENV_SETTINGS="$ENV_SETTINGS PORT=8080"

echo -e "${BLUE}Environment variables: GITHUB_TOKEN=*****, GITHUB_WEBHOOK_SECRET=${GITHUB_WEBHOOK_SECRET:+*****}, PORT=8080${NC}"
if ! az webapp config appsettings set \
    --resource-group "$RESOURCE_GROUP" \
    --name "$APP_NAME" \
    --settings $ENV_SETTINGS \
    --output none; then
    echo -e "${RED}❌ Failed to set environment variables${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Environment variables set${NC}"

# Configure the port
echo -e "${GREEN}🔌 Configuring port settings...${NC}"
if ! az webapp config appsettings set \
    --resource-group "$RESOURCE_GROUP" \
    --name "$APP_NAME" \
    --settings WEBSITES_PORT=8080 \
    --output none; then
    echo -e "${RED}❌ Failed to configure port settings${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Port settings configured${NC}"

# Enable continuous deployment (auto-pull new images)
echo -e "${GREEN}🔄 Enabling continuous deployment...${NC}"
if ! az webapp deployment container config \
    --resource-group "$RESOURCE_GROUP" \
    --name "$APP_NAME" \
    --enable-cd true \
    --output none; then
    echo -e "${YELLOW}⚠️  Warning: Failed to enable continuous deployment (non-critical)${NC}"
else
    echo -e "${GREEN}✓ Continuous deployment enabled${NC}"
fi

# Get the app URL
APP_URL="https://$APP_NAME.azurewebsites.net"

# Wait for deployment to complete
echo -e "${GREEN}⏳ Waiting for deployment to complete...${NC}"
sleep 30

# Check if the app is running
echo -e "${GREEN}🔍 Checking application status...${NC}"
APP_STATE=$(az webapp show --resource-group "$RESOURCE_GROUP" --name "$APP_NAME" --query state --output tsv)

if [ "$APP_STATE" = "Running" ]; then
    echo -e "${GREEN}✅ App Service deployment successful!${NC}"
    echo -e "${GREEN}🌐 Your application is available at: $APP_URL${NC}"
    echo -e "${GREEN}🔄 Webhook endpoint: $APP_URL/webhook/github${NC}"
    echo -e "${GREEN}💰 Estimated monthly cost: ~$13-15 (B1 tier)${NC}"
    echo ""
    echo -e "${BLUE}📊 Management commands:${NC}"
    echo "• View logs: az webapp log tail --resource-group $RESOURCE_GROUP --name $APP_NAME"
    echo "• Restart app: az webapp restart --resource-group $RESOURCE_GROUP --name $APP_NAME"
    echo "• Scale up: az appservice plan update --resource-group $RESOURCE_GROUP --name $APP_SERVICE_PLAN --sku S1"
    echo ""
    echo -e "${YELLOW}🔧 Next steps:${NC}"
    echo "• Configure custom domain (optional)"
    echo "• Set up Azure CDN for better performance"
    echo "• Enable Application Insights for monitoring"
else
    echo -e "${RED}❌ Deployment may have issues. Checking logs...${NC}"
    az webapp log tail --resource-group "$RESOURCE_GROUP" --name "$APP_NAME" --provider application
fi

echo ""
echo -e "${YELLOW}💡 App Service advantages:${NC}"
echo "• Always-on web application (no cold starts)"
echo "• Built-in load balancing and SSL certificates"
echo "• Easy custom domain configuration"
echo "• Integrated CI/CD with continuous deployment"
echo "• Better cost efficiency for 24/7 workloads"
echo "• Built-in health monitoring and auto-restart" 