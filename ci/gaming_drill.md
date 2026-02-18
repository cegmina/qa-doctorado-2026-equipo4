# Gaming Drill — Quality Gate (Semana 5)

## Táctica elegida

**Reducir el conjunto de casos: ejecutar menos tests sin declararlo.**

## Check del gate que afecta

**Check 2: Persistencia de datos (R001 / Q5)**, definido en `ci/quality_gates.md` y ejecutado por `ci/run_quality_gates.sh` en la sección de persistencia (`GET /booking/{id}` + validación de campos JSON).

## Por qué “haría pasar” sin mejorar calidad

Si se reduce el alcance de la validación de persistencia (por ejemplo, evitando validaciones completas del JSON o desactivando parte del check), disminuye la probabilidad de detectar defectos de integridad de datos.
El gate podría verse como **PASS** al registrar una ejecución “limpia” del check de persistencia, pero el riesgo real no baja: solo se debilitó el oráculo y se ocultaron fallos funcionales.
En resumen, mejora o mantiene el indicador del gate, pero no la calidad del SUT.
