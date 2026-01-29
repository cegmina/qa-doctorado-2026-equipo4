#!/bin/bash
# Test Concurrent Load (Q6 – R003: Performance under concurrent requests)
# Validates that SUT handles 10 concurrent POST requests without degradation

HOST="${HOST:-localhost}"
PORT="${PORT:-3001}"
BASE_URL="${BASE_URL:-http://${HOST}:${PORT}}"

NUM_REQUESTS=${1:-10}

MARCADETIEMPO=$(date +"%Y%m%d_%H%M%S")
DIRECCION_EVIDENCIA="evidence/week3"
ARCHIVO_DE_REGISTRO="${DIRECCION_EVIDENCIA}/concurrent_load_test_${MARCADETIEMPO}.log"

mkdir -p "$DIRECCION_EVIDENCIA"

{
  echo "=========================================="
  echo "TEST Q6: CONCURRENT LOAD (R003)"
  echo "=========================================="
  echo "Start Time: $(date '+%Y-%m-%d %H:%M:%S')"
  echo "Number of concurrent requests: $NUM_REQUESTS"
  echo ""
  
  # Create temp file for results
  TEMP_RESULTS=$(mktemp)
  
  echo "[STEP 1] Launching $NUM_REQUESTS concurrent POST requests..."
  
  # Launch concurrent requests
  for i in $(seq 1 $NUM_REQUESTS); do
    (
      START_TIME=$(date +%s%N)
      RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "${BASE_URL}/booking" \
        -H "Content-Type: application/json" \
        -d "{
          \"firstname\": \"ConcurrentTest-$i\",
          \"lastname\": \"Week3-$i\",
          \"totalprice\": $((100 + i * 10)),
          \"depositpaid\": true,
          \"bookingdates\": {
            \"checkin\": \"2026-02-01\",
            \"checkout\": \"2026-02-05\"
          }
        }")
      
      END_TIME=$(date +%s%N)
      LATENCY_MS=$(( (END_TIME - START_TIME) / 1000000 ))
      
      HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)
      BODY=$(echo "$RESPONSE" | head -n -1)
      BOOKING_ID=$(echo "$BODY" | jq -r '.bookingid // empty' 2>/dev/null)
      
      echo "$i|$HTTP_CODE|$BOOKING_ID|$LATENCY_MS" >> "$TEMP_RESULTS"
    ) &
  done
  
  # Wait for all background jobs
  wait
  
  echo "[OK] All requests completed"
  echo ""
  
  # Analyze results
  echo "[STEP 2] Analyzing results..."
  PASS_COUNT=0
  FAIL_COUNT=0
  MAX_LATENCY=0
  UNIQUE_IDS=0
  
  while IFS='|' read -r REQ_NUM HTTP_CODE BOOKING_ID LATENCY_MS; do
    if [ "$HTTP_CODE" = "200" ]; then
      PASS_COUNT=$((PASS_COUNT + 1))
      echo "  Request $REQ_NUM: HTTP $HTTP_CODE, ID=$BOOKING_ID, Latency=${LATENCY_MS}ms ✓"
    else
      FAIL_COUNT=$((FAIL_COUNT + 1))
      echo "  Request $REQ_NUM: HTTP $HTTP_CODE [FAIL]"
    fi
    
    if [ "$LATENCY_MS" -gt "$MAX_LATENCY" ]; then
      MAX_LATENCY="$LATENCY_MS"
    fi
  done < "$TEMP_RESULTS"
  
  UNIQUE_IDS=$(cut -d'|' -f3 "$TEMP_RESULTS" | sort -u | wc -l)
  
  echo ""
  echo "=========================================="
  echo "SUMMARY:"
  echo "  Passed: $PASS_COUNT / $NUM_REQUESTS"
  echo "  Failed: $FAIL_COUNT / $NUM_REQUESTS"
  echo "  Unique IDs: $UNIQUE_IDS"
  echo "  Max Latency: ${MAX_LATENCY}ms"
  echo "=========================================="
  echo ""
  
  # Oracle: All must pass, latency <= 2000ms, all IDs unique
  ORACLE_PASS=true
  
  if [ "$PASS_COUNT" != "$NUM_REQUESTS" ]; then
    echo "[FAIL] Not all requests returned HTTP 200"
    ORACLE_PASS=false
  fi
  
  if [ "$UNIQUE_IDS" != "$NUM_REQUESTS" ]; then
    echo "[FAIL] Not all IDs are unique (duplicate bookings detected)"
    ORACLE_PASS=false
  fi
  
  if [ "$MAX_LATENCY" -gt 2000 ]; then
    echo "[WARN] Max latency exceeded threshold (${MAX_LATENCY}ms > 2000ms)"
    ORACLE_PASS=false
  fi
  
  echo ""
  echo "=========================================="
  if [ "$ORACLE_PASS" = true ]; then
    echo "RESULT: PASS"
    echo "ORACLE: All concurrent requests succeeded with unique IDs and acceptable latency"
  else
    echo "RESULT: FAIL"
    echo "ORACLE: Some requests failed, duplicate IDs, or latency exceeded"
  fi
  echo "=========================================="
  echo "End Time: $(date '+%Y-%m-%d %H:%M:%S')"
  
  # Cleanup
  rm -f "$TEMP_RESULTS"
  
} | tee "$ARCHIVO_DE_REGISTRO"
