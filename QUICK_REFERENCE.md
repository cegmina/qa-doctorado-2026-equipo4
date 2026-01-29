# ⚡ Quick Reference – Semana 3 en Una Página

| Elemento | Contenido | Archivo |
|----------|-----------|---------|
| **10 Riesgos Identificados** | Risk ID, Attribute, Impact, Probability, Score, Status | [risk/risk_matrix.csv](risk/risk_matrix.csv) |
| **Top 3 Riesgos** | R001 (20), R003 (16), R002 (15) | Orden por score descendente |
| **8 Atributos Calidad** | Reliability, Security, Performance, Availability, Correctness, Compatibility, Functional Correctness, Maintainability | [risk/quality_risk_definition.md](risk/quality_risk_definition.md) |
| **Escenarios Q1–Q7** | Q1–Q4 Week 2 (CRUD), Q5–Q7 Week 3 (Top 3) | [quality/scenarios.md](quality/scenarios.md) |

---

## 🎯 Top 3 Riesgos en Detalle

### R001 – Pérdida de Datos (Reliability, Score: 20)
- **Escenario:** Q5 – Persistencia tras reinicio
- **Test:** `bash scripts/test_persistency.sh`
- **Oracle:** Datos idénticos antes/después
- **Evidence:** `evidence/week3/persistency_test_*.log`
- **Status:** ✅ PASS

### R003 – Performance bajo Carga (Performance, Score: 16)
- **Escenario:** Q6 – 10 POST concurrentes
- **Test:** `bash scripts/test_concurrent_load.sh 10`
- **Oracle:** 10 HTTP 200 + IDs únicos + latencia ≤2s
- **Evidence:** `evidence/week3/concurrent_load_test_*.log`
- **Status:** ✅ PASS

### R002 – Acceso No Autorizado (Security, Score: 15)
- **Escenario:** Q7 – Rechazo sin token
- **Test:** `bash scripts/test_auth_failure.sh`
- **Oracle:** HTTP 401/403 + datos intactos
- **Evidence:** `evidence/week3/authentication_failure_*.log`
- **Status:** ✅ PASS

---

## 📁 Archivos Clave

```
risk/
  ├── risk_matrix.csv                 ← 10 riesgos, scores, Top 3
  ├── quality_risk_definition.md      ← 8 atributos, exclusiones
  ├── top3_scenario_mapping.md        ← Mapeo detallado Top 3
  └── test_strategy.md                ← Estrategia, oráculos, scripts

quality/
  └── scenarios.md                    ← Q1–Q7 (Q5–Q7 nuevos)

scripts/
  ├── test_persistency.sh             ← Q5 (R001)
  ├── test_concurrent_load.sh         ← Q6 (R003)
  └── test_auth_failure.sh            ← Q7 (R002)

evidence/week3/
  ├── RUNLOG.md                       ← Master runlog
  ├── SUMMARY.md                      ← Resumen ejecutivo
  ├── INDEX.md                        ← Índice navegable
  ├── persistency_test_*.log
  ├── concurrent_load_test_*.log
  └── authentication_failure_*.log
```

---

## 🔗 Trazabilidad Rápida

```
Risk → Scenario → Script → Evidence → Oracle → Status
─────────────────────────────────────────────────────
R001 → Q5      → test_persistency.sh → *_143022.log → PASS ✅
R003 → Q6      → test_concurrent_load.sh → *_143145.log → PASS ✅
R002 → Q7      → test_auth_failure.sh → *_143245.log → PASS ✅
```

---

## 💡 Quick Tips

| Si quieres... | Abre... |
|---|---|
| Ver matriz de riesgos | `risk/risk_matrix.csv` |
| Entender qué es "riesgo de calidad" | `risk/quality_risk_definition.md` |
| Ver escenarios de prueba | `quality/scenarios.md` |
| Ejecutar tests | `scripts/test_*.sh` |
| Leer evidencia | `evidence/week3/RUNLOG.md` |
| Navegación completa | `NAVIGATION_GUIDE.md` |
| Resumen ejecutivo | `WEEK3_DELIVERABLES.md` |

---

## 📊 Estadísticas

- **Riesgos Total:** 10
- **Riesgos Top 3:** 3 (100% validados)
- **Riesgos BACKLOG:** 7 (pendientes)
- **Escenarios Nuevos:** 3 (Q5, Q6, Q7)
- **Scripts Nuevos:** 3
- **Evidence Files:** 6 (RUNLOG + 3 logs + INDEX + SUMMARY)
- **Pass Rate:** 3/3 (100%)

---

## ✅ Requisitos Cumplidos

- [x] Matriz de riesgos (10 riesgos, scores, Top 3)
- [x] Definición de calidad (8 atributos)
- [x] Mapeo Top 3 → Escenarios
- [x] Estrategia de prueba (oráculos, riesgo residual)
- [x] Evidencia Week 3 (RUNLOG, logs, scripts)
- [x] Trazabilidad completa

---

**Semana 3:** ✅ COMPLETADA  
**Próxima:** Semana 4 – Riesgos BACKLOG
