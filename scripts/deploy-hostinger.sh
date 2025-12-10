#!/bin/bash

# =====================================================
# 🚀 Script de Despliegue para Hostinger VPS
# =====================================================
# Este script automatiza el despliegue de TeamTo-Do
# en un VPS de Hostinger con Docker y HTTPS
# =====================================================

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}"
echo "╔══════════════════════════════════════════════════╗"
echo "║     🚀 TeamTo-Do - Despliegue en Hostinger       ║"
echo "╚══════════════════════════════════════════════════╝"
echo -e "${NC}"

# Verificar que se ejecuta como root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}❌ Este script debe ejecutarse como root${NC}"
    echo "   Ejecuta: sudo ./scripts/deploy-hostinger.sh"
    exit 1
fi

# Verificar archivo de configuración
if [ ! -f ".env.production" ]; then
    echo -e "${RED}❌ No se encontró .env.production${NC}"
    echo "   Copia .env.production.example y configúralo"
    exit 1
fi

# Cargar variables
source .env.production

# Validar variables requeridas
if [ -z "$DOMAIN" ] || [ "$DOMAIN" = "tudominio.com" ]; then
    echo -e "${RED}❌ Configura tu dominio en .env.production${NC}"
    exit 1
fi

if [ -z "$CERTBOT_EMAIL" ] || [ "$CERTBOT_EMAIL" = "tu-email@ejemplo.com" ]; then
    echo -e "${RED}❌ Configura tu email en .env.production${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Configuración cargada${NC}"
echo "  Dominio: $DOMAIN"
echo "  Email: $CERTBOT_EMAIL"
echo ""

# =====================================================
# Paso 1: Instalar Docker si no está instalado
# =====================================================
echo -e "${YELLOW}📦 Paso 1: Verificando Docker...${NC}"

if ! command -v docker &> /dev/null; then
    echo "  Instalando Docker..."
    curl -fsSL https://get.docker.com | sh
    systemctl enable docker
    systemctl start docker
    echo -e "${GREEN}  ✓ Docker instalado${NC}"
else
    echo -e "${GREEN}  ✓ Docker ya está instalado${NC}"
fi

# =====================================================
# Paso 2: Configurar Firewall
# =====================================================
echo -e "${YELLOW}🔒 Paso 2: Configurando Firewall...${NC}"

if command -v ufw &> /dev/null; then
    ufw allow 22/tcp   # SSH
    ufw allow 80/tcp   # HTTP
    ufw allow 443/tcp  # HTTPS
    ufw --force enable
    echo -e "${GREEN}  ✓ Firewall configurado (puertos 22, 80, 443)${NC}"
else
    echo -e "${YELLOW}  ⚠ UFW no instalado, configura el firewall manualmente${NC}"
fi

# =====================================================
# Paso 3: Crear configuración de Nginx
# =====================================================
echo -e "${YELLOW}⚙️ Paso 3: Configurando Nginx...${NC}"

# Crear directorios
mkdir -p nginx/conf.d
mkdir -p certbot/conf
mkdir -p certbot/www

# Crear configuración temporal para obtener certificado
cat > nginx/conf.d/default.conf << EOF
server {
    listen 80;
    server_name $DOMAIN www.$DOMAIN;

    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }

    location / {
        return 200 'TeamTo-Do está configurándose...';
        add_header Content-Type text/plain;
    }
}
EOF

echo -e "${GREEN}  ✓ Configuración Nginx creada${NC}"

# =====================================================
# Paso 4: Iniciar Nginx temporalmente
# =====================================================
echo -e "${YELLOW}🌐 Paso 4: Iniciando Nginx para certificado SSL...${NC}"

# Iniciar solo nginx-proxy temporalmente
docker compose -f docker-compose.prod.yml up -d nginx-proxy

sleep 5
echo -e "${GREEN}  ✓ Nginx iniciado${NC}"

