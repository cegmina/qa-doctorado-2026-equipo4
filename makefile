# Makefile — Restful Booker SUT control
# Uso:
#   make up
#   make health
#   make down

SHELL := /bin/bash

RUN_SCRIPT := ./run_sut.sh
STOP_SCRIPT := ./stop_sut.sh
HEALTH_SCRIPT := ./healthcheck_sut.sh

.PHONY: help up down health restart status logs perm quality-gate gaming-drill

help:
	@echo "Objetivos disponibles:"
	@echo "  make up        Inicia el SUT"
	@echo "  make health    Verifica la salud del SUT"
	@echo "  make down      Detiene el SUT"
	@echo "  make restart   Reinicia el SUT (down + up + health)"
	@echo "  make status    Muestra estado de contenedores (si existe docker compose)"
	@echo "  make logs      Muestra logs (si existe docker compose)"
	@echo "  make perm      Asigna permisos de ejecucion a los scripts"
	@echo ""
	@echo "Escenarios de Calidad  - Semana 2:"
	@echo "  Q1-CreateBooking  - Escenario Q1: Crea una nueva reserva"
	@echo "  Q2-GetBookingById - Escenario Q2: Devuelve una reserva especifica"
	@echo "  Q3-UpdateBooking  - Escenario Q3: Actualiza una reserva existente"
	@echo "  Q4-DeleteBooking  - Escenario Q4: Elimina una reserva existente"
	@echo "  QA-week2          - Ejecutar todos los escenarios Q1-Q4 de la semana 2"
	@echo ""
	@echo "Quality Gate (Semana 5):"
	@echo "  quality-gate      - Ejecutar quality gate (checks + evidencia en evidence/week5/)"
	@echo "  gaming-drill      - Ejecutar experimento BEFORE/AFTER en evidence/week6/"
	@echo ""
	@echo "Pruebas Legacy:"
	@echo "  smoke             - Ejecutar pruebas de humo"

perm:
	@chmod +x $(RUN_SCRIPT) $(STOP_SCRIPT) $(HEALTH_SCRIPT)
	@chmod +x ./ci/run_quality_gates.sh
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

smoke:
	./scripts/smoke.sh

Q1-CreateBooking:
	./scripts/createBooking.sh

Q2-GetBookingById:
	./scripts/getBookingById.sh

Q3-UpdateBooking:
	./scripts/updateBooking.sh

Q4-DeleteBooking:
	./scripts/deleteBooking.sh

QA-week2: Q1-CreateBooking Q2-GetBookingById Q3-UpdateBooking Q4-DeleteBooking
	@echo ""
	@echo "================================"
	@echo "✅ Todos los escenarios Q1-Q4 completados"
	@echo "================================"

quality-gate:
	./ci/run_quality_gates.sh

gaming-drill:
	bash ./ci/run_gate_gaming_drill.sh
