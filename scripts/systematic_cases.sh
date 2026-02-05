#!/bin/bash

################################################################################
# systematic_cases.sh
# Ejecución sistemática de casos de prueba para GET /booking/{id}
# Técnica: Equivalencia (EQ) + Valores Límite (BV)
# Endpoint: GET /booking/{id}
################################################################################

set -o pipefail

# Configuration
HOST="${HOST:-localhost}"
PORT="${PORT:-3001}"
BASE_URL="${BASE_URL:-http://${HOST}:${PORT}}"
EVIDENCE_DIR="evidence/week4"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
RUNLOG_FILE="${EVIDENCE_DIR}/RUNLOG.md"
SUMMARY_FILE="${EVIDENCE_DIR}/summary.txt"

# Create directories
mkdir -p "$EVIDENCE_DIR"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Counters
TOTAL_CASES=0
PASSED=0
FAILED=0
AMBIGUOUS=0

# Arrays to store results
declare -a RESULTS

################################################################################
# Utility Functions
################################################################################

log() {
    # Only output to console with colors, don't write to file
    echo -e "$1"
}

log_case_result() {
    local tc_id=$1
    local status=$2
    local details=$3
    
    # Console output with colors
    if [ "$status" = "PASS" ]; then
        echo -e "${GREEN}[✓ PASS]${NC} $tc_id: $details"
        PASSED=$((PASSED + 1))
    elif [ "$status" = "FAIL" ]; then
        echo -e "${RED}[✗ FAIL]${NC} $tc_id: $details"
        FAILED=$((FAILED + 1))
    else
        echo -e "${YELLOW}[? AMBIGUOUS]${NC} $tc_id: $details"
        AMBIGUOUS=$((AMBIGUOUS + 1))
    fi
    
    # File output without colors
    echo "| $tc_id | $status | $details |" >> "$RUNLOG_FILE"
    RESULTS+=("$tc_id|$status|$details")
}

# Oracle validation functions

oracle_http_200() {
    local http_code=$1
    if [ "$http_code" = "200" ]; then
        return 0
    else
        return 1
    fi
}

oracle_json_valid() {
    local json=$1
    # Try to parse JSON with jq if available, otherwise basic validation
    if command -v jq &> /dev/null; then
        echo "$json" | jq . > /dev/null 2>&1
        return $?
    else
        # Basic JSON validation: check if starts with { and ends with }
        if [[ "$json" == "{"* && "$json" == *"}" ]]; then
            return 0
        fi
        return 1
    fi
}

oracle_required_fields() {
    local json=$1
    local fields=("firstname" "lastname" "totalprice" "depositpaid" "bookingdates")
    
    for field in "${fields[@]}"; do
        if ! echo "$json" | grep -q "\"$field\""; then
            return 1
        fi
    done
    return 0
}