# =====================================================
# Paso 5: Obtener certificado SSL
# =====================================================
echo -e "${YELLOW}🔐 Paso 5: Obteniendo certificado SSL de Let's Encrypt...${NC}"

docker run --rm \
    -v $(pwd)/certbot/conf:/etc/letsencrypt \
    -v $(pwd)/certbot/www:/var/www/certbot \
    certbot/certbot certonly \
    --webroot \
    --webroot-path=/var/www/certbot \
    --email $CERTBOT_EMAIL \
    --agree-tos \
    --no-eff-email \
    -d $DOMAIN \
    -d www.$DOMAIN

if [ $? -eq 0 ]; then
    echo -e "${GREEN}  ✓ Certificado SSL obtenido${NC}"
else
    echo -e "${RED}  ❌ Error obteniendo certificado. Verifica que tu dominio apunta a este servidor.${NC}"
    exit 1
fi

# =====================================================
# Paso 6: Configurar Nginx con SSL
# =====================================================
echo -e "${YELLOW}⚙️ Paso 6: Configurando Nginx con SSL...${NC}"

cat > nginx/conf.d/default.conf << EOF
# Redirigir HTTP a HTTPS
server {
    listen 80;
    server_name $DOMAIN www.$DOMAIN;

    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }

    location / {
        return 301 https://\$host\$request_uri;
    }
}

# HTTPS Server
server {
    listen 443 ssl http2;
    server_name $DOMAIN www.$DOMAIN;

    ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;

    ssl_session_timeout 1d;
    ssl_session_cache shared:SSL:50m;
    ssl_session_tickets off;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;
    add_header Strict-Transport-Security "max-age=63072000" always;

    location / {
        proxy_pass http://frontend:80;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
    }

    location /api/ {
        proxy_pass http://backend:3000/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
        proxy_read_timeout 300s;
        proxy_connect_timeout 75s;
    }
}
EOF

echo -e "${GREEN}  ✓ Nginx configurado con SSL${NC}"

# =====================================================
# Paso 7: Desplegar aplicación completa
# =====================================================
echo -e "${YELLOW}🚀 Paso 7: Desplegando aplicación...${NC}"

# Detener nginx temporal
docker compose -f docker-compose.prod.yml down

# Construir e iniciar todo
docker compose -f docker-compose.prod.yml up -d --build

echo -e "${GREEN}  ✓ Aplicación desplegada${NC}"

# =====================================================
# Paso 8: Verificar estado
# =====================================================
echo -e "${YELLOW}🔍 Paso 8: Verificando estado...${NC}"

sleep 10

docker compose -f docker-compose.prod.yml ps

echo ""
echo -e "${GREEN}"
echo "╔══════════════════════════════════════════════════╗"
echo "║          ✅ ¡DESPLIEGUE COMPLETADO!              ║"
echo "╠══════════════════════════════════════════════════╣"
echo "║                                                  ║"
echo "║  🌐 Tu aplicación está disponible en:            ║"
echo "║     https://$DOMAIN"
echo "║                                                  ║"
echo "║  📋 Comandos útiles:                             ║"
echo "║     docker compose -f docker-compose.prod.yml ps ║"
echo "║     docker compose -f docker-compose.prod.yml logs -f"
echo "║                                                  ║"
echo "╚══════════════════════════════════════════════════╝"
echo -e "${NC}"

# =====================================================
# Configurar renovación automática de certificados
# =====================================================
echo -e "${YELLOW}🔄 Configurando renovación automática de certificados...${NC}"

# Crear cron job para renovar certificados
(crontab -l 2>/dev/null; echo "0 12 * * * cd $(pwd) && docker compose -f docker-compose.prod.yml run --rm certbot renew && docker compose -f docker-compose.prod.yml exec nginx-proxy nginx -s reload") | crontab -

echo -e "${GREEN}  ✓ Renovación automática configurada (cada día a las 12:00)${NC}"
