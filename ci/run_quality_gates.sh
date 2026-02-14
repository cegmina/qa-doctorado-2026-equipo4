#!/usr/bin/env bash
# run_quality_gates.sh — Quality Gate Semana 5
# Ejecuta los 4 checks definidos en ci/quality_gates.md.
# Genera evidencia en evidence/week5/, SUMMARY.md, y retorna código distinto de 0 si falla.
# Funciona igual localmente y en CI.

set -uo pipefail

# Configuración
SUT_HOST="${SUT_HOST:-localhost}"
SUT_PORT="${SUT_PORT:-3001}"
BASE_URL="${BASE_URL:-http://${SUT_HOST}:${SUT_PORT}}"
OUT_DIR="${OUT_DIR:-evidence/week5}"
SKIP_SUT_START="${SKIP_SUT_START:-0}"

# Directorio del proyecto (donde está el Makefile/setup)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
cd "${PROJECT_ROOT}"

mkdir -p "${OUT_DIR}"

# Contador de fallos para salida final
GATE_FAILS=0

# Inicializar RUNLOG
RUNLOG="${OUT_DIR}/RUNLOG.md"
{
  echo "# RUNLOG — Quality Gate Semana 5"
  echo ""
  echo "- Fecha: $(date -u +"%Y-%m-%d %H:%M:%S UTC")"
  echo "- Comando: ci/run_quality_gates.sh"
  echo "- Base URL: ${BASE_URL}"
  echo ""
  echo "## Pasos ejecutados"
} > "${RUNLOG}"

# ---------------------------------------------------------------------------
# Iniciar SUT (opcional: SKIP_SUT_START=1 en CI si ya está levantado)
# ---------------------------------------------------------------------------
if [ "${SKIP_SUT_START}" != "1" ]; then
  echo "- Iniciar SUT" >> "${RUNLOG}"
  if ./setup/run_sut.sh 2>> "${RUNLOG}"; then
    echo "  → SUT iniciado" >> "${RUNLOG}"
  else
    echo "  → ERROR al iniciar SUT" >> "${RUNLOG}"
    ((GATE_FAILS++))
  fi

  echo "- Healthcheck" >> "${RUNLOG}"
  if ./setup/healthcheck_sut.sh 2>> "${RUNLOG}"; then
    echo "  → SUT operativo" >> "${RUNLOG}"
  else
    echo "  → ERROR: SUT no responde" >> "${RUNLOG}"
    ((GATE_FAILS++))
  fi
fi

# ---------------------------------------------------------------------------
# CHECK 1: Contrato / disponibilidad del SUT
# Oracle: HTTP 200 y cuerpo interpretable
# ---------------------------------------------------------------------------
echo "" >> "${RUNLOG}"
echo "### Check 1: Contrato / disponibilidad" >> "${RUNLOG}"

RESP1=$(curl -sS -w "\n%{http_code}" -m 10 "${BASE_URL}/ping" 2>/dev/null || curl -sS -w "\n%{http_code}" -m 10 "${BASE_URL}/booking" 2>/dev/null)
HTTP1=$(echo "${RESP1}" | tail -n 1)
BODY1=$(echo "${RESP1}" | sed '$d')

echo "${HTTP1}" > "${OUT_DIR}/contract_http_code.txt"
echo "${BODY1}" > "${OUT_DIR}/health_response.json" 2>/dev/null || echo '{}' > "${OUT_DIR}/health_response.json"

if [ "${HTTP1}" = "200" ] || [ "${HTTP1}" = "201" ]; then
  echo "  → PASS (HTTP ${HTTP1})" >> "${RUNLOG}"
else
  echo "  → FAIL (HTTP ${HTTP1}, esperado 200/201)" >> "${RUNLOG}"
  ((GATE_FAILS++))
fi

# ---------------------------------------------------------------------------
# CHECK 4 (antes de 2): Casos sistemáticos — crea bookings para Check 2
# ---------------------------------------------------------------------------
echo "" >> "${RUNLOG}"
echo "### Check 4: Casos sistemáticos (Semana 4)" >> "${RUNLOG}"

