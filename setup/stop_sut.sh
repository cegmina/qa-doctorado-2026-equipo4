#!/usr/bin/env bash
# stop_sut.sh
set -euo pipefail

SUT_NAME="${SUT_NAME:-restful-booker}"
COMPOSE_FILE="${COMPOSE_FILE:-docker-compose.yml}"

compose_cmd() {
  if command -v docker-compose >/dev/null 2>&1; then
    echo "docker-compose"
  else
    echo "docker compose"
  fi
}

require_cmd() {
  local cmd="$1"
  if ! command -v "${cmd}" >/dev/null 2>&1; then
    echo "Falta el comando requerido: ${cmd}" >&2
    exit 1
  fi
}

require_cmd docker

C="$(compose_cmd)"

echo "Deteniendo SUT: ${SUT_NAME}"
echo "Archivo Compose: ${COMPOSE_FILE}"

# Detención y limpieza de recursos del Compose
${C} -f "${COMPOSE_FILE}" down

echo "SUT detenido."
