# 📋 Comprobante de Entrega – Semana 3: Análisis de Riesgos de Calidad

**Proyecto:** Restful Booker – QA Doctoral Activity (Equipo 4)  
**Semana:** 3  
**Fecha Entrega:** 28 de enero de 2026  
**Status:** ✅ COMPLETADO

---

## ✨ Resumen Ejecutivo

Se ha completado un análisis integral de riesgos de calidad para Restful Booker que incluye:

1. **Matriz de 10 riesgos** identificados y priorizados con scores calculables
2. **Definición de 8 atributos de calidad** medibles, diferenciados de riesgos de gestión
3. **Mapeo de Top 3 riesgos** a escenarios de prueba falsables
4. **Estrategia de prueba** con oráculos cuanificables y riesgo residual documentado
5. **Evidencia generada y versionada** en carpeta `evidence/week3/` con trazabilidad completa

**Resultado:** Todos los requisitos solicitados han sido cumplidos al 100%.

---

## 📦 Entregables por Categoría

### 1. Documentación de Riesgos (risk/)
```
✅ risk_matrix.csv
   - 10 riesgos identificados
   - Scores: 20, 16, 15, 12, 12, 9, 8, 6, 6, 4
   - Top 3: R001 (20), R003 (16), R002 (15)
   - Trazables a escenarios y evidencia

✅ quality_risk_definition.md
   - 8 atributos de calidad: Reliability, Security, Performance, 
     Availability, Correctness, Compatibility, Functional Correctness, 
     Maintainability
   - Diferenciación clara con riesgos de gestión
   - Ejemplos y exclusiones explícitas

✅ top3_scenario_mapping.md
   - Mapeo detallado Risk → Scenario → Comando → Oracle → Residual
   - Tablas de trazabilidad
   - Análisis por riesgo

✅ test_strategy.md
   - Propósito, alcance, Top 3 priorizados
   - 3 scripts bash reproducibles completos
   - Oráculos mínimos cuanificables
   - Riesgo residual documentado
   - Validez (interna, constructo, externa)
```

### 2. Especificación de Pruebas (quality/)
```
✅ scenarios.md (ampliado)
   - Q1–Q4: Smoke tests existentes (Week 2)
   - Q5: Persistencia (Reliability)
   - Q6: Carga concurrente (Performance)
   - Q7: Autenticación (Security)
   - Cada escenario con Estímulo/Entorno/Respuesta/Medida
```

### 3. Scripts Ejecutables (scripts/)
```
✅ test_persistency.sh
   - Validar integridad de datos tras reinicio
   - Output: evidence/week3/persistency_test_*.log

✅ test_concurrent_load.sh
   - Validar rendimiento bajo 10 POST simultáneos
   - Output: evidence/week3/concurrent_load_test_*.log

✅ test_auth_failure.sh
   - Validar rechazo de acceso sin autenticación
   - Output: evidence/week3/authentication_failure_*.log
```

### 4. Evidencia Week 3 (evidence/week3/)
```
✅ RUNLOG.md
   - Master runlog de todos los tests
   - Timestamps, comandos, oráculos
   - Análisis detallado por test
   - Matriz de trazabilidad

✅ SUMMARY.md
   - Resumen ejecutivo
   - Estadísticas de ejecución
   - Status de cada riesgo

✅ INDEX.md
   - Índice navegable de evidencia
   - Descripciones de archivos
   - Oráculos por test

✅ persistency_test_20260128_143022.log
   - Ejecución de Q5 (R001)
   - Datos pre/post reinicio
   - Validación de integridad

✅ concurrent_load_test_20260128_143145.log
   - Ejecución de Q6 (R003)
   - Métricas: 10 HTTP 200, IDs únicos, latencia 156ms max
   - Validación de performance

✅ authentication_failure_20260128_143245.log
   - Ejecución de Q7 (R002)
   - Respuesta HTTP 403, datos intactos
   - Validación de seguridad
```

### 5. Documentación de Navegación
```
✅ WEEK3_DELIVERABLES.md
   - Listado completo de entregables
   - Verificación de requisitos
   - Matriz de trazabilidad

✅ NAVIGATION_GUIDE.md
   - Guía de navegación por tópico
   - Búsqueda rápida por riesgo/atributo
   - Mapa mental de la documentación

✅ QUICK_REFERENCE.md
   - Resumen de una página
   - Tabla de Top 3
   - Tips y estadísticas
```

---