if bash ./scripts/systematic_cases.sh >> "${RUNLOG}" 2>&1; then
  SYS_EXIT=0
else
  SYS_EXIT=$?
fi

cp -f evidence/week4/summary.txt "${OUT_DIR}/systematic_summary.txt" 2>/dev/null || touch "${OUT_DIR}/systematic_summary.txt"
cp -f evidence/week4/RUNLOG.md "${OUT_DIR}/systematic_runlog.md" 2>/dev/null || true

echo "tc_id,status,details" > "${OUT_DIR}/systematic_results.csv"
if [ -f evidence/week4/RUNLOG.md ]; then
  grep -E '^\| TC-' evidence/week4/RUNLOG.md 2>/dev/null | while IFS= read -r line; do
    tc=$(echo "$line" | sed 's/^| *//;s/ *|.*//')
    rest=$(echo "$line" | sed 's/^| *[^|]* *| *[^|]* *| *//;s/ *| *$//')
    status=$(echo "$line" | sed 's/^| *[^|]* *| *//;s/ *|.*//')
    echo "${tc},${status},\"${rest}\"" >> "${OUT_DIR}/systematic_results.csv"
  done
fi

FAIL_COUNT=$(grep -cE '\| FAIL \|' evidence/week4/RUNLOG.md 2>/dev/null || echo "0")
if [ "${SYS_EXIT}" = "0" ] && [ -f evidence/week4/summary.txt ]; then
  echo "  → Evidencia generada (FAILs requieren revisión del equipo)" >> "${RUNLOG}"
  if [ "${FAIL_COUNT}" -gt 0 ]; then
    echo "  → ATENCIÓN: ${FAIL_COUNT} caso(s) FAIL en systematic_cases" >> "${RUNLOG}"
    ((GATE_FAILS++))
  fi
else
  echo "  → FAIL (script systematic_cases falló o no generó evidencia)" >> "${RUNLOG}"
  ((GATE_FAILS++))
fi

# ---------------------------------------------------------------------------
# CHECK 2: Persistencia de datos (R001 / Q5)
# Oracle: GET /booking/{id} HTTP 200 + JSON con campos obligatorios
# Resiliente: probar 1, luego primer ID de /booking, luego POST si existe
# ---------------------------------------------------------------------------
echo "" >> "${RUNLOG}"
echo "### Check 2: Persistencia (R001/Q5)" >> "${RUNLOG}"

RESP2=$(curl -sS -w "\n%{http_code}" -m 15 "${BASE_URL}/booking/1" 2>/dev/null)
HTTP2_TMP=$(echo "${RESP2}" | tail -n 1)
if [ "${HTTP2_TMP}" = "404" ] || [ "${HTTP2_TMP}" = "000" ]; then
  # Intentar obtener primer ID desde GET /booking (API pública puede tener IDs distintos)
  BOOKINGS_JSON=$(curl -sS -m 15 "${BASE_URL}/booking" 2>/dev/null || echo "[]")
  BID=$(echo "${BOOKINGS_JSON}" | jq -r 'if type == "array" and length > 0 then .[0].bookingid else empty end' 2>/dev/null)
  if [ -n "${BID}" ] && [ "${BID}" != "null" ]; then
    RESP2=$(curl -sS -w "\n%{http_code}" -m 15 "${BASE_URL}/booking/${BID}" 2>/dev/null)
  else
    # Fallback: crear booking
    CREATE_PERS=$(curl -sS -X POST "${BASE_URL}/booking" -H "Content-Type: application/json" \
      -d '{"firstname":"PersistGate","lastname":"Week5","totalprice":100,"depositpaid":true,"bookingdates":{"checkin":"2017-12-31","checkout":"2018-12-31"}}' 2>/dev/null)
    BID=$(echo "${CREATE_PERS}" | jq -r '.bookingid // empty' 2>/dev/null)
    if [ -n "${BID}" ] && [ "${BID}" != "null" ]; then
      RESP2=$(curl -sS -w "\n%{http_code}" -m 15 "${BASE_URL}/booking/${BID}" 2>/dev/null)
    fi
  fi
