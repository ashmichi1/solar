# 🚀 Guía de Despliegue en Hostinger VPS

Esta guía te ayudará a desplegar TeamTo-Do en un VPS de Hostinger con Docker y HTTPS gratuito.

## 📋 Requisitos Previos

1. **VPS de Hostinger** con Ubuntu 20.04+ o Debian 11+
2. **Dominio** configurado apuntando a la IP del VPS
3. **Acceso SSH** al servidor

## 🔧 Preparación del Dominio

Antes de empezar, configura los registros DNS de tu dominio:

| Tipo | Nombre | Valor          |
| ---- | ------ | -------------- |
| A    | @      | `IP_DE_TU_VPS` |
| A    | www    | `IP_DE_TU_VPS` |

> ⏳ Los cambios DNS pueden tardar hasta 24 horas en propagarse.

## 🚀 Despliegue Automático (Recomendado)

### Paso 1: Conectarse al VPS

```bash
ssh root@tu-ip-del-vps
```

### Paso 2: Clonar el repositorio

```bash
git clone https://github.com/Leonidas670/TeamTo-Do.git
cd TeamTo-Do
```

### Paso 3: Configurar variables de entorno

```bash
# Editar configuración de producción
nano .env.production
```

Configura estos valores:

```env
# Tu dominio (sin https://)
DOMAIN=tudominio.com

# Contraseñas seguras para MySQL
MYSQL_ROOT_PASSWORD=ContraseñaMuySegura123!
MYSQL_PASSWORD=OtraContraseñaSegura456!

# Tu email para Let's Encrypt
CERTBOT_EMAIL=tu-email@ejemplo.com
```

### Paso 4: Ejecutar script de despliegue

```bash
chmod +x scripts/deploy-hostinger.sh
sudo ./scripts/deploy-hostinger.sh
```

El script automáticamente:

- ✅ Instala Docker
- ✅ Configura el Firewall
- ✅ Obtiene certificado SSL de Let's Encrypt
- ✅ Despliega la aplicación
- ✅ Configura renovación automática de certificados

## 🔧 Despliegue Manual

Si prefieres hacerlo paso a paso:

### 1. Instalar Docker

```bash
curl -fsSL https://get.docker.com | sh
systemctl enable docker
systemctl start docker
```

### 2. Configurar Firewall

```bash
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw enable
```

### 3. Clonar y configurar

```bash
git clone https://github.com/Leonidas670/TeamTo-Do.git
cd TeamTo-Do
cp .env.production.example .env.production
nano .env.production
```

### 4. Crear directorios necesarios

```bash
mkdir -p nginx/conf.d certbot/conf certbot/www
```

### 5. Obtener certificado SSL

```bash
# Primero, crear configuración temporal de nginx
cat > nginx/conf.d/default.conf << 'EOF'
server {
    listen 80;
    server_name tudominio.com www.tudominio.com;
    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }
    location / {
        return 200 'Configurando...';
    }
}
EOF

# Iniciar nginx
docker compose -f docker-compose.prod.yml up -d nginx-proxy

# Obtener certificado
docker run --rm \
    -v $(pwd)/certbot/conf:/etc/letsencrypt \
    -v $(pwd)/certbot/www:/var/www/certbot \
    certbot/certbot certonly \
    --webroot \
    --webroot-path=/var/www/certbot \
    --email tu-email@ejemplo.com \
    --agree-tos \
    --no-eff-email \
    -d tudominio.com \
    -d www.tudominio.com
```

### 6. Configurar Nginx con SSL

Actualiza `nginx/conf.d/default.conf` con la configuración HTTPS (el script lo hace automáticamente).

### 7. Desplegar

```bash
docker compose -f docker-compose.prod.yml down
docker compose -f docker-compose.prod.yml up -d --build
```

## 📋 Comandos Útiles

```bash
# Ver estado de los contenedores
docker compose -f docker-compose.prod.yml ps

# Ver logs en tiempo real
docker compose -f docker-compose.prod.yml logs -f

# Ver logs de un servicio específico
docker compose -f docker-compose.prod.yml logs -f backend

# Reiniciar un servicio
docker compose -f docker-compose.prod.yml restart backend

# Detener todo
docker compose -f docker-compose.prod.yml down

# Actualizar la aplicación
git pull
docker compose -f docker-compose.prod.yml up -d --build

# Backup de la base de datos
docker compose -f docker-compose.prod.yml exec mysql mysqldump -u root -p teamtodo > backup_$(date +%Y%m%d).sql

# Restaurar backup
docker compose -f docker-compose.prod.yml exec -T mysql mysql -u root -p teamtodo < backup.sql
```

## 🔒 Seguridad

### Cambiar contraseñas

Asegúrate de usar contraseñas seguras en `.env.production`:

```env
MYSQL_ROOT_PASSWORD=ContraseñaMuySegura123!@#
MYSQL_PASSWORD=OtraContraseñaSegura456!@#
```

### Renovar certificados SSL

Los certificados se renuevan automáticamente. Para renovar manualmente:

```bash
docker compose -f docker-compose.prod.yml run --rm certbot renew
docker compose -f docker-compose.prod.yml exec nginx-proxy nginx -s reload
```

### Actualizar la aplicación

```bash
cd TeamTo-Do
git pull origin master
docker compose -f docker-compose.prod.yml up -d --build
```

## 🐛 Solución de Problemas

### El sitio no carga

```bash
# Verificar que los contenedores estén corriendo
docker compose -f docker-compose.prod.yml ps

# Ver logs
docker compose -f docker-compose.prod.yml logs
```

### Error de certificado SSL

```bash
# Verificar que el dominio apunta correctamente
dig tudominio.com

# Regenerar certificado
docker run --rm \
    -v $(pwd)/certbot/conf:/etc/letsencrypt \
    -v $(pwd)/certbot/www:/var/www/certbot \
    certbot/certbot certonly --force-renewal \
    --webroot --webroot-path=/var/www/certbot \
    -d tudominio.com -d www.tudominio.com
```

### MySQL no inicia

```bash
# Ver logs de MySQL
docker compose -f docker-compose.prod.yml logs mysql

# Reiniciar MySQL
docker compose -f docker-compose.prod.yml restart mysql
```

### Backend no conecta a MySQL

```bash
# Esperar a que MySQL esté listo
docker compose -f docker-compose.prod.yml restart backend
```

## 📊 Monitoreo

### Ver uso de recursos

```bash
docker stats
```

### Ver espacio en disco

```bash
docker system df
```

### Limpiar recursos no usados

```bash
docker system prune -a
```

## 🔗 URLs

Una vez desplegado, tu aplicación estará disponible en:

- **Frontend**: `https://tudominio.com`
- **API**: `https://tudominio.com/api`

---

## 📞 Soporte

Si tienes problemas:

1. Revisa los logs: `docker compose -f docker-compose.prod.yml logs -f`
2. Verifica el estado: `docker compose -f docker-compose.prod.yml ps`
3. Asegúrate de que el dominio apunta correctamente al VPS
