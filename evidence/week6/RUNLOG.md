# RUNLOG — Experimento BEFORE (Semana 6)

## Comparativo rápido (BEFORE vs AFTER)

### BEFORE — Sin defensa anti-gaming
- Estado esperado: **PASS aparente**
- Método: debilitamiento del oráculo en persistencia (Check 2)
- Riesgo: señal de calidad engañosa

### AFTER — Con defensa activa
- Estado esperado: **FAIL**
- Método: oráculo mínimo obligatorio que no se puede “relajar” sin registro, detección de manipulación/comentado del check.
- Beneficio: evita aprobación sin validación real

## Objetivo
Demostrar, de forma reproducible, la ejecución del quality gate con la táctica de gaming aplicada en el escenario BEFORE.

## Preparación de evidencia
- Carpeta utilizada: `evidence/week6/before/`
- Regla aplicada: el BEFORE debe ser verificable con archivos y comandos, no solo con texto descriptivo.

## ===== ESCENARIO BEFORE =====

## Ejecución del experimento

### Comando exacto
bash ./ci/run_gate_gaming_drill.sh

### Qué ejecuta realmente ese comando
El script `run_gate_gaming_drill.sh` **no** ejecuta únicamente el gate normal; orquesta un experimento BEFORE/AFTER completo:
- Toma una copia de resguardo del gate original (`ci/run_quality_gates.sh`).
- Construye una versión temporal “gamificada” para BEFORE, comentando el bloque del Check 2 (persistencia) e inyectando resultado permisivo.
- Ejecuta BEFORE con esa versión temporal para demostrar el bypass del oráculo.
- Restaura el gate original antes de correr AFTER.
- En AFTER aplica validación anti-gaming (marcadores/evidencia de manipulación) y fuerza FAIL si detecta relajación del oráculo.

> Importante: la manipulación se realiza sobre una **copia temporal de trabajo** dentro del drill; el archivo base `ci/run_quality_gates.sh` se respalda y se restaura.

### Comandos exactos utilizados
- Comando principal ejecutado manualmente:
	- `bash ./ci/run_gate_gaming_drill.sh`
- Comando base que el drill usa para correr el gate (BEFORE y AFTER):
	- `OUT_DIR=<before|after> BASE_URL=http://localhost:3001 SKIP_SUT_START=1 RELAX_SYSTEMATIC_CHECK=1 bash ./ci/run_quality_gates.sh`
- Variante usada cuando corre con Git Bash en Windows/WSL (runner `git-bash-exe`):
	- `"C:\Program Files\Git\bin\bash.exe" -lc "cd '<ruta_del_proyecto>' && OUT_DIR='<before|after>' BASE_URL='http://localhost:3001' SKIP_SUT_START='1' RELAX_SYSTEMATIC_CHECK='1' bash './ci/run_quality_gates.sh'"`

> Nota: `<before|after>` se reemplaza por `evidence/week6/before` o `evidence/week6/after` según el escenario.

### Fecha/hora
2026-02-17 15:56:57 -04:00

### Qué cambió para "pasar"
Se aplicó la táctica **Debilitar el oráculo** en el Check 2 (persistencia): el bloque de validación de persistencia quedó comentado y el gate usa un resultado permisivo para ese check (no bloqueante), reduciendo el poder de detección real.

### Detalle técnico de la manipulación en BEFORE
- Se encapsula temporalmente el bloque de Check 2 en un marcador de comentario (heredoc), dejando el check sin ejecución real.
- Se escriben valores sintéticos de éxito para ese check (por ejemplo `HTTP2="200"` y `RESULT: PASS`).
- Se deja rastro explícito en evidencia (`CHECK 2 comentado por gaming drill`) para que AFTER pueda detectarlo.

## Evidencia generada (verificable)
Archivos existentes en `evidence/week6/before/`:
- `SUMMARY.md`
- `RUNLOG.md`

## Verificación reproducible por comandos
Comandos sugeridos para verificar el BEFORE:
- `Get-ChildItem evidence/week6/before`
- `Get-Content evidence/week6/before/SUMMARY.md`
- `Get-Content evidence/week6/before/RUNLOG.md`

## ===== ESCENARIO AFTER (DETECCIÓN) =====

### Resultado esperado
- Estado: **FAIL**
- Motivo: Oráculo mínimo obligatorio que no se puede “relajar” sin registro; se detecta intento de gaming cuando el test de persistencia fue comentado en el BEFORE o existe marcador de manipulación.

### Detalle técnico en AFTER (qué se valida y qué código se agrega)
- **Sobre qué archivo se trabaja:** sobre la copia temporal usada por el drill y luego con restauración del gate original antes del AFTER.
- **Qué quedó comentado desde BEFORE:** el bloque de persistencia (Check 2) fue encapsulado/comentado temporalmente mediante marcador heredoc (`GAMED_CHECK2`), dejando traza en evidencia.
- **Qué se agrega para AFTER:** una validación explícita anti-gaming que evalúa marcadores y evidencia del BEFORE (por ejemplo `contains_commented_test_markers` y `detected_before_gaming_evidence`).

```bash
contains_commented_test_markers() {
	local file_path="$1"
	grep -qE "COMMENTED_OUT|GAMED_CHECK2|CHECK 2 comentado manualmente" "${file_path}"
}
```

- **Acción al detectar manipulación:** se escribe `AFTER FAIL` en `evidence/week6/after/RUNLOG.md` y `SUMMARY.md`, se marca `runner=validation-only` y se retorna `rc=1`.

### Comandos exactos en AFTER
- Ejecución del gate en AFTER:
	- `OUT_DIR=evidence/week6/after BASE_URL=http://localhost:3001 SKIP_SUT_START=1 RELAX_SYSTEMATIC_CHECK=1 bash ./ci/run_quality_gates.sh`
- Validación previa anti-gaming (lógica del drill):
	- detección de marcadores de test comentado en `ci/run_quality_gates.sh`
	- detección de rastro `CHECK 2 comentado por gaming drill` en `evidence/week6/before/RUNLOG.md`

### Evidencia generada (verificable)
Archivos existentes en `evidence/week6/after/`:
- `SUMMARY.md`
- `RUNLOG.md`

### Verificación reproducible por comandos
Comandos sugeridos para verificar el AFTER:
- `Get-ChildItem evidence/week6/after`
- `Get-Content evidence/week6/after/SUMMARY.md`
- `Get-Content evidence/week6/after/RUNLOG.md`

## Táctica utilizada
- **Gaming en BEFORE:** Debilitar el oráculo del Check 2 (persistencia), comentando temporalmente la validación para que el gate pase sin aumentar calidad real.
- **Defensa en AFTER:** Oráculo mínimo obligatorio → evita que el gate pueda ser “relajado” comentando código o ignorando fallos.

## Resultado
El experimento queda trazable y auditable en ambos escenarios: BEFORE (PASS por táctica de gaming) y AFTER (FAIL por detección/Oráculo mínimo obligatorio).

### Nota de trazabilidad
El objetivo del documento es dejar explícito que el PASS en BEFORE proviene de una modificación temporal controlada del gate, mientras que el FAIL en AFTER confirma que la defensa detecta esa relajación y evita aceptación engañosa.

## Lectura rápida
- Si el check de persistencia se debilita (BEFORE), el resultado puede parecer correcto sin garantizar calidad real.
- Si se aplica la defensa (AFTER), el gate bloquea el resultado y deja evidencia explícita del intento de relajación.