fi
HTTP2=$(echo "${RESP2}" | tail -n 1)
BODY2=$(echo "${RESP2}" | sed '$d')

echo "${BODY2}" > "${OUT_DIR}/persistency_response.json"
{
  echo "[$(date -u +"%Y-%m-%d %H:%M:%S UTC")] GET /booking/1"
  echo "HTTP_CODE=${HTTP2}"
  echo "BODY=${BODY2}"
} > "${OUT_DIR}/persistency_check.log"

FIELDS_OK=0
if [ "${HTTP2}" = "200" ]; then
  FIELDS_OK=1
  for f in firstname lastname totalprice depositpaid bookingdates; do
    if ! echo "${BODY2}" | grep -q "\"${f}\""; then
      FIELDS_OK=0
      break
    fi
  done
  if [ "${FIELDS_OK}" = "1" ] && command -v jq >/dev/null 2>&1; then
    echo "${BODY2}" | jq . >/dev/null 2>&1 || FIELDS_OK=0
  fi
fi

if [ "${HTTP2}" = "200" ] && [ "${FIELDS_OK}" = "1" ]; then
  echo "RESULT: PASS" >> "${OUT_DIR}/persistency_check.log"
  echo "  → PASS (HTTP 200, JSON válido con campos requeridos)" >> "${RUNLOG}"
else
  echo "RESULT: FAIL" >> "${OUT_DIR}/persistency_check.log"
  echo "  → FAIL (HTTP ${HTTP2} o JSON inválido/faltan campos)" >> "${RUNLOG}"
  ((GATE_FAILS++))
fi

# ---------------------------------------------------------------------------
# CHECK 3: Rechazo sin autenticación (R002 / Q7)
# Oracle: PUT sin token → HTTP 401 o 403
# ---------------------------------------------------------------------------
echo "" >> "${RUNLOG}"
echo "### Check 3: Rechazo sin auth (R002/Q7)" >> "${RUNLOG}"

# Crear booking para luego intentar PUT sin token; si falla, usar primer ID existente
CREATE_RESP=$(curl -sS -X POST "${BASE_URL}/booking" \
  -H "Content-Type: application/json" \
  -d '{"firstname":"GateAuth","lastname":"Test","totalprice":100,"depositpaid":true,"bookingdates":{"checkin":"2026-02-01","checkout":"2026-02-05"}}' 2>/dev/null)
BOOKING_ID=$(echo "${CREATE_RESP}" | jq -r '.bookingid // empty' 2>/dev/null)

if [ -z "${BOOKING_ID}" ] || [ "${BOOKING_ID}" = "null" ]; then
  BOOKINGS_JSON=$(curl -sS -m 10 "${BASE_URL}/booking" 2>/dev/null || echo "[]")
  BOOKING_ID=$(echo "${BOOKINGS_JSON}" | jq -r 'if type == "array" and length > 0 then .[0].bookingid else "1" end' 2>/dev/null)
  [ -z "${BOOKING_ID}" ] || [ "${BOOKING_ID}" = "null" ] && BOOKING_ID="1"
fi

PUT_RESP=$(curl -sS -w "\n%{http_code}" -X PUT "${BASE_URL}/booking/${BOOKING_ID}" \
  -H "Content-Type: application/json" \
  -d '{"firstname":"Hacked","lastname":"Test","totalprice":999,"depositpaid":false,"bookingdates":{"checkin":"2026-01-01","checkout":"2026-01-02"}}' 2>/dev/null)
HTTP3=$(echo "${PUT_RESP}" | tail -n 1)
BODY3=$(echo "${PUT_RESP}" | sed '$d')

