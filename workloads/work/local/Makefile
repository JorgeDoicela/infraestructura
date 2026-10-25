.PHONY: dev-up dev-down dev-restart dev-logs dev-ps dev-clean help

COMPOSE_FILE := docker-compose.local.yml

help:
	@echo "Comandos disponibles para la pila de desarrollo local:"
	@echo "  make dev-up       - Inicia todos los servicios de soporte en segundo plano"
	@echo "  make dev-down     - Detiene los servicios sin eliminar los volumenes de datos"
	@echo "  make dev-restart  - Reinicia los servicios de desarrollo"
	@echo "  make dev-logs     - Muestra y sigue los logs en tiempo real"
	@echo "  make dev-ps       - Muestra el estado y los puertos de los contenedores"
	@echo "  make dev-clean    - DETIENE y ELIMINA todos los contenedores y volumenes de datos"

dev-up:
	@if [ ! -f .env ]; then cp .env.example .env && echo "Archivo .env generado a partir de .env.example"; fi
	docker compose -f $(COMPOSE_FILE) up -d

dev-down:
	docker compose -f $(COMPOSE_FILE) down

dev-restart:
	docker compose -f $(COMPOSE_FILE) restart

dev-logs:
	docker compose -f $(COMPOSE_FILE) logs -f

dev-ps:
	docker compose -f $(COMPOSE_FILE) ps

dev-clean:
	docker compose -f $(COMPOSE_FILE) down -v
