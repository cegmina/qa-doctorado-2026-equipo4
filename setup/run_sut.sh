#!/usr/bin/env bash
# run_sut.sh
set -euo pipefail

SUT_NAME="${SUT_NAME:-restful-booker}"
SUT_HOST="${SUT_HOST:-localhost}"
SUT_PORT="${SUT_PORT:-3001}"
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
require_cmd curl

C="$(compose_cmd)"

echo "Iniciando SUT Restful-booker: ${SUT_NAME}"
echo "Archivo Compose: ${COMPOSE_FILE}"

${C} -f "${COMPOSE_FILE}" build
${C} -f "${COMPOSE_FILE}" up -d

echo "SUT iniciado. Endpoint esperado: http://${SUT_HOST}:${SUT_PORT}"
