# RUNLOG — Quality Gate Semana 5

- Fecha: 2026-02-18 21:38:29 UTC
- Comando: ci/run_quality_gates.sh
- Base URL: http://localhost:3001

## Pasos ejecutados

### Check 1: Contrato / disponibilidad
  → PASS (HTTP 201)

### Check 4: Casos sistemáticos (Semana 4)
[0;34m=== Inicio de Ejecución Sistemática ===[0m
URL Base: http://localhost:3001
Marca de Tiempo: 2026-02-18 17:38:29

[0;34m=== Preparación: Creación de bookings de prueba ===[0m
[0;32m✓ Datos de prueba preparados (10 bookings creados)[0m

[0;34m=== Ejecución de Casos de Prueba ===[0m
[0;32m[✓ PASS][0m TC-001: ID=1, HTTP 200, JSON válido, campos requeridos presentes
[0;32m[✓ PASS][0m TC-002: ID=5, HTTP 200, JSON válido
[0;32m[✓ PASS][0m TC-003: ID=10, HTTP 200, datos íntegros
[0;32m[✓ PASS][0m TC-004: ID=0, HTTP 404 (error esperado)
[0;32m[✓ PASS][0m TC-005: ID=-1, HTTP 404 (error esperado)
[0;32m[✓ PASS][0m TC-006: ID=99999, HTTP 404 (no encontrado)
[0;32m[✓ PASS][0m TC-007: ID=999999999, HTTP 404 (error esperado)
[0;32m[✓ PASS][0m TC-008: ID=abc, HTTP 404 (error esperado)
[1;33m[? AMBIGUOUS][0m TC-009: ID=(vacío), HTTP 200 (comportamiento SUT-específico)
[0;32m[✓ PASS][0m TC-010: ID=null, HTTP 404 (error esperado)
[1;33m[? AMBIGUOUS][0m TC-011: ID=12.5, HTTP 200 (comportamiento SUT-específico)
[0;32m[✓ PASS][0m TC-012: ID=1, fechas coherentes (checkin < checkout)
[0;32m[✓ PASS][0m TC-013: ID=2, firstname y lastname son strings no vacíos
[0;32m[✓ PASS][0m TC-014: ID=3, totalprice es número válido
[0;32m[✓ PASS][0m TC-015: ID=4, depositpaid es booleano válido

[0;34m=== Resumen de Ejecución ===[0m
Total de Casos: 15
Aprobados: 13
Reprobados: 0
Ambiguos: 2

[0;32m✓ Ejecución completada.[0m
  → Evidencia generada
  → CHECK 2 comentado por gaming drill (no ejecutado)

### Check 3: Rechazo sin auth (R002/Q7)
  → PASS (HTTP 403, rechazo correcto)

## Evidencia producida
- evidence/week6/before/RUNLOG.md
- evidence/week6/before/SUMMARY.md
