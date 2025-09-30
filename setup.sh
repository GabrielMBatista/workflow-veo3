#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo ""
echo "=========================================="
echo "  N8N Video Generator - Setup"
echo "=========================================="
echo ""

# Check Docker
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Error: Docker not found${NC}"
    echo "Install Docker: https://docs.docker.com/get-docker/"
    exit 1
fi
echo -e "${GREEN}✓${NC} Docker found"

# Check Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}Error: Docker Compose not found${NC}"
    exit 1
fi
echo -e "${GREEN}✓${NC} Docker Compose found"

# Create .env if not exists
if [ ! -f .env ]; then
    echo -e "${YELLOW}Creating .env file...${NC}"
    cp .env.example .env
    echo -e "${GREEN}✓${NC} .env created"
    echo ""
    echo -e "${YELLOW}⚠️  IMPORTANT: Edit .env with your API keys!${NC}"
    echo ""
    read -p "Press Enter after editing .env..."
else
    echo -e "${GREEN}✓${NC} .env already exists"
fi

# Check required variables
if grep -q "your_gemini_api_key_here" .env; then
    echo -e "${RED}Error: Configure GOOGLE_GEMINI_API_KEY in .env${NC}"
    exit 1
fi

if grep -q "your_baserow_token_here" .env; then
    echo -e "${RED}Error: Configure BASEROW_API_KEY in .env${NC}"
    exit 1
fi

echo -e "${GREEN}✓${NC} Environment variables configured"

# Create keys.env from .env
echo -e "${YELLOW}Creating keys.env...${NC}"
cp .env keys.env
echo -e "${GREEN}✓${NC} keys.env created"

# Create necessary directories
mkdir -p workflows docs

# Pull latest n8n image
echo ""
echo -e "${BLUE}Pulling n8n image...${NC}"
docker-compose pull

# Start containers
echo ""
echo -e "${BLUE}Starting containers...${NC}"
docker-compose up -d

# Wait for n8n to be ready
echo ""
echo -e "${YELLOW}Waiting for n8n to start...${NC}"
sleep 15

# Check if running
if docker-compose ps | grep -q "Up"; then
    echo ""
    echo "=========================================="
    echo -e "${GREEN}  Setup Complete!${NC}"
    echo "=========================================="
    echo ""
    echo "Next steps:"
    echo ""
    echo "1. Access n8n:"
    echo "   http://localhost:5678"
    echo ""
    echo "2. Create your admin account"
    echo ""
    echo "3. Configure credentials:"
    echo "   - Google Gemini API"
    echo "   - Baserow API"
    echo ""
    echo "4. Import workflows from /workflows folder"
    echo ""
    echo "5. Update Baserow IDs:"
    echo "   ./update-baserow-ids.sh"
    echo ""
    echo "6. Activate all workflows"
    echo ""
    echo "Documentation: README.md"
    echo ""
else
    echo -e "${RED}Error starting containers${NC}"
    echo "Check logs: docker-compose logs"
    exit 1
fi