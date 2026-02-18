## 2026-02-17 — Aplicación de oráculo mínimo obligatorio

### Resumen del cambio
Se incorpora una regla de **cumplimiento obligatorio** para el control R001/Q5.  
El objetivo es impedir que el gate acepte ejecuciones que aparentan éxito cuando la validación de persistencia fue deshabilitada o alterada.

### Problema detectado
Durante el drill de gaming se observó que, en el escenario **BEFORE**, era posible producir un `PASS` sin validar la persistencia real del sistema.

Esto podía ocurrir, por ejemplo, cuando:
- Se comentaba el check de persistencia.
- Se dejaban marcadores de bypass/gaming.
- Se alteraba la evidencia de ejecución para simular cumplimiento.

### Regla técnica aplicada
El gate ahora marca **FAIL** automáticamente si detecta cualquiera de estas condiciones:
- Manipulación del check de persistencia.
- Evidencia inconsistente con una ejecución real.
- Indicios de bypass explícito del oráculo mínimo.

En otras palabras: **sin validación efectiva de persistencia, no hay PASS**.

### Justificación de calidad
Este ajuste elimina falsos positivos de calidad y fortalece la confiabilidad del resultado del pipeline.

Sin esta defensa, el gate podía comunicar una señal engañosa al equipo (aparente conformidad), ocultando un riesgo funcional crítico.

### Impacto esperado
- Mayor robustez frente a estrategias de gate gaming.
- Trazabilidad más clara entre ejecución, evidencia y decisión del gate.
- Reducción de resultados “aparentemente correctos” sin sustento técnico.

### Alcance
Aplica específicamente al control R001/Q5 y a la validación de persistencia asociada en el flujo de CI.

### Evidencia relacionada
- `evidence/week6/before/`
- `evidence/week6/after/`
- `evidence/week6/summary.txt`
