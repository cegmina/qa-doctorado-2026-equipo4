#!/usr/bin/env bash
# healthcheck_sut.sh
set -euo pipefail

SUT_HOST="${SUT_HOST:-localhost}"
SUT_PORT="${SUT_PORT:-3001}"
SUT_BASE_URL="${SUT_BASE_URL:-http://${SUT_HOST}:${SUT_PORT}}"

PING_PATH="${PING_PATH:-/ping}"
BOOKING_PATH="${BOOKING_PATH:-/booking}"

TIMEOUT_SECONDS="${TIMEOUT_SECONDS:-5}"
RETRIES="${RETRIES:-10}"
SLEEP_SECONDS="${SLEEP_SECONDS:-1}"

require_cmd() {
  local cmd="$1"
  if ! command -v "${cmd}" >/dev/null 2>&1; then
    echo "Falta el comando requerido: ${cmd}" >&2
    exit 1
  fi
}

require_cmd curl

check_endpoint() {
  local url="$1"
  local expected_codes_csv="$2"
  local code

  code="$(curl -sS -o /dev/null -m "${TIMEOUT_SECONDS}" -w "%{http_code}" "${url}" || echo "000")"

  IFS=',' read -r -a expected <<< "${expected_codes_csv}"
  for ec in "${expected[@]}"; do
    if [[ "${code}" == "${ec}" ]]; then
      echo "OK ${code} -> ${url}"
      return 0
    fi
  done

  echo "FALLO ${code} -> ${url} (esperado: ${expected_codes_csv})" >&2
  return 1
}

echo "Verificando salud del SUT en: ${SUT_BASE_URL}"

for ((i=1; i<=RETRIES; i++)); do
  if check_endpoint "${SUT_BASE_URL}${PING_PATH}" "200,201" && check_endpoint "${SUT_BASE_URL}${BOOKING_PATH}" "200"; then
    echo "Salud verificada. SUT operativo."
    exit 0
  fi
  echo "Reintento ${i}/${RETRIES} en ${SLEEP_SECONDS} s..."
  sleep "${SLEEP_SECONDS}"
done

echo "No se verificó la salud del SUT tras ${RETRIES} intentos." >&2
exit 1
