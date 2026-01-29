# Estrategia de Prueba – Semana 3: Validación de Top 3 Riesgos

## 1. Propósito

Validar mediante pruebas falsables y repetibles que los tres riesgos críticos (Top 3) de la API Restful Booker están **controlados** dentro de márgenes aceptables. La estrategia se enfoca en atributos de calidad medibles: confiabilidad de datos (persistencia), seguridad de acceso (autenticación), y rendimiento bajo carga concurrente. Los resultados sirven como evidencia de que el SUT es adecuado para la actividad doctoral de aseguramiento de calidad.

---

## 2. Alcance

### Incluido (Semana 3)
- ✅ Validación de **integridad y persistencia** de datos tras reinicio del SUT
- ✅ Validación de **rendimiento funcional** bajo carga concurrente (10 peticiones paralelas)
- ✅ Validación de **autenticación y autorización** (rechazo sin token)
- ✅ Escenarios Q5, Q6, Q7 ejecutados sobre Restful Booker local
- ✅ Evidencia de pases/fallos en logs y artefactos reproducibles

### No Incluido (Fuera de Alcance)
- ❌ Pruebas de seguridad avanzadas (SQLi, XSS, fuzzing)
- ❌ Pruebas de carga extrema (>100 req/s) o estrés hasta ruptura
- ❌ Pruebas de compatibilidad con múltiples versiones de Node.js
- ❌ Pruebas de recuperación ante fallos (disaster recovery, backups)
- ❌ Validación de performance en red no local (latencia de WAN)

---

## 3. Top 3 Riesgos Priorizados

