#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

clear
echo ""
echo "=========================================="
echo "  🎬 N8N Video Generator - Setup"
echo "=========================================="
echo ""

# Check Docker
echo -n "Checking Docker... "
if ! command -v docker &> /dev/null; then
    echo -e "${RED}✗${NC}"
    echo "Error: Docker not found"
    echo "Install: https://docs.docker.com/get-docker/"
    exit 1
fi
echo -e "${GREEN}✓${NC}"

# Check Docker Compose
echo -n "Checking Docker Compose... "
if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}✗${NC}"
    echo "Error: Docker Compose not found"
    exit 1
fi
echo -e "${GREEN}✓${NC}"

echo ""

# Create .env if not exists
if [ ! -f .env ]; then
    echo -e "${YELLOW}Creating .env file...${NC}"
    cp .env.example .env
    echo -e "${GREEN}✓${NC} .env created"
    echo ""
    echo -e "${RED}⚠️  IMPORTANTE: Configure suas API keys no .env!${NC}"
    echo ""
    echo "Abra o arquivo .env e configure:"
    echo "  - GOOGLE_GEMINI_API_KEY"
    echo "  - BASEROW_API_KEY"
    echo "  - N8N_ENCRYPTION_KEY (gere uma chave aleatória)"
    echo ""
    read -p "Pressione Enter após editar .env..."
    echo ""
else
    echo -e "${GREEN}✓${NC} .env já existe"
fi

# Validate required keys
echo "Validating configuration..."

if ! grep -q "^GOOGLE_GEMINI_API_KEY=" .env || grep -q "your-google-gemini-api-key-here" .env; then
    echo -e "${RED}✗ Configure GOOGLE_GEMINI_API_KEY no .env${NC}"
    exit 1
fi
echo -e "${GREEN}✓${NC} Gemini API key configurada"

if ! grep -q "^BASEROW_API_KEY=" .env || grep -q "your-baserow-token-here" .env; then
    echo -e "${RED}✗ Configure BASEROW_API_KEY no .env${NC}"
    exit 1
fi
echo -e "${GREEN}✓${NC} Baserow API key configurada"

if ! grep -q "^N8N_ENCRYPTION_KEY=" .env || grep -q "change-this" .env; then
    echo -e "${YELLOW}⚠${NC}  N8N_ENCRYPTION_KEY não foi alterada"
    echo "Recomendamos usar uma chave aleatória forte"
fi

echo ""

# Create keys.env from .env (para config-server)
echo -e "${BLUE}Creating keys.env for config-server...${NC}"
cp .env keys.env
echo -e "${GREEN}✓${NC} keys.env created"
echo -e "${YELLOW}ℹ${NC}  Este arquivo será montado em /files/keys.env no container"
echo ""

# Create directories
echo "Creating directories..."
mkdir -p workflows docs
echo -e "${GREEN}✓${NC} Directories created"
echo ""

# Pull latest image
echo -e "${BLUE}Pulling n8n image...${NC}"
docker-compose pull

if [ $? -ne 0 ]; then
    echo -e "${RED}✗ Failed to pull image${NC}"
    exit 1
fi

echo ""

# Start containers
echo -e "${BLUE}Starting containers...${NC}"
docker-compose up -d

if [ $? -ne 0 ]; then
    echo -e "${RED}✗ Failed to start containers${NC}"
    echo "Check logs: docker-compose logs"
    exit 1
fi

echo ""
echo -e "${YELLOW}Waiting for n8n to initialize...${NC}"

# Wait for healthcheck
for i in {1..30}; do
    if docker exec n8n-video-generator curl -sf http://localhost:5678/healthz > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} n8n is ready!"
        break
    fi
    echo -n "."
    sleep 2
done

echo ""

# Verify keys.env in container
echo -n "Verifying keys.env in container... "
if docker exec n8n-video-generator test -f /files/keys.env; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
    echo "Warning: keys.env not accessible in container"
fi

echo ""

# Check if running
if docker-compose ps | grep -q "Up"; then
    echo ""
    echo "=========================================="
    echo -e "${GREEN}  ✅ Setup Completo!${NC}"
    echo "=========================================="
    echo ""
    echo "📍 Acesse n8n: http://localhost:5678"
    echo ""
    echo "📋 Próximos passos:"
    echo ""
    echo "1. Acesse n8n e crie sua conta admin"
    echo ""
    echo "2. Configure credenciais:"
    echo "   Settings > Credentials > Add Credential"
    echo "   - Google Gemini (PaLM) API"
    echo "   - Baserow API"
    echo ""
    echo "3. Importe workflows da pasta ./workflows/"
    echo "   (na ordem: config-server, create-video, extract-frame,"
    echo "    video-monitor, veo3)"
    echo ""
    echo "4. Configure Baserow:"
    echo "   Siga: docs/BASEROW_SETUP.md"
    echo ""
    echo "5. Atualize IDs do Baserow nos workflows:"
    echo "   ./update-baserow-ids.sh"
    echo ""
    echo "6. Teste o config-server:"
    echo "   curl http://localhost:5678/webhook/config"
    echo ""
    echo "7. Ative todos os workflows (toggle verde)"
    echo ""
    echo "8. Teste o sistema completo!"
    echo ""
    echo "📚 Documentação: README.md"
    echo "🐛 Troubleshooting: docs/TROUBLESHOOTING.md"
    echo ""
else
    echo -e "${RED}✗ Erro ao iniciar containers${NC}"
    echo "Verifique os logs: docker-compose logs"
    exit 1
fi