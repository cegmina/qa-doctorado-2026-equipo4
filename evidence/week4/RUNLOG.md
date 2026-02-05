# RUNLOG — Informe de Ejecución de Pruebas Sistemáticas

**Endpoint:** GET /booking/{id}  
**Técnica de Prueba:** Clases de Equivalencia (EQ) + Valores Límite (BV)  
**Fecha de Ejecución:** 2026-02-04 22:21:02  
**URL Base:** http://localhost:3001  
**Comando de Ejecución:** ./scripts/systematic_cases.sh

---

## Ambiente de Ejecución

- **SO:** MINGW64_NT-10.0-19045
- **Shell:** Bash
- **Cliente HTTP:** curl
- **SUT:** Restful Booker (http://localhost:3001)

---

## Registro de Ejecución

### Inicialización
- URL Base: http://localhost:3001
- Directorio de Evidencia: evidence/week4
- Marca de Tiempo: 2026-02-04 22:21:02

### Preparación de Datos de Prueba
Creando 10 bookings de prueba...

### Resultados de Casos de Prueba

| TC-ID | Estado | Detalles |
|-------|--------|----------|
| TC-001 | PASS | ID=1, HTTP 200, JSON válido, campos requeridos presentes |
| TC-002 | PASS | ID=5, HTTP 200, JSON válido |
| TC-003 | PASS | ID=10, HTTP 200, datos íntegros |
| TC-004 | PASS | ID=0, HTTP 404 (error esperado) |
| TC-005 | PASS | ID=-1, HTTP 404 (error esperado) |
| TC-006 | PASS | ID=99999, HTTP 404 (no encontrado) |
| TC-007 | PASS | ID=999999999, HTTP 404 (error esperado) |
| TC-008 | PASS | ID=abc, HTTP 404 (error esperado) |
| TC-009 | AMBIGUOUS | ID=(vacío), HTTP 200 (comportamiento SUT-específico) |
| TC-010 | PASS | ID=null, HTTP 404 (error esperado) |
| TC-011 | AMBIGUOUS | ID=12.5, HTTP 200 (comportamiento SUT-específico) |
| TC-012 | PASS | ID=1, fechas coherentes (checkin < checkout) |
| TC-013 | PASS | ID=2, firstname y lastname son strings no vacíos |
| TC-014 | PASS | ID=3, totalprice es número válido |
| TC-015 | PASS | ID=4, depositpaid es booleano válido |

---

## Resumen

- **Total de Casos:** 15
- **Aprobados:** 13
- **Reprobados:** 0
- **Ambiguos:** 2
- **Tasa de Aprobación:** 86.7%

---

## Conclusión

✓ Ejecución de pruebas sistemáticas completada exitosamente.

**Ubicación de Evidencia:** evidence/week4/
- Respuestas individuales: TC-001_response.json a TC-015_response.json
- Archivo de resumen: summary.txt
- Este registro: RUNLOG.md

