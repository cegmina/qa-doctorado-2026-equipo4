# Makefile — Restful Booker SUT control
# Uso:
#   make up
#   make health
#   make down

SHELL := /bin/bash

RUN_SCRIPT := ./run_sut.sh
STOP_SCRIPT := ./stop_sut.sh
HEALTH_SCRIPT := ./healthcheck_sut.sh

.PHONY: help up down health restart status logs perm

help:
	@echo "Objetivos disponibles:"
	@echo "  make up        Inicia el SUT"
	@echo "  make health    Verifica la salud del SUT"
	@echo "  make down      Detiene el SUT"
	@echo "  make restart   Reinicia el SUT (down + up + health)"
	@echo "  make status    Muestra estado de contenedores (si existe docker compose)"
	@echo "  make logs      Muestra logs (si existe docker compose)"
	@echo "  make perm      Asigna permisos de ejecucion a los scripts"

perm:
	@chmod +x $(RUN_SCRIPT) $(STOP_SCRIPT) $(HEALTH_SCRIPT)
	@echo "Permisos de ejecucion aplicados."

up:
	@$(RUN_SCRIPT)

health:
	@$(HEALTH_SCRIPT)

down:
	@$(STOP_SCRIPT)

restart: down up health

status:
	@{ command -v docker-compose >/dev/null 2>&1 && docker-compose ps; } || \
	 { command -v docker >/dev/null 2>&1 && docker compose ps; } || \
	 { echo "Docker Compose no se encuentra disponible."; exit 1; }

logs:
	@{ command -v docker-compose >/dev/null 2>&1 && docker-compose logs -f --tail=200; } || \
	 { command -v docker >/dev/null 2>&1 && docker compose logs -f --tail=200; } || \
	 { echo "Docker Compose no se encuentra disponible."; exit 1; }