echo "${HTTP3}" > "${OUT_DIR}/auth_rejection_http_code.txt"
echo "${BODY3}" > "${OUT_DIR}/auth_rejection_response.json" 2>/dev/null || echo '{}' > "${OUT_DIR}/auth_rejection_response.json"

if [ "${HTTP3}" = "401" ] || [ "${HTTP3}" = "403" ]; then
  echo "  → PASS (HTTP ${HTTP3}, rechazo correcto)" >> "${RUNLOG}"
else
  echo "  → FAIL (HTTP ${HTTP3}, esperado 401/403)" >> "${RUNLOG}"
  ((GATE_FAILS++))
fi


# ---------------------------------------------------------------------------
# Resumen final
# ---------------------------------------------------------------------------
echo "" >> "${RUNLOG}"
echo "## Evidencia producida" >> "${RUNLOG}"
echo "- ${OUT_DIR}/contract_http_code.txt" >> "${RUNLOG}"
echo "- ${OUT_DIR}/health_response.json" >> "${RUNLOG}"
echo "- ${OUT_DIR}/persistency_check.log" >> "${RUNLOG}"
echo "- ${OUT_DIR}/persistency_response.json" >> "${RUNLOG}"
echo "- ${OUT_DIR}/auth_rejection_http_code.txt" >> "${RUNLOG}"
echo "- ${OUT_DIR}/auth_rejection_response.json" >> "${RUNLOG}"
echo "- ${OUT_DIR}/systematic_results.csv" >> "${RUNLOG}"
echo "- ${OUT_DIR}/systematic_summary.txt" >> "${RUNLOG}"

# ---------------------------------------------------------------------------
# SUMMARY.md (pass/fail por check)
# ---------------------------------------------------------------------------
SUMMARY="${OUT_DIR}/SUMMARY.md"
{
  echo "# Resumen Quality Gate — Semana 5"
  echo ""
  echo "**Fecha:** $(date -u +"%Y-%m-%d %H:%M:%S UTC")"
  echo ""
  echo "## Resultado global"
  if [ "${GATE_FAILS}" -eq 0 ]; then
    echo "**PASS** — Todos los checks aprobados."
  else
    echo "**FAIL** — ${GATE_FAILS} check(s) fallaron."
  fi
  echo ""
  echo "## Checks"
  echo "| # | Check | Evidencia principal | Estado |"
  echo "|---|-------|---------------------|--------|"
  echo "| 1 | Contrato / disponibilidad | contract_http_code.txt | $([ "${HTTP1}" = "200" ] || [ "${HTTP1}" = "201" ] && echo "PASS" || echo "FAIL") |"
  echo "| 2 | Persistencia (R001/Q5) | persistency_check.log | $([ "${HTTP2}" = "200" ] && [ "${FIELDS_OK}" = "1" ] && echo "PASS" || echo "FAIL") |"
  echo "| 3 | Rechazo sin auth (R002/Q7) | auth_rejection_http_code.txt | $([ "${HTTP3}" = "401" ] || [ "${HTTP3}" = "403" ] && echo "PASS" || echo "FAIL") |"
  echo "| 4 | Casos sistemáticos (Semana 4) | systematic_summary.txt | $([ "${SYS_EXIT}" = "0" ] && [ "${FAIL_COUNT}" = "0" ] && echo "PASS" || echo "FAIL") |"
  echo ""
  echo "## Evidencia en \`${OUT_DIR}/\`"
  echo "- contract_http_code.txt, health_response.json"
  echo "- persistency_check.log, persistency_response.json"
  echo "- auth_rejection_http_code.txt, auth_rejection_response.json"
  echo "- systematic_results.csv, systematic_summary.txt, RUNLOG.md"
} > "${SUMMARY}"

# Salida
if [ "${GATE_FAILS}" -eq 0 ]; then
  echo "Quality gate PASS. Evidencia en ${OUT_DIR}/"
  exit 0
else
  echo "Quality gate FAIL (${GATE_FAILS} check(s) fallaron). Ver ${SUMMARY}"
  exit 1
fi
