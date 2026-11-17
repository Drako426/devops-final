# Proyecto Final DevOps - API de Tareas (estudiante35)

Despliegue contenedorizado de una API REST en Python (Flask) conectada a una base de datos PostgreSQL privada, integrando controles de seguridad DevSecOps y monitoreo automatizado.

- **Estudiante:** Juan Pablo Correa Gutiérrez (`estudiante35`)
- **Servidor:** `178.128.14.98`
- **Endpoint público:** `http://178.128.14.98:8035/health`

## Comandos ejecutados en orden

### 1. Conexión SSH y preparación del repositorio
```bash
ssh estudiante35@178.128.14.98
git clone https://github.com/Drako426/devops-final
cd devops-final
git remote set-url origin  https://github.com/Drako426/devops-final
git config user.name "Juan Pablo Correa"
git config user.email "pablo.correa@utp.edu.co"
```

### 2. Configuración de variables de entorno y Docker Compose
```bash
# Creación del archivo .env con ESTUDIANTE=estudiante35, API_PORT=8035 y credenciales DB
# Creación de docker-compose.yml con name: estudiante35, est35_db y est35_api
docker compose up -d --build
docker compose ps
```

### 3. Verificación de la API
```bash
curl http://localhost:8035/health
curl -X POST http://localhost:8035/tareas -H "Content-Type: application/json" -d '{"titulo":"Primera tarea"}'
curl http://localhost:8035/tareas
```

### 4. Ejecución de DevSecOps y Monitoreo
```bash
chmod +x seguridad.sh
./seguridad.sh
ls -la reportes/
cat monitoreo.log
```
