#!/bin/bash
# Test Authentication Failure (Q7 – R002: Unauthorized access without token)
# Validates that PUT without authentication token is rejected

HOST="${HOST:-localhost}"
PORT="${PORT:-3001}"
BASE_URL="${BASE_URL:-http://${HOST}:${PORT}}"

MARCADETIEMPO=$(date +"%Y%m%d_%H%M%S")
DIRECCION_EVIDENCIA="evidence/week3"
ARCHIVO_DE_REGISTRO="${DIRECCION_EVIDENCIA}/authentication_failure_${MARCADETIEMPO}.log"

mkdir -p "$DIRECCION_EVIDENCIA"

{
  echo "=========================================="
  echo "TEST Q7: AUTHENTICATION FAILURE (R002)"
  echo "=========================================="
  echo "Start Time: $(date '+%Y-%m-%d %H:%M:%S')"
  echo ""
  
  # Step 1: Create a booking
  echo "[STEP 1] Creating baseline booking..."
  CREATE_RESPONSE=$(curl -s -X POST "${BASE_URL}/booking" \
    -H "Content-Type: application/json" \
    -d '{
      "firstname": "AuthTest",
      "lastname": "Week3",
      "totalprice": 777,
      "depositpaid": true,
      "bookingdates": {
        "checkin": "2026-02-01",
        "checkout": "2026-02-05"
      }
    }')
  
  BOOKING_ID=$(echo "$CREATE_RESPONSE" | jq -r '.bookingid // empty' 2>/dev/null)
  if [ -z "$BOOKING_ID" ]; then
    echo "[FAIL] Could not create booking"
    echo "Response: $CREATE_RESPONSE"
    exit 1
  fi
  echo "[OK] Booking created with ID: $BOOKING_ID"
  echo ""
  
  # Step 2: Get pre-attack data
  echo "[STEP 2] Retrieving baseline data BEFORE attack..."
  PRE_DATA=$(curl -s "${BASE_URL}/booking/${BOOKING_ID}")
  PRE_FIRSTNAME=$(echo "$PRE_DATA" | jq -r '.firstname // empty' 2>/dev/null)
  PRE_LASTNAME=$(echo "$PRE_DATA" | jq -r '.lastname // empty' 2>/dev/null)
  PRE_TOTALPRICE=$(echo "$PRE_DATA" | jq -r '.totalprice // empty' 2>/dev/null)
  
  echo "Baseline Data:"
  echo "  firstname: $PRE_FIRSTNAME"
  echo "  lastname: $PRE_LASTNAME"
  echo "  totalprice: $PRE_TOTALPRICE"
  echo ""
  
  # Step 3: Try to update WITHOUT token (attack)
  echo "[STEP 3] Attempting PUT /booking/$BOOKING_ID WITHOUT authentication token..."
  echo "  (This should be rejected with 401 or 403)"
  echo ""
  
  UPDATE_RESPONSE=$(curl -s -w "\n%{http_code}" -X PUT "${BASE_URL}/booking/${BOOKING_ID}" \
    -H "Content-Type: application/json" \
    -d '{
      "firstname": "HACKED",
      "lastname": "HACKED",
      "totalprice": 999,
      "depositpaid": false,
      "bookingdates": {
        "checkin": "2026-01-01",
        "checkout": "2026-01-02"
      }
    }')
  
  HTTP_CODE=$(echo "$UPDATE_RESPONSE" | tail -n 1)
  BODY=$(echo "$UPDATE_RESPONSE" | head -n -1)
  
  echo "Response Status: HTTP $HTTP_CODE"
  echo "Response Body: $BODY"
  echo ""
  
  # Step 4: Verify data integrity after attack attempt
  echo "[STEP 4] Verifying data integrity AFTER attack attempt..."
  POST_DATA=$(curl -s "${BASE_URL}/booking/${BOOKING_ID}")
  POST_FIRSTNAME=$(echo "$POST_DATA" | jq -r '.firstname // empty' 2>/dev/null)
  POST_LASTNAME=$(echo "$POST_DATA" | jq -r '.lastname // empty' 2>/dev/null)
  POST_TOTALPRICE=$(echo "$POST_DATA" | jq -r '.totalprice // empty' 2>/dev/null)
  
  echo "Post-attack Data:"
  echo "  firstname: $POST_FIRSTNAME"
  echo "  lastname: $POST_LASTNAME"
  echo "  totalprice: $POST_TOTALPRICE"
  echo ""
  
  # Step 5: Apply Oracle
  echo "[STEP 5] Validating oracle conditions..."
  ORACLE_PASS=true
  
  # Condition 1: HTTP 401 or 403
  if [ "$HTTP_CODE" != "401" ] && [ "$HTTP_CODE" != "403" ]; then
    echo "[FAIL] Expected HTTP 401/403, got $HTTP_CODE (request was accepted)"
    ORACLE_PASS=false
  else
    echo "[OK] Request rejected with HTTP $HTTP_CODE"
  fi
  
  # Condition 2: Data must NOT be modified
  if [ "$PRE_FIRSTNAME" != "$POST_FIRSTNAME" ]; then
    echo "[FAIL] Data was modified: firstname changed from '$PRE_FIRSTNAME' to '$POST_FIRSTNAME'"
    ORACLE_PASS=false
  else
    echo "[OK] firstname intact: $POST_FIRSTNAME"
  fi
  
  if [ "$PRE_LASTNAME" != "$POST_LASTNAME" ]; then
    echo "[FAIL] Data was modified: lastname changed from '$PRE_LASTNAME' to '$POST_LASTNAME'"
    ORACLE_PASS=false
  else
    echo "[OK] lastname intact: $POST_LASTNAME"
  fi
  
  if [ "$PRE_TOTALPRICE" != "$POST_TOTALPRICE" ]; then
    echo "[FAIL] Data was modified: totalprice changed from '$PRE_TOTALPRICE' to '$POST_TOTALPRICE'"
    ORACLE_PASS=false
  else
    echo "[OK] totalprice intact: $POST_TOTALPRICE"
  fi
  
  echo ""
  echo "=========================================="
  if [ "$ORACLE_PASS" = true ]; then
    echo "RESULT: PASS"
    echo "ORACLE: Unauthorized request rejected (HTTP 401/403) and data intact"
  else
    echo "RESULT: FAIL"
    echo "ORACLE: Request was accepted or data was modified"
  fi
  echo "=========================================="
  echo "End Time: $(date '+%Y-%m-%d %H:%M:%S')"
  
} | tee "$ARCHIVO_DE_REGISTRO"

# Exit with appropriate code
if [ "$ORACLE_PASS" = true ]; then
  exit 0
else
  exit 1
fi