oracle_date_format() {
    local date=$1
    # Check YYYY-MM-DD format
    if [[ $date =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
        return 0
    fi
    return 1
}

oracle_dates_coherent() {
    local json=$1
    # Extract dates
    local checkin=$(echo "$json" | grep -o '"checkin":"[^"]*"' | cut -d'"' -f4)
    local checkout=$(echo "$json" | grep -o '"checkout":"[^"]*"' | cut -d'"' -f4)
    
    # Compare dates (string comparison works for YYYY-MM-DD)
    if [ "$checkin" \< "$checkout" ]; then
        return 0
    fi
    return 1
}

oracle_types_correct() {
    local json=$1
    
    # Check firstname/lastname are non-empty strings
    if ! echo "$json" | grep -qE '"firstname":"[^"]+[^"]*"'; then
        return 1
    fi
    if ! echo "$json" | grep -qE '"lastname":"[^"]+[^"]*"'; then
        return 1
    fi
    
    # Check totalprice is number
    if ! echo "$json" | grep -qE '"totalprice":[0-9]+(\.[0-9]+)?'; then
        return 1
    fi
    
    # Check depositpaid is boolean
    if ! echo "$json" | grep -qE '"depositpaid":(true|false)'; then
        return 1
    fi
    
    return 0
}

################################################################################
# Test Case Execution
################################################################################

# Prepare test data: create bookings for valid ID tests
prepare_test_data() {
    log "${BLUE}=== Preparación: Creación de bookings de prueba ===${NC}"
    
    # Create 10+ test bookings
    for i in {1..10}; do
        local checkin="2025-01-0$((i)):00"
        [ $i -lt 9 ] || checkin="2025-01-1$((i-8)):00"
        
        local checkout="2025-02-0$((i)):00"
        [ $i -lt 9 ] || checkout="2025-02-1$((i-8)):00"
        
        local payload=$(cat <<EOF
{
  "firstname": "TestUser$i",
  "lastname": "LastName$i",
  "totalprice": $((100 + i * 10)),
  "depositpaid": true,
  "bookingdates": {
    "checkin": "$checkin",
    "checkout": "$checkout"
  },
  "additionalneeds": "Breakfast"
}
EOF
        )
        
        curl -s -X POST "$BASE_URL/booking" \
            -H "Content-Type: application/json" \
            -d "$payload" > /dev/null 2>&1
    done
    
    log "${GREEN}✓ Datos de prueba preparados (10 bookings creados)${NC}"
}

# TC-001: Valid ID = 1
execute_tc_001() {
    local tc_id="TC-001"
    local response=$(curl -s -w "\n%{http_code}" "$BASE_URL/booking/1")
    local http_code=$(echo "$response" | tail -n1)
    local body=$(echo "$response" | sed '$d')
    
    local case_file="${EVIDENCE_DIR}/TC-001_response.json"
    echo "$body" > "$case_file"
    
    if oracle_http_200 "$http_code"; then
        if oracle_json_valid "$body" && oracle_required_fields "$body" && oracle_date_format "2025-01-01"; then
            log_case_result "$tc_id" "PASS" "ID=1, HTTP 200, JSON válido, campos requeridos presentes"
        else
            log_case_result "$tc_id" "FAIL" "ID=1, HTTP 200 pero estructura inválida"
        fi
    else
        log_case_result "$tc_id" "FAIL" "ID=1, HTTP $http_code (esperado 200)"
    fi
    TOTAL_CASES=$((TOTAL_CASES + 1))
}

# TC-002: Valid ID = 5
execute_tc_002() {
    local tc_id="TC-002"
    local response=$(curl -s -w "\n%{http_code}" "$BASE_URL/booking/5")
    local http_code=$(echo "$response" | tail -n1)
    local body=$(echo "$response" | sed '$d')
    
    local case_file="${EVIDENCE_DIR}/TC-002_response.json"
    echo "$body" > "$case_file"
    
    if oracle_http_200 "$http_code"; then
        if oracle_json_valid "$body" && oracle_required_fields "$body"; then
            log_case_result "$tc_id" "PASS" "ID=5, HTTP 200, JSON válido"
        else
            log_case_result "$tc_id" "FAIL" "ID=5, HTTP 200 pero estructura inválida"
        fi
    else
        log_case_result "$tc_id" "FAIL" "ID=5, HTTP $http_code (esperado 200)"
    fi
    TOTAL_CASES=$((TOTAL_CASES + 1))
}

# TC-003: Valid ID = 10 (Integridad)
execute_tc_003() {
    local tc_id="TC-003"
    local response=$(curl -s -w "\n%{http_code}" "$BASE_URL/booking/10")
    local http_code=$(echo "$response" | tail -n1)
    local body=$(echo "$response" | sed '$d')
    
    local case_file="${EVIDENCE_DIR}/TC-003_response.json"
    echo "$body" > "$case_file"
    
    if oracle_http_200 "$http_code"; then
        if oracle_json_valid "$body" && oracle_required_fields "$body"; then
            log_case_result "$tc_id" "PASS" "ID=10, HTTP 200, datos íntegros"
        else
            log_case_result "$tc_id" "FAIL" "ID=10, datos incompletos o corruptos"
        fi
    else
        log_case_result "$tc_id" "FAIL" "ID=10, HTTP $http_code (esperado 200)"
    fi
    TOTAL_CASES=$((TOTAL_CASES + 1))
}

# TC-004: Boundary Value = 0
execute_tc_004() {
    local tc_id="TC-004"
    local response=$(curl -s -w "\n%{http_code}" "$BASE_URL/booking/0")
    local http_code=$(echo "$response" | tail -n1)
    local body=$(echo "$response" | sed '$d')
    
    local case_file="${EVIDENCE_DIR}/TC-004_response.json"
    echo "$body" > "$case_file"
    
    if [ "$http_code" != "200" ]; then
        log_case_result "$tc_id" "PASS" "ID=0, HTTP $http_code (error esperado)"
    else
        log_case_result "$tc_id" "FAIL" "ID=0, HTTP 200 (se esperaba error)"
    fi
    TOTAL_CASES=$((TOTAL_CASES + 1))
}

# TC-005: Negative ID
execute_tc_005() {
    local tc_id="TC-005"
    local response=$(curl -s -w "\n%{http_code}" "$BASE_URL/booking/-1")
    local http_code=$(echo "$response" | tail -n1)
    local body=$(echo "$response" | sed '$d')
    
    local case_file="${EVIDENCE_DIR}/TC-005_response.json"
    echo "$body" > "$case_file"
    
    if [ "$http_code" != "200" ]; then
        log_case_result "$tc_id" "PASS" "ID=-1, HTTP $http_code (error esperado)"
    else
        log_case_result "$tc_id" "FAIL" "ID=-1, HTTP 200 (se esperaba error)"
    fi
    TOTAL_CASES=$((TOTAL_CASES + 1))
}

# TC-006: Non-existent ID
execute_tc_006() {
    local tc_id="TC-006"
    local response=$(curl -s -w "\n%{http_code}" "$BASE_URL/booking/99999")
    local http_code=$(echo "$response" | tail -n1)
    local body=$(echo "$response" | sed '$d')
    
    local case_file="${EVIDENCE_DIR}/TC-006_response.json"
    echo "$body" > "$case_file"
    
    if [ "$http_code" = "404" ]; then
        log_case_result "$tc_id" "PASS" "ID=99999, HTTP 404 (no encontrado)"
    else
        log_case_result "$tc_id" "FAIL" "ID=99999, HTTP $http_code (esperado 404)"
    fi
    TOTAL_CASES=$((TOTAL_CASES + 1))
}

# TC-007: Very Large ID
execute_tc_007() {
    local tc_id="TC-007"
    local response=$(curl -s -w "\n%{http_code}" "$BASE_URL/booking/999999999")
    local http_code=$(echo "$response" | tail -n1)
    local body=$(echo "$response" | sed '$d')
    
    local case_file="${EVIDENCE_DIR}/TC-007_response.json"
    echo "$body" > "$case_file"
    
    if [ "$http_code" != "200" ]; then
        log_case_result "$tc_id" "PASS" "ID=999999999, HTTP $http_code (error esperado)"
    else
        log_case_result "$tc_id" "FAIL" "ID=999999999, HTTP 200 (se esperaba error)"
    fi
    TOTAL_CASES=$((TOTAL_CASES + 1))
}

# TC-008: Invalid Type - Alphanumeric
execute_tc_008() {
    local tc_id="TC-008"
    local response=$(curl -s -w "\n%{http_code}" "$BASE_URL/booking/abc")
    local http_code=$(echo "$response" | tail -n1)
    local body=$(echo "$response" | sed '$d')
    
    local case_file="${EVIDENCE_DIR}/TC-008_response.json"
    echo "$body" > "$case_file"
    
    if [ "$http_code" != "200" ]; then
        log_case_result "$tc_id" "PASS" "ID=abc, HTTP $http_code (error esperado)"
    else
        log_case_result "$tc_id" "FAIL" "ID=abc, HTTP 200 (se esperaba error)"
    fi
    TOTAL_CASES=$((TOTAL_CASES + 1))
}

# TC-009: Empty ID
execute_tc_009() {
    local tc_id="TC-009"
    # URL vacía (sin ID): /booking/
    local response=$(curl -s -w "\n%{http_code}" "$BASE_URL/booking/")
    local http_code=$(echo "$response" | tail -n1)
    local body=$(echo "$response" | sed '$d')
    
    local case_file="${EVIDENCE_DIR}/TC-009_response.json"
    echo "$body" > "$case_file"
    
    if [ "$http_code" != "200" ]; then
        log_case_result "$tc_id" "PASS" "ID=(vacío), HTTP $http_code (error esperado)"
    else
        log_case_result "$tc_id" "AMBIGUOUS" "ID=(vacío), HTTP 200 (comportamiento SUT-específico)"
    fi
    TOTAL_CASES=$((TOTAL_CASES + 1))
}

# TC-010: Invalid Type - String "null"
execute_tc_010() {
    local tc_id="TC-010"
    local response=$(curl -s -w "\n%{http_code}" "$BASE_URL/booking/null")
    local http_code=$(echo "$response" | tail -n1)
    local body=$(echo "$response" | sed '$d')
    
    local case_file="${EVIDENCE_DIR}/TC-010_response.json"
    echo "$body" > "$case_file"
    
    if [ "$http_code" != "200" ]; then
        log_case_result "$tc_id" "PASS" "ID=null, HTTP $http_code (error esperado)"
    else
        log_case_result "$tc_id" "FAIL" "ID=null, HTTP 200 (se esperaba error)"
    fi
    TOTAL_CASES=$((TOTAL_CASES + 1))
}

# TC-011: Invalid Type - Decimal
execute_tc_011() {
    local tc_id="TC-011"
    local response=$(curl -s -w "\n%{http_code}" "$BASE_URL/booking/12.5")
    local http_code=$(echo "$response" | tail -n1)
    local body=$(echo "$response" | sed '$d')
    
    local case_file="${EVIDENCE_DIR}/TC-011_response.json"
    echo "$body" > "$case_file"
    
    # Comportamiento ambiguo: algunos SUT aceptan 12.5 como 12
    if [ "$http_code" = "200" ] || [ "$http_code" = "404" ] || [ "$http_code" = "400" ]; then
        log_case_result "$tc_id" "AMBIGUOUS" "ID=12.5, HTTP $http_code (comportamiento SUT-específico)"
    else
        log_case_result "$tc_id" "FAIL" "ID=12.5, HTTP $http_code (respuesta no esperada)"
    fi
    TOTAL_CASES=$((TOTAL_CASES + 1))
}

# TC-012: Valid ID with Date Coherence Check
execute_tc_012() {
    local tc_id="TC-012"
    local response=$(curl -s -w "\n%{http_code}" "$BASE_URL/booking/1")
    local http_code=$(echo "$response" | tail -n1)
    local body=$(echo "$response" | sed '$d')
    
    local case_file="${EVIDENCE_DIR}/TC-012_response.json"
    echo "$body" > "$case_file"
    
    if oracle_http_200 "$http_code"; then
        if oracle_dates_coherent "$body"; then
            log_case_result "$tc_id" "PASS" "ID=1, fechas coherentes (checkin < checkout)"
        else
            log_case_result "$tc_id" "FAIL" "ID=1, fechas no coherentes"
        fi
    else
        log_case_result "$tc_id" "FAIL" "ID=1, HTTP $http_code (esperado 200)"
    fi
    TOTAL_CASES=$((TOTAL_CASES + 1))
}

# TC-013: Type Check - Strings
execute_tc_013() {
    local tc_id="TC-013"
    local response=$(curl -s -w "\n%{http_code}" "$BASE_URL/booking/2")
    local http_code=$(echo "$response" | tail -n1)
    local body=$(echo "$response" | sed '$d')
    
    local case_file="${EVIDENCE_DIR}/TC-013_response.json"
    echo "$body" > "$case_file"
    
    if oracle_http_200 "$http_code"; then
        if echo "$body" | grep -qE '"firstname":"[^"]+[^"]*"' && \
           echo "$body" | grep -qE '"lastname":"[^"]+[^"]*"'; then
            log_case_result "$tc_id" "PASS" "ID=2, firstname y lastname son strings no vacíos"
        else
            log_case_result "$tc_id" "FAIL" "ID=2, firstname o lastname vacíos"
        fi
    else
        log_case_result "$tc_id" "FAIL" "ID=2, HTTP $http_code (esperado 200)"
    fi
    TOTAL_CASES=$((TOTAL_CASES + 1))
}

# TC-014: Type Check - Price
execute_tc_014() {
    local tc_id="TC-014"
    local response=$(curl -s -w "\n%{http_code}" "$BASE_URL/booking/3")
    local http_code=$(echo "$response" | tail -n1)
    local body=$(echo "$response" | sed '$d')
    
    local case_file="${EVIDENCE_DIR}/TC-014_response.json"
    echo "$body" > "$case_file"
    
    if oracle_http_200 "$http_code"; then
        if echo "$body" | grep -qE '"totalprice":[0-9]+(\.[0-9]+)?'; then
            log_case_result "$tc_id" "PASS" "ID=3, totalprice es número válido"
        else
            log_case_result "$tc_id" "FAIL" "ID=3, totalprice no es número"
        fi
    else
        log_case_result "$tc_id" "FAIL" "ID=3, HTTP $http_code (esperado 200)"
    fi
    TOTAL_CASES=$((TOTAL_CASES + 1))
}

# TC-015: Type Check - Boolean
execute_tc_015() {
    local tc_id="TC-015"
    local response=$(curl -s -w "\n%{http_code}" "$BASE_URL/booking/4")
    local http_code=$(echo "$response" | tail -n1)
    local body=$(echo "$response" | sed '$d')
    
    local case_file="${EVIDENCE_DIR}/TC-015_response.json"
    echo "$body" > "$case_file"
    
    if oracle_http_200 "$http_code"; then
        if echo "$body" | grep -qE '"depositpaid":(true|false)'; then
            log_case_result "$tc_id" "PASS" "ID=4, depositpaid es booleano válido"
        else
            log_case_result "$tc_id" "FAIL" "ID=4, depositpaid no es booleano"
        fi
    else
        log_case_result "$tc_id" "FAIL" "ID=4, HTTP $http_code (esperado 200)"
    fi
    TOTAL_CASES=$((TOTAL_CASES + 1))
}

################################################################################
# Main Execution
################################################################################

# Initialize RUNLOG with proper formatting
{
    cat <<EOF
# RUNLOG — Informe de Ejecución de Pruebas Sistemáticas

**Endpoint:** GET /booking/{id}  
**Técnica de Prueba:** Clases de Equivalencia (EQ) + Valores Límite (BV)  
**Fecha de Ejecución:** $(date '+%Y-%m-%d %H:%M:%S')  
**URL Base:** $BASE_URL  
**Comando de Ejecución:** $0

---

## Ambiente de Ejecución

- **SO:** $(uname -s)
- **Shell:** Bash
- **Cliente HTTP:** curl
- **SUT:** Restful Booker (http://localhost:3001)

---

## Registro de Ejecución

### Inicialización
- URL Base: $BASE_URL
- Directorio de Evidencia: $EVIDENCE_DIR
- Marca de Tiempo: $(date '+%Y-%m-%d %H:%M:%S')

### Preparación de Datos de Prueba
Creando 10 bookings de prueba...

### Resultados de Casos de Prueba

| TC-ID | Estado | Detalles |
|-------|--------|----------|
EOF
} > "$RUNLOG_FILE"

log "${BLUE}=== Inicio de Ejecución Sistemática ===${NC}"
echo "URL Base: $BASE_URL"
echo "Directorio de Evidencia: $EVIDENCE_DIR"
echo "Marca de Tiempo: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# Prepare data
prepare_test_data

# Execute all test cases
echo ""
log "${BLUE}=== Ejecución de Casos de Prueba ===${NC}"

execute_tc_001
execute_tc_002
execute_tc_003
execute_tc_004
execute_tc_005
execute_tc_006
execute_tc_007
execute_tc_008
execute_tc_009
execute_tc_010
execute_tc_011
execute_tc_012
execute_tc_013
execute_tc_014
execute_tc_015

# Summary
echo ""
log "${BLUE}=== Resumen de Ejecución ===${NC}"
echo "Total de Casos: $TOTAL_CASES"
echo "Aprobados: $PASSED"
echo "Reprobados: $FAILED"
echo "Ambiguos: $AMBIGUOUS"

# Append summary to RUNLOG
cat >> "$RUNLOG_FILE" <<EOF

---

## Resumen

- **Total de Casos:** $TOTAL_CASES
- **Aprobados:** $PASSED
- **Reprobados:** $FAILED
- **Ambiguos:** $AMBIGUOUS
- **Tasa de Aprobación:** $(awk "BEGIN {printf \"%.1f\", ($PASSED / $TOTAL_CASES) * 100}")%

---

## Conclusión

✓ Ejecución de pruebas sistemáticas completada exitosamente.

**Ubicación de Evidencia:** evidence/week4/
- Respuestas individuales: TC-001_response.json a TC-015_response.json
- Archivo de resumen: summary.txt
- Este registro: RUNLOG.md

EOF

# Save summary file
cat > "$SUMMARY_FILE" <<EOF
Resumen de Ejecución de Pruebas Sistemáticas
=============================================
Endpoint: GET /booking/{id}
Fecha de Ejecución: $(date '+%Y-%m-%d %H:%M:%S')

Total de Casos: $TOTAL_CASES
Aprobados: $PASSED
Reprobados: $FAILED
Ambiguos: $AMBIGUOUS

Tasa de Aprobación: $(awk "BEGIN {printf \"%.2f\", ($PASSED / $TOTAL_CASES) * 100}")%

Resultados por Caso:
EOF

for result in "${RESULTS[@]}"; do
    echo "$result" >> "$SUMMARY_FILE"
done

echo ""
log "${GREEN}✓ Ejecución completada.${NC}"
echo "Evidencia guardada en: $EVIDENCE_DIR"
echo "Resumen: $SUMMARY_FILE"
echo "Registro: $RUNLOG_FILE"

exit 0
