# 📋 Team To-Do

Aplicación web colaborativa para gestionar tareas en equipo con autenticación de usuarios y filtrado en tiempo real.

## 🚀 Demo en Vivo

- **Frontend**: https://tdolistreact.netlify.app
- **Backend API**: https://teamto-do-1.onrender.com

## ✨ Características Principales

- ✅ **Gestión de Tareas**: Crear, editar, marcar como completadas y eliminar tareas
- 👥 **Multiusuario**: Sistema completo de registro e inicio de sesión
- 🔍 **Búsqueda Inteligente**: Busca tareas por texto o autor con debounce
- 🎯 **Filtros**: Visualiza todas, pendientes o completadas
- 🔒 **Seguridad**: Validación de contraseñas (min 8 caracteres, mayúsculas, minúsculas y caracteres especiales)
- 🎨 **Diseño Moderno**: Interfaz colorida y responsive con gradientes cálidos
- 📱 **Responsive**: Funciona perfectamente en desktop, tablet y móvil

## 🛠️ Tecnologías

### Frontend

- React 18
- React Router DOM
- Tailwind CSS
- Axios
- React Toastify
- Vite

### Backend

- NestJS
- Prisma ORM
- MySQL
- JWT para autenticación
- bcrypt para encriptación

### Despliegue

- Frontend: Netlify
- Backend: Render
- Base de Datos: Railway (MySQL)
- **Docker**: Contenedores para desarrollo y producción

## 🐳 Despliegue con Docker

### Requisitos Previos

- Docker 20.10+
- Docker Compose 2.0+

### Inicio Rápido

1. **Clonar el repositorio**:

```bash
git clone https://github.com/tu-usuario/team-todo.git
cd team-todo
```

2. **Configurar variables de entorno** (opcional):

```bash
cp .env.example .env
# Editar .env si es necesario
```

3. **Iniciar todos los servicios**:

```bash
docker compose up -d
```

4. **Acceder a la aplicación**:
   - 🌐 **Frontend**: http://localhost
   - 🔧 **Backend API**: http://localhost:3000
   - 🗄️ **MySQL**: localhost:3306

### Comandos Útiles

```bash
# Ver logs en tiempo real
docker compose logs -f

# Ver logs de un servicio específico
docker compose logs -f backend
docker compose logs -f frontend
docker compose logs -f mysql

# Detener todos los servicios
docker compose down

# Detener y eliminar volúmenes (¡borra datos!)
docker compose down -v

# Reconstruir imágenes
docker compose build

# Reconstruir y reiniciar
docker compose up -d --build

# Ver estado de los contenedores
docker compose ps

# Ejecutar comandos en un contenedor
docker compose exec backend sh
docker compose exec mysql mysql -u teamtodo -p
```

### Configuración de Puertos

Por defecto los servicios usan estos puertos:

| Servicio         | Puerto |
| ---------------- | ------ |
| Frontend (Nginx) | 80     |
| Backend (NestJS) | 3000   |
| MySQL            | 3306   |

Para cambiar los puertos, edita el archivo `.env`:

```env
FRONTEND_PORT=8080
BACKEND_PORT=3001
MYSQL_PORT=3307
```

### Variables de Entorno

Copia `.env.example` a `.env` y configura según tu entorno:

```env
# MySQL
MYSQL_ROOT_PASSWORD=rootpassword
MYSQL_DATABASE=teamtodo
MYSQL_USER=teamtodo
MYSQL_PASSWORD=teamtodo123

# Backend
FRONTEND_URL=http://localhost
FRONTEND_URLS=http://localhost,http://localhost:80

# Puertos (opcional)
FRONTEND_PORT=80
BACKEND_PORT=3000
MYSQL_PORT=3306
```

### Arquitectura Docker

```
┌─────────────────────────────────────────────────────┐
│                    Docker Network                    │
│                   teamtodo-network                   │
│                                                      │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  │
│  │   Frontend  │  │   Backend   │  │    MySQL    │  │
│  │   (Nginx)   │─▶│   (NestJS)  │─▶│   (8.0)     │  │
│  │   :80       │  │   :3000     │  │   :3306     │  │
│  └─────────────┘  └─────────────┘  └─────────────┘  │
│         │                                   │        │
│         │ /api/* proxy                      │        │
│         └───────────────────────────────────┘        │
└─────────────────────────────────────────────────────┘
```

### Producción con Docker

Para despliegue en producción, considera:

1. **Usar imágenes específicas de versión**:

```yaml
services:
  mysql:
    image: mysql:8.0.35
```

2. **Configurar SSL/TLS** en nginx para HTTPS

3. **Usar secrets de Docker** para credenciales:

```bash
echo "password" | docker secret create mysql_password -
```

4. **Configurar backups automáticos** para MySQL:

