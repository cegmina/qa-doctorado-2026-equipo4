# Reglas de oráculo — GET /booking/{id}

**Endpoint:** `GET /booking/{id}`

**Propósito:** Recuperar los detalles completos de una reserva específica a partir de su identificador único.

**Estructura de respuesta exitosa (HTTP 200):**
```json
{
  "firstname": "string",
  "lastname": "string",
  "totalprice": "number",
  "depositpaid": "boolean",
  "bookingdates": {
    "checkin": "YYYY-MM-DD",
    "checkout": "YYYY-MM-DD"
  },
  "additionalneeds": "string (opcional)"
}
```

---

## Reglas de Oráculo (Pass/Fail)

### OR-001: HTTP Status Code 200 (Oráculo Débil — Mínimo)

**Tipo:** Validación de estado HTTP  
**Condición de Éxito (PASS):**
- La respuesta HTTP contiene código de estado 200.

**Condición de Fallo (FAIL):**
- La respuesta HTTP contiene código de estado diferente a 200 (ej.: 404, 500, 400).

**Justificación:**  
Esta es la regla más básica y fundamental: confirma que el servidor respondió favorablemente a la solicitud. Es el primer filtro que debe cumplirse para cualquier respuesta válida.

---

### OR-002: JSON Response Format Valid (Oráculo Débil)

**Tipo:** Validación de estructura  
**Condición de Éxito (PASS):**
- La respuesta es un objeto JSON válido (parseable).
- El JSON contiene los campos mínimos requeridos: `firstname`, `lastname`, `totalprice`, `depositpaid`, `bookingdates`.

**Condición de Fallo (FAIL):**
- La respuesta no es JSON válido (malformado).
- Faltan campos obligatorios en la estructura.

**Justificación:**  
Garantiza que la respuesta respeta la estructura esperada del contrato API. Es una validación de "forma" esencial antes de analizar contenido.

---

### OR-003: Booking Dates Format (YYYY-MM-DD) (Oráculo Débil)

**Tipo:** Validación de formato de datos  
**Condición de Éxito (PASS):**
- `bookingdates.checkin` tiene formato `YYYY-MM-DD` (ej.: 2025-12-25).
- `bookingdates.checkout` tiene formato `YYYY-MM-DD`.
- Ambas fechas son fechas válidas del calendario.

**Condición de Fallo (FAIL):**
- Al menos una fecha no sigue el formato `YYYY-MM-DD`.
- Al menos una fecha es inválida (ej.: 2025-13-45).

**Justificación:**  
Las fechas de entrada y salida son datos críticos en una reserva. El formato estandarizado es esencial para la interoperabilidad y la serialización consistente.

---

### OR-004: Data Type Consistency (Oráculo Fuerte)

**Tipo:** Validación de tipos de datos  
**Condición de Éxito (PASS):**
- `firstname` es una cadena (string) no vacía.
- `lastname` es una cadena (string) no vacía.
- `totalprice` es un número (integer o float >= 0).
- `depositpaid` es un valor booleano (true o false).
- `additionalneeds` (si está presente) es una cadena (string), incluyendo vacía.

**Condición de Fallo (FAIL):**
- Al menos un campo tiene un tipo de dato incorrecto (ej.: firstname es un número).
- `firstname` o `lastname` están vacíos.
- `totalprice` es negativo.
- `depositpaid` no es booleano.

**Justificación:**  
La consistencia de tipos previene errores de procesamiento en sistemas consumidores. Es una validación de "forma fuerte" que aplica restricciones semánticas.

---

### OR-005: Logical Consistency — Booking Dates (Oráculo Fuerte)

**Tipo:** Validación de consistencia lógica  
**Condición de Éxito (PASS):**
- `bookingdates.checkin` < `bookingdates.checkout` (la fecha de entrada es anterior a la de salida).
- La diferencia entre checkout e checkin es >= 1 día.

**Condición de Fallo (FAIL):**
- `bookingdates.checkin` >= `bookingdates.checkout`.
- La diferencia es menor a 1 día.

**Justificación:**  
En el contexto de una reserva de hospedaje, es lógicamente imposible que la salida sea antes o igual a la entrada. Esta regla valida la semántica del dominio.

---

### OR-006: Retrieval Consistency — Data Integrity (Oráculo Fuerte)

**Tipo:** Validación de integridad de datos  
**Condición de Éxito (PASS):**
- Los datos retornados coinciden exactamente con los datos almacenados (verificado mediante una llamada GET inmediatamente posterior o comparación con el POST/PUT que creó la reserva).
- Ningún campo fue modificado, truncado o distorsionado.

**Condición de Fallo (FAIL):**
- Los datos retornados difieren de los datos esperados.
- Se ha perdido o alterado información (ej.: caracteres especiales en firstname).

**Justificación:**  
Valida que el sistema recupera exactamente lo que almacenó, sin corrupción ni transformaciones no autorizadas. Es esencial para confianza en la integridad del sistema.

---

## Estrategia de Evaluación

- **Oráculos Débiles (OR-001, OR-002, OR-003):** Se aplican en todos los casos para garantizar un nivel mínimo de validez.
- **Oráculos Fuertes (OR-004, OR-005, OR-006):** Se aplican en casos donde se espera lógica más compleja o donde el dominio requiere semántica específica.
- **Combinación:** Para casos de entrada normal, se validan al menos 3 oráculos. Para casos de error o borde, se evalúan según la categoría.

---

## Referencias

- Endpoint: `GET /booking/{id}` — Restful Booker API
- Especificación: https://restfulbooker.herokuapp.com/apidoc/index.html (o documentación local del SUT)
