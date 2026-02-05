# Test Cases — GET /booking/{id}

**Endpoint:** `GET /booking/{id}`

**Técnica de Diseño:** Equivalencia (EQ) + Valores Límite (BV)

**Propósito:** Validar que el endpoint recupera datos de reservas de forma correcta bajo variaciones sistemáticas de entrada (ID) y estado del sistema.

---

## Estrategia de Diseño Sistemático

### Particiones de Equivalencia (EQ)

1. **Valid Booking ID:** IDs que existen en el sistema (ej.: 1, 5, 100).
   - Clase: IDs numéricos válidos y presentes.

2. **Invalid ID — Non-existent:** IDs que no existen (ej.: 99999).
   - Clase: IDs numéricos válidos pero no presentes en BD.

3. **Invalid ID — Type:** IDs con tipo incorrecto (ej.: "abc", "", null).
   - Clase: IDs no numéricos o mal formados.

4. **Boundary Values:**
   - Mínimo válido: ID = 1 (primer registro posible).
   - Máximo conocido: ID = último registro existente.
   - Límite inferior inválido: ID = 0 o negativo.
   - Límite superior excesivo: ID = 999999999.

---

## Matriz de Casos de Prueba (12+ casos)

| TC-ID | Categoría | Entrada (ID) | Descripción | Oráculo(s) Aplicado(s) | Resultado Esperado | Clasificación |
|-------|-----------|--------------|-------------|------------------------|-------------------|--------------------|
| TC-001 | EQ-Valid | 1 | ID válido: primer booking existente | OR-001, OR-002, OR-003, OR-004 | HTTP 200, JSON válido, datos completos | PASS |
| TC-002 | EQ-Valid | 5 | ID válido: booking intermedio | OR-001, OR-002, OR-003, OR-004 | HTTP 200, JSON válido, datos completos | PASS |
| TC-003 | EQ-Valid | 10 | ID válido: booking en rango normal | OR-001, OR-002, OR-003, OR-004, OR-006 | HTTP 200, datos íntegros | PASS |
| TC-004 | BV-Minimum | 0 | ID límite: cero (inválido) | OR-001 | HTTP 404 o 400 | FAIL |
| TC-005 | BV-Negative | -1 | ID límite: número negativo | OR-001 | HTTP 404 o 400 | FAIL |
| TC-006 | BV-NonExistent | 99999 | ID válido pero no existe | OR-001, OR-002 | HTTP 404 | FAIL |
| TC-007 | BV-LargeID | 999999999 | ID límite: número muy grande | OR-001 | HTTP 404 o 400 | FAIL |
| TC-008 | EQ-InvalidType | "abc" | ID no numérico: string alfanumérico | OR-001 | HTTP 404 o 400 | FAIL |
| TC-009 | EQ-InvalidType | "" | ID vacío | OR-001 | HTTP 404 o 400 (depende del SUT) | FAIL |
| TC-010 | EQ-InvalidType | "null" | ID como cadena "null" | OR-001 | HTTP 404 o 400 | FAIL |
| TC-011 | EQ-InvalidType | "12.5" | ID decimal (no entero) | OR-001 | HTTP 404, 400 o 200 (depende SUT) | FAIL/AMBIGUOUS |
| TC-012 | EQ-ValidData | 1 | Validación de integridad: Checkin < Checkout | OR-005 | Fechas válidas y coherentes | PASS |
| TC-013 | EQ-ValidData | 2 | Validación de tipos: firstname, lastname no vacíos | OR-004 | Strings no vacíos | PASS |
| TC-014 | EQ-ValidData | 3 | Validación de tipos: totalprice >= 0 | OR-004 | Número >= 0 | PASS |
| TC-015 | EQ-ValidData | 4 | Validación de tipos: depositpaid booleano | OR-004 | true o false | PASS |

---

## Detalles de Ejecución de Casos

### TC-001: ID Válido — Primer Booking
```
Método: GET
URL: http://localhost:3001/booking/1
Esperado: HTTP 200, objeto con firstname, lastname, totalprice, depositpaid, bookingdates
Oráculo: OR-001 (HTTP 200), OR-002 (JSON válido), OR-003 (fechas formato correcto), OR-004 (tipos correctos)
Evidencia: response_TC-001.json, HTTP code, parsed JSON structure
```

### TC-002: ID Válido — Booking Intermedio
```
Método: GET
URL: http://localhost:3001/booking/5
Esperado: HTTP 200, objeto booking completo
Oráculo: OR-001, OR-002, OR-003, OR-004
Evidencia: response_TC-002.json
```