```bash
docker compose exec mysql mysqldump -u root -p teamtodo > backup.sql
```

---

## 📦 Instalación Local

### Requisitos Previos

- Node.js 18+
- npm o yarn
- MySQL

### 1. Clonar el Repositorio

```bash
git clone https://github.com/tu-usuario/team-todo.git
cd team-todo
```

### 2. Configurar Frontend

```bash
cd frontend
npm install
```

Crear archivo `.env`:

```env
VITE_API_URL=http://localhost:3000
```

Iniciar en modo desarrollo:

```bash
npm run dev
```

El frontend estará en `http://localhost:5173`

### 3. Configurar Backend

```bash
cd backend
npm install
```

Crear archivo `.env`:

```env
DATABASE_URL="mysql://root:password@localhost:3306/teamtodo"
FRONTEND_URL="http://localhost:5173"
PORT=3000
```

Generar Prisma Client y migrar la base de datos:

```bash
npx prisma generate
npx prisma migrate dev
```

Iniciar en modo desarrollo:

```bash
npm run start:dev
```

El backend estará en `http://localhost:3000`

## 📁 Estructura del Proyecto

```
team-todo/
├── frontend/
│   ├── src/
│   │   ├── components/       # Componentes reutilizables
│   │   ├── pages/            # Páginas (Home, Login, Register)
│   │   ├── context/          # AuthContext
│   │   ├── hooks/            # useDebounce
│   │   └── App.jsx
│   └── package.json
│
└── backend/
    ├── src/
    │   ├── auth/             # Autenticación
    │   ├── todos/            # Gestión de tareas
    │   ├── users/            # Gestión de usuarios
    │   └── main.ts
    ├── prisma/
    │   └── schema.prisma     # Esquema de BD
    └── package.json
```

## 🔐 Requisitos de Contraseña

Para registrarse, la contraseña debe cumplir:

- ✅ Mínimo 8 caracteres
- ✅ Al menos una letra mayúscula (A-Z)
- ✅ Al menos una letra minúscula (a-z)
- ✅ Al menos un carácter especial (!@#$%^&\*...)

## 📡 API Endpoints

### Autenticación

- `POST /auth/register` - Registrar nuevo usuario
- `POST /auth/login` - Iniciar sesión

### Tareas

- `GET /todos` - Obtener todas las tareas
- `POST /todos` - Crear nueva tarea
- `PATCH /todos/:id` - Actualizar tarea
- `DELETE /todos/:id` - Eliminar tarea

### Usuarios

- `GET /users` - Listar todos los usuarios

## 🚀 Despliegue en Producción

### Opción 1: Docker (Recomendado)

Para desplegar con Docker en un servidor:

```bash
# En el servidor
git clone https://github.com/tu-usuario/team-todo.git
cd team-todo

# Configurar variables de entorno
cp .env.example .env
nano .env  # Cambiar contraseñas y configuración

# Iniciar en modo producción
docker compose up -d

# Verificar que todo funcione
docker compose ps
docker compose logs -f
```

### Opción 2: Servicios Cloud (Netlify + Render + Railway)

#### Frontend (Netlify)

1. Conecta tu repositorio
2. Build command: `npm run build`
3. Publish directory: `dist`
4. Agregar variable: `VITE_API_URL=https://tu-backend.onrender.com`

#### Backend (Render)

1. Conecta tu repositorio
2. Build command: `npm install && npx prisma generate`
3. Start command: `npm run start:prod`
4. Agregar variables de entorno:
   - `DATABASE_URL` (URL pública de Railway)
   - `FRONTEND_URL` (URL de Netlify)

#### Base de Datos (Railway)

1. Crear proyecto MySQL
2. Copiar la URL pública de conexión
3. Usarla en `DATABASE_URL`

## 🐛 Solución de Problemas

### Docker

**El backend no puede conectarse a MySQL**:

```bash
# Verificar que MySQL esté healthy
docker compose ps

# Ver logs de MySQL
docker compose logs mysql

# Reiniciar el backend después de que MySQL esté listo
docker compose restart backend
```

**Puertos ocupados**:

```bash
# Cambiar puertos en .env
FRONTEND_PORT=8080
BACKEND_PORT=3001
```

**Limpiar todo y empezar de nuevo**:

```bash
docker compose down -v
docker system prune -a
docker compose up -d --build
```

### Error de CORS

Asegúrate de que `FRONTEND_URL` en Render incluya tu dominio de Netlify sin `/` al final.

### Error de Base de Datos

Usa la URL **pública** de Railway (con `shuttle.proxy.rlwy.net`), no la interna (`mysql.railway.internal`).

### Problemas de Login/Registro

Verifica que el backend esté corriendo y que las variables de entorno estén correctamente configuradas.

## 👤 Autor

Michelle Garcia Jehimy Hernandez
