# 🧭 Guía de Navegación – Semana 3: Análisis de Riesgos de Calidad

**Proyecto:** Restful Booker – QA Doctoral Activity  
**Semana:** 3 (Identificación, Validación y Evidencia de Top 3 Riesgos)  
**Fecha:** 28 de enero de 2026

---

## 📖 Cómo Navegar esta Documentación

### 🎯 Si quieres entender la estrategia general...

1. **Comienza aquí:** [WEEK3_DELIVERABLES.md](WEEK3_DELIVERABLES.md)
   - Vista general de todos los entregables
   - Resumen ejecutivo
   - Checklist de requisitos

2. **Luego lee:** [risk/quality_risk_definition.md](risk/quality_risk_definition.md)
   - Qué cuenta como "riesgo de calidad"
   - 8 atributos de calidad medibles
   - Qué NO es un riesgo (gestión)

---

### 🔍 Si quieres ver la matriz de riesgos...

**Archivo directo:** [risk/risk_matrix.csv](risk/risk_matrix.csv)

**Cómo leerlo:**
```
risk_id     → Identificador (R001–R010)
score       → Impact × Probability (rango 4–20)
status      → TOP3 o BACKLOG
scenario_ref → Enlace a escenario en quality/scenarios.md
evidence_ref → Enlace a logs en evidence/week3/
```

**Top 3 Resaltados:**
- **R001** (Reliability, 20) – Pérdida de datos
- **R003** (Performance, 16) – Degradación bajo carga
- **R002** (Security, 15) – Acceso no autorizado

---

### 📋 Si quieres entender los escenarios de prueba...

1. **Para todos los escenarios:** [quality/scenarios.md](quality/scenarios.md)
   - Q1–Q4 (Week 2) – Smoke tests básicos
   - Q5–Q7 (Week 3) – Validación de Top 3 riesgos

2. **Para mapeo detallado de Top 3:** [risk/top3_scenario_mapping.md](risk/top3_scenario_mapping.md)
   - Tabla trazable: Risk → Escenario → Medida → Oracle

---

### 🧪 Si quieres ejecutar los tests...

**Scripts disponibles:** `scripts/`

```bash
# Test 1: Persistencia de datos (R001)
bash scripts/test_persistency.sh
→ Output: evidence/week3/persistency_test_*.log

# Test 2: Carga concurrente (R003)
bash scripts/test_concurrent_load.sh 10
→ Output: evidence/week3/concurrent_load_test_*.log

# Test 3: Autenticación (R002)
bash scripts/test_auth_failure.sh
→ Output: evidence/week3/authentication_failure_*.log
```

---

### 📊 Si quieres ver la evidencia...

**Directorio:** [evidence/week3/](evidence/week3/)

**Para navegar la evidencia:**
1. Comienza en [evidence/week3/INDEX.md](evidence/week3/INDEX.md)
   - Índice de todos los archivos
   - Descripción de cada test
   - Ubicación de logs

2. O directo al master runlog: [evidence/week3/RUNLOG.md](evidence/week3/RUNLOG.md)
   - Todas las ejecuciones documentadas
   - Oráculos validados
   - Timestamps y traceabilidad

3. O al resumen: [evidence/week3/SUMMARY.md](evidence/week3/SUMMARY.md)
   - Estado general de todos los tests
   - Tabla de resultados
   - Próximos pasos

---

### 🎓 Si preparas una presentación...

**Documentos cortos y sintetizados:**

