#!/bin/bash

# MacAdmin Production Deployment Script
# This script automates the deployment of MacAdmin to production servers

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 MacAdmin Production Deployment Script${NC}"
echo "============================================"

# Configuration
DOMAIN=${1:-""}
EMAIL=${2:-""}

if [ -z "$DOMAIN" ] || [ -z "$EMAIL" ]; then
    echo "Usage: $0 <domain> <email>"
    echo "Example: $0 macadmin.example.com admin@example.com"
    exit 1
fi

echo -e "${YELLOW}📋 Configuration:${NC}"
echo "  Domain: $DOMAIN"
echo "  Email: $EMAIL"
echo ""

# Check if Docker is installed
echo -e "${YELLOW}🐳 Checking Docker...${NC}"
if ! command -v docker &> /dev/null; then
    echo "Installing Docker..."
    # Install Docker Desktop for Mac
    echo -e "${RED}Please install Docker Desktop for Mac manually from https://www.docker.com/products/docker-desktop/${NC}"
    exit 1
else
    echo -e "${GREEN}✅ Docker is installed${NC}"
fi

# Create deployment directory
echo -e "${YELLOW}📁 Creating deployment directory...${NC}"
DEPLOY_DIR="$HOME/macadmin-deploy"
mkdir -p $DEPLOY_DIR
cd $DEPLOY_DIR

# Download latest docker-compose.prod.yml
echo -e "${YELLOW}⬇️  Downloading configuration files...${NC}"
curl -fsSL https://raw.githubusercontent.com/irfancode/MacAdmin/master/docker-compose.prod.yml -o docker-compose.yml

# Generate secrets
echo -e "${YELLOW}🔐 Generating secrets...${NC}"
SECRET_KEY=$(openssl rand -hex 32)
JWT_SECRET_KEY=$(openssl rand -hex 32)

# Create environment file
echo -e "${YELLOW}📝 Creating environment file...${NC}"
cat > .env <<EOF
# Application Secrets
SECRET_KEY=$SECRET_KEY
JWT_SECRET_KEY=$JWT_SECRET_KEY

# Domain
DOMAIN=$DOMAIN
EMAIL=$EMAIL
EOF

echo -e "${GREEN}✅ Environment file created${NC}"

# Update docker-compose.yml with domain
echo -e "${YELLOW}🔧 Configuring domain...${NC}"
sed -i "" "s/your-domain.com/$DOMAIN/g" docker-compose.yml
sed -i "" "s/admin@your-domain.com/$EMAIL/g" docker-compose.yml

# Create necessary directories
echo -e "${YELLOW}📂 Creating directories...${NC}"
mkdir -p letsencrypt

# Pull latest images
echo -e "${YELLOW}🐳 Pulling latest Docker images...${NC}"
docker-compose pull

# Start services
echo -e "${YELLOW}🚀 Starting services...${NC}"
docker-compose up -d

# Wait for services
echo -e "${YELLOW}⏳ Waiting for services to start...${NC}"
sleep 10

# Check if services are running
if docker-compose ps | grep -q "Up"; then
    echo -e "${GREEN}✅ Services are running${NC}"
else
    echo -e "${RED}❌ Some services failed to start${NC}"
    docker-compose logs
    exit 1
fi

# Display success message
echo ""
echo -e "${GREEN}🎉 MacAdmin has been successfully deployed!${NC}"
echo "============================================"
echo ""
echo -e "🌐 Access your application at:"
echo -e "   ${GREEN}https://$DOMAIN${NC}"
echo ""
echo -e "🔧 Management commands:"
echo -e "   View logs:     ${YELLOW}cd $DEPLOY_DIR && docker-compose logs -f${NC}"
echo -e "   Update:        ${YELLOW}cd $DEPLOY_DIR && docker-compose pull && docker-compose up -d${NC}"
echo -e "   Stop:          ${YELLOW}cd $DEPLOY_DIR && docker-compose down${NC}"
echo ""
echo -e "📚 Documentation: https://github.com/irfancode/MacAdmin/blob/master/docs/deployment.md"
echo ""