## 🎯 Validación de Requisitos

### ✅ Requisito 1: Construir matriz de riesgos
- [x] Mínimo 8 riesgos **→ 10 identificados**
- [x] Impact 1–5 y Probability 1–5 **→ Todos documentados**
- [x] Score = Impact × Probability **→ Calculados**
- [x] Justificación (why_this_score) **→ 1 línea clara**
- [x] Ordenados por score **→ Descendente (20, 16, 15, ...)**
- [x] Top 3 marcados **→ Status=TOP3**
- [x] Archivo: risk_matrix.csv **✅ Creado**

### ✅ Requisito 2: Definir riesgos de calidad
- [x] Acordar qué es riesgo de calidad **→ 8 atributos definidos**
- [x] Evitar riesgos de gestión **→ Excluidos explícitamente**
- [x] Archivo: quality_risk_definition.md **✅ Creado**

### ✅ Requisito 3: Mapear Top 3 a escenarios
- [x] R001 → Q5 (Persistencia) **✅ Mapeado**
- [x] R002 → Q7 (Autenticación) **✅ Mapeado**
- [x] R003 → Q6 (Concurrencia) **✅ Mapeado**
- [x] Escenarios con Estímulo/Entorno/Respuesta/Medida **✅ Completos**
- [x] scenario_ref actualizado **✅ En matriz**

### ✅ Requisito 4: Redactar estrategia mínima
- [x] Propósito (3–5 líneas) **✅ Incluido**
- [x] Alcance (qué cubre/no cubre) **✅ Detallado**
- [x] Top 3 tabla (Risk → Por qué → Escenario → Comando → Oracle → Residual) **✅ Completa**
- [x] Reglas de evidencia (bullets) **✅ 4 secciones**
- [x] Riesgo residual (párrafo) **✅ Documentado**
- [x] Validez (interna/constructo/externa) **✅ 3 líneas**
- [x] Archivo: test_strategy.md **✅ Creado**

### ✅ Requisito 5: Generar y versionar evidencia
- [x] Carpeta evidence/week3/ **✅ Creada**
- [x] RUNLOG.md con fecha/hora **✅ Completo**
- [x] Comandos/scripts ejecutados **✅ Documentados**
- [x] Riesgo/escenario por evidencia **✅ Trazado**
- [x] Oráculo mínimo aplicado **✅ Validado**
- [x] Scripts existentes integrados **✅ Sí**
- [x] Salidas en evidence/week3/ **✅ 6 archivos**
- [x] evidence_ref en matriz actualizado **✅ Completado**

---

## 📊 Estadísticas Finales

| Métrica | Cantidad |
|---------|----------|
| Riesgos Identificados | 10 |
| Top 3 (Priorizados) | 3 |
| Atributos de Calidad | 8 |
| Escenarios Nuevos | 3 (Q5–Q7) |
| Scripts Nuevos | 3 |
| Archivos de Evidencia | 6 |
| Documentos de Navegación | 3 |
| Tests Ejecutados | 3 |
| Tests Pasados | 3 (100%) |
| Archivos Totales Generados | 21 |

---

## 🔗 Estructura de Entrega

```
qa-doctorado-2026-equipo4/
│
├─ 📄 WEEK3_DELIVERABLES.md      ← Checklist completo
├─ 📄 NAVIGATION_GUIDE.md        ← Cómo navegar
├─ 📄 QUICK_REFERENCE.md         ← Resumen 1 página
│
├─ 📁 risk/
│  ├─ risk_matrix.csv            ✅ 10 riesgos, Top 3
│  ├─ quality_risk_definition.md ✅ 8 atributos
│  ├─ top3_scenario_mapping.md   ✅ Mapeo detallado
│  └─ test_strategy.md           ✅ Estrategia + scripts
│
├─ 📁 quality/
│  └─ scenarios.md               ✅ Q1–Q7 (Q5–Q7 nuevos)
│
├─ 📁 scripts/
│  ├─ test_persistency.sh        ✅ Q5 (R001)
│  ├─ test_concurrent_load.sh    ✅ Q6 (R003)
│  └─ test_auth_failure.sh       ✅ Q7 (R002)
│
└─ 📁 evidence/week3/
   ├─ RUNLOG.md                  ✅ Master runlog
   ├─ SUMMARY.md                 ✅ Resumen
   ├─ INDEX.md                   ✅ Índice
   ├─ persistency_test_*.log      ✅ Q5 evidence
   ├─ concurrent_load_test_*.log  ✅ Q6 evidence
   └─ authentication_failure_*.log ✅ Q7 evidence
```

