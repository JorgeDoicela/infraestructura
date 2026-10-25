# 04 — Entorno de Desarrollo Local para Equipos

[Volver al Índice General](00-indice-general.md) | [Anterior: Configuración con Ansible](03-gestion-configuracion-ansible.md) | [Siguiente: Cargas de Trabajo y Edge](05-cargas-de-trabajo-y-edge.md)

---

## 1. Propósito y Filosofía de la Pila Local

El objetivo de [`workloads/work/local/`](../workloads/work/local/) es proporcionar a cualquier desarrollador del equipo de trabajo una infraestructura de soporte idéntica a la utilizada en staging y producción con **cero fricción de instalación**.

* **Sin instalaciones de sistema:** No se instalan servicios de PostgreSQL, Redis o RabbitMQ directamente sobre el sistema operativo del programador.
* **Hermetismo:** Todos los servicios corren en contenedores Docker conectados a una red interna bridge (`local_dev_network`).
* **Multiplataforma:** Opera con idéntico comportamiento en Linux, macOS y Windows (vía WSL2 o Docker Desktop).

---

## 2. Catálogo de Servicios y Puertos Expuestos

| Servicio | Imagen Docker | Puerto Local | Credenciales por Defecto | Propósito Técnico |
|---|---|---|---|---|
| **PostgreSQL 16** | `postgres:16-alpine` | `localhost:5432` | User: `postgres`<br>Pass: `postgres_dev_password`<br>DB: `app_dev` | Base de datos relacional principal con extensiones UUID y PGCRYPTO habilitadas. |
| **Redis 7** | `redis:7-alpine` | `localhost:6379` | Sin autenticación local | Servidor en memoria para caché, sesiones y pub/sub. |
| **RabbitMQ 3** | `rabbitmq:3-management-alpine` | `localhost:5672`<br>`localhost:15672` | User: `guest`<br>Pass: `guest` | Cola de mensajes asíncrona. Puerto `15672` expone la consola web de administración. |
| **MinIO (S3)** | `minio/minio:RELEASE...` | `localhost:9000`<br>`localhost:9001` | User: `minioadmin`<br>Pass: `minioadmin` | Emulador compatible con AWS S3 para almacenamiento de archivos. Puerto `9001` expone la consola web. |
| **Mailpit** | `axllent/mailpit:v1.18` | `localhost:1025`<br>`localhost:8025` | Sin autenticación | Mock de servidor SMTP. Intercepta todos los correos enviados y los visualiza en la interfaz web (`:8025`). |

---

## 3. Inicialización Automática de Base de Datos (`init-scripts/`)

El archivo [`workloads/work/local/init-scripts/01-init-db.sql`](../workloads/work/local/init-scripts/01-init-db.sql) es montado en el punto de entrada de PostgreSQL (`/docker-entrypoint-initdb.d/`).

Al iniciar el contenedor por primera vez con un volumen limpio:
1. Activa la extensión `uuid-ossp` para generación de identificadores UUID v4.
2. Activa la extensión `pgcrypto` para funciones criptográficas nativas.
3. Crea el esquema `core`.

---

## 4. Guía de Operación con Makefile

El desarrollador no requiere memorizar parámetros de Docker Compose. Todo el ciclo de vida se controla mediante [`Makefile`](../workloads/work/local/Makefile):

```bash
cd workloads/work/local

# 1. Iniciar toda la infraestructura en segundo plano
# (Copia automaticamente .env.example a .env si este no existe)
make dev-up

# 2. Consultar el estado de salud de los contenedores
make dev-ps

# 3. Seguir los logs de todos los servicios en tiempo real
make dev-logs

# 4. Detener los servicios preservando los datos
make dev-down

# 5. Reiniciar los servicios
make dev-restart

# 6. Restablecer la base de datos a cero (ELIMINA VOLUMENES)
make dev-clean
```

---

## 5. Configuración de Cadenas de Conexión en Aplicaciones

Para conectar aplicaciones locales (Node.js, .NET, Python, Go) a la pila de desarrollo, inyectar las siguientes variables en el archivo `.env` de la aplicación:

### PostgreSQL
```env
DATABASE_URL="postgresql://postgres:postgres_dev_password@localhost:5432/app_dev?schema=core"
```

### Redis
```env
REDIS_URL="redis://localhost:6379"
```

### RabbitMQ
```env
RABBITMQ_URL="amqp://guest:guest@localhost:5672/"
```

### MinIO (S3)
```env
AWS_ACCESS_KEY_ID="minioadmin"
AWS_SECRET_ACCESS_KEY="minioadmin"
AWS_ENDPOINT_URL="http://localhost:9000"
AWS_REGION="us-east-1"
AWS_S3_FORCE_PATH_STYLE="true"
```

### Mailpit (SMTP)
```env
SMTP_HOST="localhost"
SMTP_PORT=1025
SMTP_SECURE="false"
```

---

## 6. Resolución de Problemas Comunes

1. **Error: `bind: address already in use` (Puerto ocupado):**
   * Ocurre si el desarrollador tiene un servicio nativo de PostgreSQL o Redis ejecutándose en el host.
   * **Solución:** Detener el servicio nativo (`sudo systemctl stop postgresql`) o cambiar el puerto en `.env` (ej. `POSTGRES_PORT=5433`).
2. **La base de datos no ejecuta los scripts de inicialización:**
   * Los scripts de `/docker-entrypoint-initdb.d/` solo corren cuando el directorio de datos de Postgres está vacío.
   * **Solución:** Ejecutar `make dev-clean` y luego `make dev-up` para regenerar el volumen.