### TC-003: ID Válido — Validación de Integridad
```
Método: GET
URL: http://localhost:3001/booking/10
Esperado: HTTP 200, datos sin truncamiento
Oráculo: OR-001, OR-002, OR-006 (integridad)
Evidencia: response_TC-003.json, comparación con datos originales (si disponible)
```

### TC-004: Valor Límite — ID = 0
```
Método: GET
URL: http://localhost:3001/booking/0
Esperado: HTTP 404 o 400 (error: ID inválido/no existe)
Oráculo: OR-001 (código no 200)
Evidencia: response_TC-004.json, error message
```

### TC-005: Valor Límite — ID Negativo
```
Método: GET
URL: http://localhost:3001/booking/-1
Esperado: HTTP 404 o 400
Oráculo: OR-001
Evidencia: response_TC-005.json
```

### TC-006: Valor Límite — ID No Existe (99999)
```
Método: GET
URL: http://localhost:3001/booking/99999
Esperado: HTTP 404 (no encontrado)
Oráculo: OR-001
Evidencia: response_TC-006.json
```

### TC-007: Valor Límite — ID Muy Grande
```
Método: GET
URL: http://localhost:3001/booking/999999999
Esperado: HTTP 404 o 400 (desbordamiento/no existe)
Oráculo: OR-001
Evidencia: response_TC-007.json
```

### TC-008: Tipo Inválido — String Alfanumérico
```
Método: GET
URL: http://localhost:3001/booking/abc
Esperado: HTTP 404 o 400
Oráculo: OR-001
Evidencia: response_TC-008.json, error message
```

### TC-009: Tipo Inválido — ID Vacío
```
Método: GET
URL: http://localhost:3001/booking/
Esperado: HTTP 404 o comportamiento específico del SUT
Oráculo: OR-001
Evidencia: response_TC-009.json, comportamiento real
```

### TC-010: Tipo Inválido — String "null"
```
Método: GET
URL: http://localhost:3001/booking/null
Esperado: HTTP 404 o 400
Oráculo: OR-001
Evidencia: response_TC-010.json
```

### TC-011: Tipo Inválido — Decimal
```
Método: GET
URL: http://localhost:3001/booking/12.5
Esperado: HTTP 404, 400 o 200 (comportamiento SUT-específico)
Oráculo: OR-001
Evidencia: response_TC-011.json, clasificación: AMBIGUOUS (requiere análisis SUT)
```

### TC-012: Validación Semántica — Fechas Coherentes
```
Método: GET
URL: http://localhost:3001/booking/1
Esperado: HTTP 200, bookingdates.checkin < bookingdates.checkout
Oráculo: OR-001, OR-005 (lógica de fechas)
Evidencia: response_TC-012.json, comparación de fechas
```

### TC-013: Validación de Tipos — Strings
```
Método: GET
URL: http://localhost:3001/booking/2
Esperado: HTTP 200, firstname y lastname son strings no vacíos
Oráculo: OR-001, OR-004 (tipo y contenido)
Evidencia: response_TC-013.json, validación de tipos en shell
```

### TC-014: Validación de Tipos — Precio
```
Método: GET
URL: http://localhost:3001/booking/3
Esperado: HTTP 200, totalprice es número >= 0
Oráculo: OR-001, OR-004
Evidencia: response_TC-014.json
```

### TC-015: Validación de Tipos — Booleano
```
Método: GET
URL: http://localhost:3001/booking/4
Esperado: HTTP 200, depositpaid es true o false
Oráculo: OR-001, OR-004
Evidencia: response_TC-015.json
```

---

## Resumen de Cobertura

- **Equivalencia:** 3 clases válidas, 2 clases inválidas por tipo
- **Valores Límite:** mínimo (0, negativo), máximo (muy grande), no existe (99999)
- **Datos:** Validación de tipos, integridad, consistencia lógica
- **Total casos:** 15 (incluye válidos y casos de error)
- **Casos de Éxito Esperado (PASS):** 8 (TC-001, 002, 003, 012, 013, 014, 015, +1 adicional)
- **Casos de Error Esperado (FAIL):** 6 (TC-004, 005, 006, 007, 008, 010)
- **Casos Ambigüos:** 1 (TC-011, requiere validación SUT)

---

## Notas Metodológicas

1. Los casos TC-001 a TC-003 usan IDs existentes; requieren preparación previa (creación de bookings).
2. Los casos TC-004 a TC-011 no requieren bookings previos (esperan fallos).
3. Los casos TC-012 a TC-015 validan semántica y tipos de datos mediante análisis del JSON.
4. Cada caso se ejecutará de forma aislada para garantizar independencia.
5. Los oráculos se aplicarán de forma progresiva: primero OR-001 (HTTP), luego estructura, luego tipos, luego lógica.