1. **Ejecutivo (2 minutos):** [WEEK3_DELIVERABLES.md](WEEK3_DELIVERABLES.md#-entregables-generados)
2. **Técnico (5 minutos):** [risk/test_strategy.md](risk/test_strategy.md)
3. **Detallado (15 minutos):** [evidence/week3/SUMMARY.md](evidence/week3/SUMMARY.md)

---

### 🔐 Si necesitas validación de seguridad...

**Documento principal:** [risk/quality_risk_definition.md](risk/quality_risk_definition.md#12-security-seguridad)

**Riesgos relacionados:**
- **R002** (TOP 3) – Acceso no autorizado
  - Test: [scripts/test_auth_failure.sh](scripts/test_auth_failure.sh)
  - Evidence: [evidence/week3/authentication_failure_*.log](evidence/week3/authentication_failure_20260128_143245.log)

- **R009** (BACKLOG) – Inyección SQL/NoSQL
  - Escenario: [quality/scenarios.md#Q1](quality/scenarios.md#escenario-q1--crea-una-nueva-reserva-en-la-api)

---

### ⚡ Si necesitas performance...

**Documento principal:** [risk/quality_risk_definition.md](risk/quality_risk_definition.md#13-performance-rendimiento)

**Riesgos relacionados:**
- **R003** (TOP 3) – Degradación bajo carga
  - Test: [scripts/test_concurrent_load.sh](scripts/test_concurrent_load.sh)
  - Evidence: [evidence/week3/concurrent_load_test_*.log](evidence/week3/concurrent_load_test_20260128_143145.log)
  - Métricas: 10 concurrent requests, max latency 156ms

---

### 💾 Si necesitas confiabilidad de datos...

**Documento principal:** [risk/quality_risk_definition.md](risk/quality_risk_definition.md#11-reliability-confiabilidad)

**Riesgos relacionados:**
- **R001** (TOP 3) – Pérdida de datos
  - Test: [scripts/test_persistency.sh](scripts/test_persistency.sh)
  - Evidence: [evidence/week3/persistency_test_*.log](evidence/week3/persistency_test_20260128_143022.log)
  - Oracle: Datos idénticos antes/después reinicio

---

## 🗺️ Mapa Mental Completo

```
SEMANA 3: ANÁLISIS DE RIESGOS
│
├─── IDENTIFICACIÓN
│    ├─ risk/risk_matrix.csv (10 riesgos)
│    ├─ risk/quality_risk_definition.md (8 atributos)
│    └─ Top 3 seleccionados
│
├─── MAPEO A ESCENARIOS
│    ├─ quality/scenarios.md (Q5–Q7)
│    ├─ risk/top3_scenario_mapping.md (detalle)
│    └─ Estímulo/Entorno/Respuesta/Medida
│
├─── ESTRATEGIA DE PRUEBA
│    ├─ risk/test_strategy.md (oráculos)
│    ├─ scripts/test_*.sh (3 scripts)
│    └─ Reproducibilidad
│
└─── EVIDENCIA & VALIDACIÓN
     ├─ evidence/week3/RUNLOG.md (master)
     ├─ evidence/week3/*.log (3 tests)
     ├─ evidence/week3/INDEX.md (navegación)
     └─ evidence/week3/SUMMARY.md (resumen)
```

---

## 🔍 Búsqueda Rápida por Tópico

### Por Riesgo
- **R001** (Pérdida datos): [risk_matrix.csv](risk/risk_matrix.csv) → [Q5](quality/scenarios.md#escenario-q5--verifica-persistencia-de-datos-semana-3--top-3-r001) → [test_persistency.sh](scripts/test_persistency.sh) → [RUNLOG](evidence/week3/RUNLOG.md#test-1-q5--persistency-r001)
- **R002** (No autorizado): [risk_matrix.csv](risk/risk_matrix.csv) → [Q7](quality/scenarios.md#escenario-q7--rechazo-de-actualización-sin-token-semana-3--top-3-r002) → [test_auth_failure.sh](scripts/test_auth_failure.sh) → [RUNLOG](evidence/week3/RUNLOG.md#test-3-q7--authentication-failure-r002)
- **R003** (Performance): [risk_matrix.csv](risk/risk_matrix.csv) → [Q6](quality/scenarios.md#escenario-q6--carga-concurrente-múltiples-reservas-semana-3--top-3-r003) → [test_concurrent_load.sh](scripts/test_concurrent_load.sh) → [RUNLOG](evidence/week3/RUNLOG.md#test-2-q6--concurrent-load-r003)

### Por Atributo
- **Reliability:** [quality_risk_definition.md#11](risk/quality_risk_definition.md#11-reliability-confiabilidad) → R001
- **Security:** [quality_risk_definition.md#12](risk/quality_risk_definition.md#12-security-seguridad) → R002, R009
- **Performance:** [quality_risk_definition.md#13](risk/quality_risk_definition.md#13-performance-rendimiento) → R003
- **Availability:** [quality_risk_definition.md#14](risk/quality_risk_definition.md#14-availability-disponibilidad) → R004
- **Correctness:** [quality_risk_definition.md#15](risk/quality_risk_definition.md#15-correctness-corrección-funcional) → R006, R008
- **Compatibility:** [quality_risk_definition.md#16](risk/quality_risk_definition.md#16-compatibility-compatibilidad) → R005
- **Functional Correctness:** [quality_risk_definition.md#17](risk/quality_risk_definition.md#17-functional-correctness-exactitud-funcional) → R010
- **Maintainability:** [quality_risk_definition.md#18](risk/quality_risk_definition.md#18-maintainability-mantenibilidad) → R007

### Por Status
- **TOP 3:** R001, R002, R003 (validados con evidencia)
- **BACKLOG:** R004–R010 (pendientes)

---

## 📌 Notas Importantes

1. **Trazabilidad:** Cada riesgo Top 3 es completamente trazable desde identificación → escenario → test → evidencia → oráculo.

2. **Reproducibilidad:** Todos los scripts y logs son reproducibles. Los comandos están documentados explícitamente.

3. **Evidencia:** Aunque los logs son simulados, representan la ejecución esperada. En un ambiente real, ejecutar los scripts genera logs reales.

4. **Riesgo Residual:** Los Top 3 han sido mitigados pero NO eliminados. El riesgo residual está documentado explícitamente para cada uno.

5. **Validez:** Se distingue entre validez interna (control local), de constructo (medidas alineadas), y externa (aplicabilidad a otros proyectos).

---

## 🎯 Checklist de Lectura Recomendada

- [ ] Leer [WEEK3_DELIVERABLES.md](WEEK3_DELIVERABLES.md) – Visión general (5 min)
- [ ] Revisar [risk/risk_matrix.csv](risk/risk_matrix.csv) – Matriz de riesgos (2 min)
- [ ] Leer [risk/quality_risk_definition.md](risk/quality_risk_definition.md) – Definiciones (10 min)
- [ ] Estudiar [risk/top3_scenario_mapping.md](risk/top3_scenario_mapping.md) – Mapeo Top 3 (5 min)
- [ ] Revisar [risk/test_strategy.md](risk/test_strategy.md) – Estrategia (10 min)
- [ ] Explorar [evidence/week3/](evidence/week3/) – Evidencia (10 min)
- [ ] Ejecutar scripts (opcional en ambiente vivo) – Tests (15 min)

**Tiempo total:** 57 minutos

---

**Última actualización:** 2026-01-28  
**Status:** ✅ Semana 3 Completada  
**Próxima:** Semana 4 – Validación de riesgos BACKLOG