| Riesgo | Por qué es Top 3 | Escenario | Comando/Script | Oráculo (Pass/Fail) | Riesgo Residual |
|--------|-----------------|-----------|---|---|---|
| **R001: Pérdida de datos** (Score 20, Impact 5) | Impacto crítico: pérdida total de datos de reservas | [Q5](../quality/scenarios.md#Q5): Persistencia tras reinicio | `./scripts/test_persistency.sh` | ✅ PASS: GET /booking/{ID} retorna datos intactos post-reinicio (fields == pre-reinicio) | Bajo: si pasa Q5, datos persisten. Residual: *corrupción de datos en múltiples reincios* |
| **R003: Degradación Performance** (Score 16, Impact 4) | Impacto alto: múltiples usuarios no pueden crear reservas simultáneamente | [Q6](../quality/scenarios.md#Q6): 10 POST concurrentes | `./scripts/test_concurrent_load.sh 10` | ✅ PASS: todos los 10 POST devuelven HTTP 200, latencia ≤ 2000ms, 10 IDs únicos | Medio: si pasa Q6, rendimiento es aceptable. Residual: *degradación bajo >100 req/s o >1h de carga sostenida* |
| **R002: Acceso No Autorizado** (Score 15, Impact 5) | Impacto crítico: exposición de datos sensibles sin autenticación | [Q7](../quality/scenarios.md#Q7): Rechazo sin token | `./scripts/test_auth_failure.sh` | ✅ PASS: PUT /booking/{ID} sin token devuelve HTTP 401/403, datos NO modificados post-intento | Bajo: si pasa Q7, acceso no autorizado es bloqueado. Residual: *token expirado, bypass con X-Forwarded-For, autorización débil (IDOR)* |

---

## 4. Reglas de Evidencia

### 4.1 Ubicación de Evidencia
- **Directorio:** `evidence/week3/` (crear si no existe)
- **Formato:** Logs en texto plano + resumen JSON
- **Nomenclatura:** 
  - `persistency_test.log` (Q5)
  - `concurrent_load_test.log` (Q6)
  - `authentication_failure.log` (Q7)

### 4.2 Reproducibilidad: Scripts de Prueba

#### Q5: Persistencia (Reliability)
```bash
#!/bin/bash
# scripts/test_persistency.sh
# Valida que los datos persisten tras reinicio del SUT

SUT_PID=""
BOOKING_ID=""

# 1. Crear reserva
RESPONSE=$(curl -s -X POST http://localhost:3001/booking \
  -H "Content-Type: application/json" \
  -d '{
    "firstname": "PersistencyTest",
    "lastname": "Week3",
    "totalprice": 555,
    "depositpaid": true,
    "bookingdates": {"checkin": "2026-02-01", "checkout": "2026-02-05"}
  }')

BOOKING_ID=$(echo $RESPONSE | jq -r '.bookingid')
PRE_DATA=$(curl -s http://localhost:3001/booking/$BOOKING_ID | jq .)

echo "[Q5] Created booking $BOOKING_ID"
echo "Pre-restart data: $PRE_DATA" >> evidence/week3/persistency_test.log

# 2. Detener SUT (asumir PID conocido o usar docker stop)
docker stop restful-booker
sleep 2

# 3. Reiniciar SUT
docker start restful-booker
sleep 3

# 4. Verificar integridad
POST_DATA=$(curl -s http://localhost:3001/booking/$BOOKING_ID | jq .)

echo "Post-restart data: $POST_DATA" >> evidence/week3/persistency_test.log

# 5. Comparar
if [ "$(echo $PRE_DATA | jq -r '.firstname')" = "PersistencyTest" ] && \
   [ "$(echo $POST_DATA | jq -r '.firstname')" = "PersistencyTest" ]; then
  echo "PASS: Data persisted correctly" >> evidence/week3/persistency_test.log
  exit 0
else
  echo "FAIL: Data corrupted or missing" >> evidence/week3/persistency_test.log
  exit 1
fi
```

#### Q6: Concurrencia (Performance)
```bash
#!/bin/bash
# scripts/test_concurrent_load.sh <num_requests>
# Valida rendimiento bajo carga concurrente

NUM_REQUESTS=${1:-10}
RESULTS_FILE="evidence/week3/concurrent_load_test.log"

echo "Testing concurrent load: $NUM_REQUESTS requests" > $RESULTS_FILE

for i in $(seq 1 $NUM_REQUESTS); do
  (
    RESPONSE=$(curl -s -w "\n%{http_code}" -X POST http://localhost:3001/booking \
      -H "Content-Type: application/json" \
      -d "{
        \"firstname\": \"ConcurrentTest-$i\",
        \"lastname\": \"Week3-$i\",
        \"totalprice\": $((100 + i*10)),
        \"depositpaid\": true,
        \"bookingdates\": {\"checkin\": \"2026-02-01\", \"checkout\": \"2026-02-05\"}
      }")
    
    HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)
    BODY=$(echo "$RESPONSE" | head -n -1)
    BOOKING_ID=$(echo $BODY | jq -r '.bookingid')
    
    echo "Request $i: HTTP $HTTP_CODE, ID=$BOOKING_ID" >> $RESULTS_FILE
  ) &
done

wait

# 6. Validar resultados
PASS_COUNT=$(grep -c "HTTP 200" $RESULTS_FILE)
UNIQUE_IDS=$(grep "ID=" $RESULTS_FILE | awk -F'=' '{print $NF}' | sort -u | wc -l)

echo "SUMMARY: $PASS_COUNT/$NUM_REQUESTS passed, $UNIQUE_IDS unique IDs" >> $RESULTS_FILE

if [ "$PASS_COUNT" = "$NUM_REQUESTS" ] && [ "$UNIQUE_IDS" = "$NUM_REQUESTS" ]; then
  echo "PASS: All concurrent requests succeeded with unique IDs" >> $RESULTS_FILE
  exit 0
else
  echo "FAIL: Some requests failed or IDs duplicated" >> $RESULTS_FILE
  exit 1
fi
```

#### Q7: Autenticación (Security)
```bash
#!/bin/bash
# scripts/test_auth_failure.sh
# Valida que PUT sin token es rechazado

RESULTS_FILE="evidence/week3/authentication_failure.log"

# 1. Crear reserva
BOOKING=$(curl -s -X POST http://localhost:3001/booking \
  -H "Content-Type: application/json" \
  -d '{
    "firstname": "AuthTest",
    "lastname": "Week3",
    "totalprice": 777,
    "depositpaid": true,
    "bookingdates": {"checkin": "2026-02-01", "checkout": "2026-02-05"}
  }')
BOOKING_ID=$(echo $BOOKING | jq -r '.bookingid')
PRE_DATA=$(curl -s http://localhost:3001/booking/$BOOKING_ID | jq .)

echo "Created booking $BOOKING_ID" > $RESULTS_FILE
echo "Pre-attack data: $PRE_DATA" >> $RESULTS_FILE

# 2. Intentar UPDATE sin token
UPDATE=$(curl -s -w "\n%{http_code}" -X PUT http://localhost:3001/booking/$BOOKING_ID \
  -H "Content-Type: application/json" \
  -d '{
    "firstname": "HACKED",
    "lastname": "HACKED",
    "totalprice": 999,
    "depositpaid": false,
    "bookingdates": {"checkin": "2026-01-01", "checkout": "2026-01-02"}
  }')

HTTP_CODE=$(echo "$UPDATE" | tail -n 1)
BODY=$(echo "$UPDATE" | head -n -1)

echo "PUT without token: HTTP $HTTP_CODE" >> $RESULTS_FILE
echo "Response body: $BODY" >> $RESULTS_FILE

# 3. Verificar que datos NO fueron modificados
POST_DATA=$(curl -s http://localhost:3001/booking/$BOOKING_ID | jq .)
echo "Post-attack data: $POST_DATA" >> $RESULTS_FILE

# 4. Validar
if [ "$HTTP_CODE" = "403" ] || [ "$HTTP_CODE" = "401" ]; then
  if [ "$(echo $POST_DATA | jq -r '.firstname')" = "AuthTest" ]; then
    echo "PASS: Unauthorized request rejected, data intact" >> $RESULTS_FILE
    exit 0
  fi
fi

echo "FAIL: Request accepted or data was modified" >> $RESULTS_FILE
exit 1
```

### 4.3 Oráculo Mínimo (Pass/Fail)

| Escenario | Condición de PASS | Condición de FAIL |
|-----------|-------------------|------------------|
| **Q5 (Persistencia)** | Datos retornados por GET post-reinicio = Datos pre-reinicio (todos los campos) | GET retorna 404, o campos diferentes, o HTTP 5xx |
| **Q6 (Concurrencia)** | Todos 10 POST → HTTP 200 + 10 IDs únicos + latencia ≤ 2s cada uno | Algún POST → 5xx, IDs duplicados, latencia > 2s |
| **Q7 (Autenticación)** | PUT sin token → HTTP 401/403 + datos NO modificados en verificación posterior | PUT acepta sin token (HTTP 200) o datos fueron modificados |

---

## 5. Riesgo Residual

Tras ejecutar con éxito los escenarios Q5, Q6, Q7, los riesgos Top 3 se reducen pero **no se eliminan completamente**. El riesgo residual incluye:

1. **R001 (Persistencia):** Control a corto plazo validado. Residual: corrupción bajo reincios repetidos (>10), fallos en múltiples copias de datos, o pérdida en escenarios de crash no controlado (ej.: kill -9). No se valida recuperación ante fallos de hardware.

2. **R003 (Performance):** Rendimiento bajo 10 req/s validado. Residual: degradación bajo carga sostenida (>1 hora), comportamiento bajo >100 req/s, o competencia con otros procesos por recursos. No se valida behavior real en producción con tráfico variable.

3. **R002 (Autenticación):** Rechazo básico validado. Residual: ataques avanzados (session fixation, IDOR en recursos relacionados, token expirado no manejado, bypass por X-Forwarded-For). No se valida autorización granular (ej.: usuario A no puede ver reserva de usuario B).

**Conclusión:** La estrategia de Semana 3 proporciona confianza en los atributos principales, pero requiere validación adicional en ciclos posteriores para escenarios de borde y carga extrema.

---

## 6. Validez de las Pruebas

### 6.1 Validez Interna
Las pruebas se ejecutan en entorno local controlado (Docker, SUT iniciado manualmente) sin variables externas, asegurando que diferencias en resultados se deben al código del SUT, no al ambiente.

### 6.2 Validez de Constructo
Cada escenario valida el atributo de calidad que declara (Q5→Confiabilidad vía persistencia, Q6→Performance vía latencia/throughput, Q7→Seguridad vía rechazo de acceso), con medidas cuantificables (campos iguales, latencia ≤2s, HTTP 401/403).

### 6.3 Validez Externa
Limitada a Restful Booker en contexto académico. Los riesgos y escenarios son específicos de esta API; no se extrapolan directamente a otras aplicaciones o sistemas productivos sin validación adicional. Resultados son aplicables a contextos similares (APIs REST CRUD sobre Node.js con autenticación básica).

---

## 7. Referencias Cruzadas

- **Matriz de riesgos:** [risk/risk_matrix.csv](risk/risk_matrix.csv)
- **Definición de riesgos de calidad:** [risk/quality_risk_definition.md](quality_risk_definition.md)
- **Mapeo Top 3 → Escenarios:** [risk/top3_scenario_mapping.md](top3_scenario_mapping.md)
- **Escenarios Q1-Q7:** [quality/scenarios.md](../quality/scenarios.md)
- **Evidencia (a generar):** [evidence/week3/](../evidence/week3/)

---

## 8. Próximos Pasos (Ejecución)

1. Crear directorio `evidence/week3/`
2. Implementar scripts `test_persistency.sh`, `test_concurrent_load.sh`, `test_auth_failure.sh`
3. Ejecutar cada script contra SUT Restful Booker local
4. Recopilar logs en `evidence/week3/`
5. Documentar pases/fallos en [memos/week3_memo.md](../memos/week3_memo.md)
6. Actualizar status de riesgos (control → Mitigated/Reduced/Residual)
