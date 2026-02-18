# Memo Semana 6: Gaming Drill y Oráculo mínimo obligatorio

**Proyecto:** Restful Booker – QA Actividad Doctoral  
**Equipo:** Grupo 4  
**Semana:** 6

---

## Objetivos

1. Ejecutar un experimento controlado de **gate gaming** (BEFORE/AFTER)
2. Probar que la táctica seleccionada puede alterar el resultado del gate sin mejorar calidad real
3. Documentar evidencia **reproducible y comparable** en `evidence/week6/`
4. Integrar el drill en automatización mediante `make gaming-drill`

---

## Logros principales

### 1. Gaming identificado (explícito)

- Se identificó y aplicó la táctica: **debilitar el oráculo** del Check 2 (Persistencia R001/Q5).
- Implementación del gaming: comentado del bloque de validación de persistencia y comportamiento permisivo del check.
- Impacto esperado: el gate puede reportar mejor estado en ese check sin validar realmente integridad de datos.

### 2. Evidencia BEFORE/AFTER generada (explícito)

- Evidencia BEFORE: `evidence/week6/before/`
- Evidencia AFTER: `evidence/week6/after/`
- Evidencia comparativa consolidada: `evidence/week6/summary.txt`
- Se registraron logs de ejecución, `SUMMARY.md`, `RUNLOG.md` y artefactos de checks en ambos escenarios.

### 3. Defensa aplicada (explícito)

- Se aplicó la táctica **Oráculo mínimo obligatorio → evita que el gate pueda ser “relajado” comentando código o ignorando fallos.**
- En AFTER se ejecutó `make quality-gate || echo "Gate detectó gaming tactic"` y quedó evidencia explícita del intento.
- Se incorporó script obligatorio del drill: `ci/run_gate_gaming_drill.sh`.
- Se integró target obligatorio en Makefile: `gaming-drill`.

### 4. Lección aprendida (explícito)

- **Lección aprendida:** un gate puede “pasar” por diseño permisivo aun cuando la calidad real no mejora; por eso la robustez del oráculo y la evidencia reproducible son críticas para evitar falsas señales de calidad.

---

## Evidencia principal

| Artefacto | Ubicación | Propósito |
|-----------|-----------|-----------|
| Script del drill | `ci/run_gate_gaming_drill.sh` | Ejecutar BEFORE/AFTER de forma reproducible |
| Target make | `makefile` (`gaming-drill`) | Automatizar ejecución del drill |
| BEFORE | `evidence/week6/before/` | Estado previo con táctica aplicada |
| AFTER | `evidence/week6/after/` | Verificación de fallo/detección del intento |
| Resumen semanal | `evidence/week6/summary.txt` | Síntesis comparativa del experimento |
| Runlog semana | `evidence/week6/RUNLOG.md` | Comando exacto, fecha/hora y cambio aplicado |

---

## Resultado del experimento

1. Se ejecutó el drill completo mediante `make gaming-drill`.
2. Se generaron artefactos comparables en `before/` y `after/`.
3. El escenario AFTER evidencia que el gate **falla o marca explícitamente** el intento de gaming.

---

## Retos y notas técnicas

1. Diferencias de entorno Windows/WSL afectaron conectividad a `localhost:3001`.
2. Se estandarizó ejecución para preservar reproducibilidad de la evidencia.
3. Se mantuvo foco en evidencia verificable por archivos y comandos.

---

## Próximos pasos

1. Endurecer el check de persistencia para evitar bypass por comentarios o valores forzados.
2. Agregar validaciones automáticas anti-manipulación en CI.
3. Consolidar criterios de aceptación del gate para minimizar falsos PASS.

---

## Checklist de entregables

- [x] Script `ci/run_gate_gaming_drill.sh` implementado
- [x] Target `make gaming-drill` agregado
- [x] Evidencia `before/` y `after/` generada
- [x] `evidence/week6/summary.txt` generado
- [x] `memos/week6_memo.md` actualizado con formato del curso

---

**Memo completado:** 18 de febrero de 2026  
**Estado:** Listo para revisión  
**Responsable de follow-up:** Equipo