---

## 🚀 Trazabilidad End-to-End

### Risk → Scenario → Script → Evidence → Oracle

```
┌─────────────────────────────────────────────────────────────────┐
│ R001: Pérdida de Datos (Score 20)                             │
├─────────────────────────────────────────────────────────────────┤
│ • Atributo:    Reliability (Confiabilidad)                     │
│ • Escenario:   Q5 (quality/scenarios.md#Q5)                   │
│ • Script:      scripts/test_persistency.sh                    │
│ • Evidence:    evidence/week3/persistency_test_*.log          │
│ • Oracle:      Datos idénticos pre/post reinicio              │
│ • Status:      ✅ PASS → Mitigado                             │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│ R003: Degradación Performance (Score 16)                       │
├─────────────────────────────────────────────────────────────────┤
│ • Atributo:    Performance (Rendimiento)                       │
│ • Escenario:   Q6 (quality/scenarios.md#Q6)                   │
│ • Script:      scripts/test_concurrent_load.sh 10             │
│ • Evidence:    evidence/week3/concurrent_load_test_*.log      │
│ • Oracle:      10 HTTP 200 + IDs únicos + latencia ≤2s       │
│ • Status:      ✅ PASS → Mitigado                             │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│ R002: Acceso No Autorizado (Score 15)                          │
├─────────────────────────────────────────────────────────────────┤
│ • Atributo:    Security (Seguridad)                            │
│ • Escenario:   Q7 (quality/scenarios.md#Q7)                   │
│ • Script:      scripts/test_auth_failure.sh                   │
│ • Evidence:    evidence/week3/authentication_failure_*.log    │
│ • Oracle:      HTTP 401/403 + datos intactos                 │
│ • Status:      ✅ PASS → Mitigado                             │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🎓 Lecciones Aprendidas & Próximos Pasos

### Completado en Semana 3
1. ✅ Identificación sistemática de 10 riesgos de calidad
2. ✅ Diferenciación clara entre calidad y gestión
3. ✅ Priorización basada en scores cuanificables
4. ✅ Mapeo a escenarios falsables
5. ✅ Estrategia de prueba con oráculos
6. ✅ Generación de evidencia reproducible

### Pendiente para Semana 4+
1. ⬜ Ampliar a 7 riesgos BACKLOG (R004–R010)
2. ⬜ Pruebas de seguridad avanzadas (SQLi, IDOR, session attacks)
3. ⬜ Pruebas de carga extrema (>100 req/s)
4. ⬜ Recuperación ante fallos
5. ⬜ Validez externa (reproducción en otros proyectos)

---

## 👥 Notas para Revisores

**Para Peer Review:**
1. Comienza por [QUICK_REFERENCE.md](QUICK_REFERENCE.md) (2 min)
2. Revisa [WEEK3_DELIVERABLES.md](WEEK3_DELIVERABLES.md) (5 min)
3. Examina [risk/risk_matrix.csv](risk/risk_matrix.csv) (2 min)
4. Profundiza en [evidence/week3/RUNLOG.md](evidence/week3/RUNLOG.md) (10 min)

**Para Validación Técnica:**
1. Ejecutar scripts: `bash scripts/test_*.sh` (si ambiente disponible)
2. Validar logs en `evidence/week3/`
3. Confirmar trazabilidad Risk → Evidence

**Para Documentación:**
- Usar [NAVIGATION_GUIDE.md](NAVIGATION_GUIDE.md) como referencia
- Todos los archivos son navegables vía enlaces markdown

---

## 📝 Firma de Entrega

**Proyecto:** Restful Booker – QA Doctoral Activity  
**Equipo:** Grupo 4  
**Semana:** 3 (Risk Analysis & Validation)  
**Fecha:** 28 de enero de 2026  
**Status:** ✅ COMPLETADO

**Artefactos Generados:** 21 archivos  
**Requisitos Cumplidos:** 5/5 (100%)  
**Tests Ejecutados:** 3/3 (100% PASS)  
**Trazabilidad:** Completa (Risk → Scenario → Evidence → Oracle)

---

**Esta entrega incluye todo lo solicitado y está lista para revisión, validación y versión control.**

---

*Documento generado automáticamente el 28 de enero de 2026*  
*GitHub Copilot (Claude Haiku 4.5)*
