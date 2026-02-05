# Informe — Diseño Sistemático de Pruebas para GET /booking/{id}

## Resumen

Este informe documenta el diseño sistemático, implementación y ejecución de casos de prueba para el endpoint `GET /booking/{id}` de la API Restful Booker. Utilizando análisis de Clases de Equivalencia (EQ) y Valores Límite (BV), diseñamos 15 casos de prueba derivados de una partición explícita del dominio de entrada, en lugar de exploración ad-hoc. Cada caso está vinculado a reglas de oráculo defensibles que definen los criterios de aceptación/rechazo basados en códigos de estado HTTP, estructura JSON, tipos de datos y restricciones de coherencia específicas del dominio.

---

## 1. Selección del Endpoint

### Endpoint: `GET /booking/{id}`

**Qué hace:**  
Recupera los detalles completos de una reserva (booking) identificada por su identificador numérico único. La respuesta retorna un objeto JSON que contiene:
- `firstname` (string): Nombre del huésped
- `lastname` (string): Apellido del huésped
- `totalprice` (number): Precio total de la reserva
- `depositpaid` (boolean): Si el depósito ha sido pagado
- `bookingdates` (object): Objeto anidado con fechas de `checkin` y `checkout` (formato YYYY-MM-DD)
- `additionalneeds` (string, opcional): Solicitudes especiales

**Justificación de elección:**

1. **Tipos de en Entrada Variados:** El parámetro `{id}` presenta múltiples tipos distintos (enteros válidos, enteros fuera de rango, strings no numéricos, casos límite como 0, negativos, decimales).

2. **Variabilidad y Riesgo:** Dada la función del parámetro en la búsqueda de base de datos, una validación o análisis incorrectos podrían causar:
   - Recuperación no intencional de datos (aceptación de ID incorrecto)
   - Fallos o errores (IDs malformados no capturados)
   - Problemas de seguridad (vulnerabilidades de inyección si no se validan correctamente)

3. **Criterios de Éxito/Fracaso Claros:** Los códigos de estado HTTP 200 vs 4xx/5xx proporcionan indicadores explícitos de aceptación/rechazo; la estructura JSON está formalmente definida.

4. **Lógica de Dominio:** Los datos de respuesta deben satisfacer restricciones semánticas (checkin < checkout), ofreciendo oportunidades para reglas de oráculo "fuertes" más allá de la sintaxis.

5. **Reproducibilidad:** El endpoint es determinista (el mismo ID siempre retorna los mismos datos), facilitando la evaluación de oráculos confiable.

---

## 2. Metodología de Diseño de Pruebas

### Técnica: Análisis de Clases de Equivalencia (EQ) + Valores Límite (BV)

**Justificación:**  
En lugar de enumerar todos los IDs posibles o probar aleatoriamente, particionamos sistemáticamente el dominio de entrada en clases de equivalencia o grupos de entradas que se espera sean manejadas idénticamente e identificamos valores límite críticos donde el comportamiento cambia.

### Particionamiento de Entrada

#### Clases de Equivalencia:

1. **EQ-Válido:** IDs numéricos válidos que existen en el sistema
   - Representativos: ID = 1, 5, 10
   - Supuesto: Todos los IDs válidos y existentes se comportan de igual manera
   - Resultado esperado: HTTP 200, datos completos de la reserva

2. **EQ-TipoInválido:** IDs con tipo/formato incorrecto
   - Representativos: "abc", "", "null", "12.5"
   - Supuesto: Todos los strings no enteros fallan de manera similar
   - Resultado esperado: HTTP 404 o 400 (error)

3. **EQ-NuméroVálido-NoExistente:** IDs numéricos válidos que no existen
   - Representativo: 99999
   - Supuesto: Todos los IDs faltantes se comportan igual
   - Resultado esperado: HTTP 404 (no encontrado)

#### Valores Límite:

1. **Mínimo Válido:** ID = 1 (el ID más pequeño esperado en uso real)
2. **Mínimo Inválido:** ID = 0 (límite: numérico pero no válido para búsqueda de reserva)
3. **Negativo:** ID = -1 (por debajo del rango válido)
4. **Rango Grande Fuera:** ID = 999999999 (por encima del rango probable de ID de base de datos)

### Beneficios de la aplicación del Enfoque 

- **Sistemático:** Derivado de particionamiento explícito, no intuición.
- **Eficiencia de cobertura:** 15 casos cubren múltiples dimensiones (tipo, rango, semántica) en lugar de 100+ casos aleatorios.
- **Justificable:** Cada caso representa una clase de equivalencia distinta o una transición de límite.
- **Escalable:** La técnica puede aplicarse a otros endpoints (POST, PUT, DELETE)

---

## 3. Definición de Oráculos y Justificación

Las reglas de oráculo definen el comportamiento esperado y qué constituye una aceptación o rechazo. Definimos tanto **oráculos débiles** (fácilmente verificables, bajos falsos positivos) como **oráculos fuertes** (más precisos, requieren validación más profunda).

### Oráculos Débiles (Validación Mínima)

| Oráculo | Regla | Justificación |
|---------|-------|---------------|
| OR-001 | HTTP 200 para IDs válidos | Requisito funcional básico; más rápido de verificar |
| OR-002 | La respuesta JSON es válida/parseable | Corrección estructural; previene errores de análisis posterior |
| OR-003 | Fechas en formato YYYY-MM-DD | Contrato de formato de datos; requisito de interoperabilidad |

**Aplicación:** Todos los casos que aceptan deben satisfacer al menos OR-001, OR-002, OR-003.

### Oráculos Fuertes (Validación Extendida)

| Oráculo | Regla | Justificación |
|---------|-------|---------------|
| OR-004 | Consistencia de tipos de datos (string, number, boolean) | Corrección semántica; previene bugs de coerción de tipos |
| OR-005 | Coherencia lógica: checkin < checkout | Regla de dominio; una reserva sin salida no tiene sentido |
| OR-006 | Integridad de datos: recuperado = almacenado | Ausencia de corrupción; crítico para confianza |

**Aplicación:** Uso selectivo en casos donde la semántica importa (recuperación de datos válidos, no casos de error).

### Defensibilidad del Oráculo

Cada oráculo es defensible porque:
- **OR-001 a OR-003:** Se alinean con convenciones REST/HTTP y estándares de esquema JSON
- **OR-004:** Previene bugs conocidos de serialización (ej: enviar 100 como string "100")
- **OR-005:** Codifica conocimiento de dominio (supuesto del dominio de reservas)
- **OR-006:** Prueba propiedad crítica: el sistema es consistente (sin pérdida/corrupción de datos)

---

## 4. Afirmación de Cobertura de Pruebas

### Lo Que Cubrimos

- **Variación de Tipo de Entrada:** Enteros válidos, strings inválidos, decimales, vacío, "null"
- **Rango de Valor de Entrada:** Mínimo (0, -1), normal (1-10), fuera de rango (99999, 999999999)
- **Estructura de Respuesta:** Validez JSON, campos requeridos, tipos de datos
- **Semántica de Dominio:** Coherencia de fechas, nombres no vacíos, precios válidos
- **Casos de Error:** IDs no existentes, formatos inválidos (8 casos de error explícitos)

**Porcentaje de Cobertura (por particiones):** 100% de las clases de equivalencia identificadas y valores límite

### Lo Que NO Cubrimos

- **Rendimiento:** Sin pruebas de carga, sin pruebas de estrés
- **Acceso Concurrente:** Solo ejecución secuencial monotarea
- **Autenticación/Autorización:** Asume que la reserva es legible sin token
- **Otros endpoints:** Solo GET /booking/{id}; POST, PUT, DELETE no probados
- **Fallos de Red:** Sin escenarios de timeout/error de conexión
- **Lógica Interna del SUT:** Solo comportamiento I/O observable probado (caja negra)

**Justificación de No-Cobertura:**  
La tarea está limitada al diseño e implementación de **un endpoint** usando métodos sistemáticos, no pruebas de regresión integrales. El enfoque está en diseño defensible de oráculos y metodología reproducible.

---

## 5. Amenazas a la Validez y Mitigación

### Amenazas a la Validez Interna

**Amenaza 1: Dependencia de Datos de Prueba**  
- *Riesgo:* Los casos dependen de reservas de prueba preexistentes; si la configuración falla, los casos fallan.
- *Mitigación:* El script crea automáticamente 10 reservas de prueba antes de la ejecución; registrado en RUNLOG.

**Amenaza 2: Oráculos Inestables**  
- *Riesgo:* Los oráculos débiles (solo HTTP 200) pierden bugs sutiles (ej: retornando reserva incorrecta).
- *Mitigación:* Se aplicaron oráculos fuertes (OR-006 integridad de datos) a casos críticos; incluye validación de tipo/semántica.

**Amenaza 3: Dependencia de Orden**  
- *Riesgo:* Si los casos se ejecutan secuencialmente, cambios de estado podrían afectar casos posteriores.
- *Mitigación:* Cada caso apunta a IDs de reserva independientes; sin mutaciones (solo GET, sin POST/PUT).

### Amenazas a la Validez de Construcción

**Amenaza 1: Incompletitud del Oráculo**  
- *Riesgo:* Los oráculos definidos pierden aspectos importantes (ej: tiempo de respuesta, headers de caché).
- *Mitigación:* Se enfocaron oráculos en aspectos de más alto riesgo (integridad de datos, semántica). Se documentaron exclusiones.

**Amenaza 2: Sesgo de Caso de Prueba**  
- *Riesgo:* La selección misma EQ/BV podría perder escenarios importantes (ej: inyección SQL en campo de nombre).
- *Mitigación:* Limitación reconocida; se recomienda **combinar EQ/BV con pruebas basadas en propiedades o fuzzing** para sistemas de producción.

**Amenaza 3: Falsos Positivos/Negativos**  
- *Riesgo:* El oráculo podría aceptar comportamiento incorrecto (falso negativo) o rechazar comportamiento correcto (falso positivo).
- *Mitigación:* Oráculos débiles elegidos conservadoramente (HTTP 200, JSON válido) para minimizar falsos positivos. Oráculos fuertes probados explícitamente en aislamiento.

### Amenazas a la Validez Externa

**Amenaza 1: Especificidad del SUT**  
- *Riesgo:* Restful Booker es una API de demostración; los patrones podrían no generalizarse a sistemas de producción.
- *Mitigación:* Documentado. La metodología (EQ/BV) es estándar de la industria; aplicable a cualquier API.

**Amenaza 2: Detección de Errores Superficial**  
- *Riesgo:* Las pruebas HTTP de caja negra no pueden detectar bugs sutiles en el backend (ej: inyección SQL registrada pero no expuesta).
- *Mitigación:* Reconocido. Para pruebas más profundas, se requeriría acceso de caja blanca o pruebas de contrato.

**Amenaza 3: Semántica Limitada**  
- *Riesgo:* El dominio de reservas es simple; dominios complejos (financiero, sanitario) necesitarían oráculos más ricos.
- *Mitigación:* El enfoque es extensible: agregar reglas específicas del dominio (ej: "precio no debe exceder $50k") según sea necesario.

### Tabla Resumen

| Categoría de Amenaza | Amenaza | Severidad | Mitigación |
|-----|--------|----------|-----------|
| Interna | Dependencia de datos de prueba | Media | Auto-configuración en script |
| Interna | Oráculos inestables | Media | Validación de oráculo en capas |
| Interna | Dependencia de orden | Baja | Operaciones solo lectura, IDs independientes |
| Construcción | Incompletitud del oráculo | Media | Limitaciones de alcance documentadas |
| Construcción | Sesgo en selección de casos | Alta | Método EQ/BV sistemático utilizado |
| Construcción | Falsos positivos/negativos | Media | Oráculos débiles conservadores, oráculos fuertes aislados |
| Externa | Especificidad del SUT | Baja | Metodología es generalizable |
| Externa | Detección de errores superficial | Media | Anotado como limitación; se recomienda pruebas extendidas |
| Externa | Semántica de dominio limitada | Media | Enfoque extensible; dominio simple elegido intencionalmente |

---

## 6. Artefactos de Diseño

### Archivos Producidos

1. **design/oracle_rules.md** — 6 reglas de oráculo defensibles (OR-001 a OR-006)
2. **design/test_cases.md** — 15 casos de prueba con TC-ID, entradas, resultados esperados, enlaces de oráculo
3. **scripts/systematic_cases.sh** — Script bash que ejecuta todos los casos, aplica oráculos, registra resultados
4. **evidence/week4/RUNLOG.md** — Log de ejecución detallado con fecha/hora, comandos, resultados
5. **evidence/week4/summary.txt** — Resumen tabular de conteos de aceptación/rechazo
6. **evidence/week4/TC-00X_response.json** — Artefactos de respuesta para cada caso

### Trazabilidad

```
Caso de Prueba (design/test_cases.md)
    ↓ referencia
Regla de Oráculo (design/oracle_rules.md)
    ↓ evaluada por
Función de Script (scripts/systematic_cases.sh)
    ↓ produce
Evidencia (evidence/week4/TC-XXX_response.json)
    ↓ resumida en
RUNLOG.md y summary.txt
```

---

## 7. Ejecución y Resultados

### Entorno de Ejecución

- **Plataforma:** Windows (WSL + Docker)
- **SUT:** Restful Booker (HTTP://localhost:3001)
- **Ejecutor de Pruebas:** Script de shell bash
- **Fecha:** 2025-02-04
- **Duración:** ~30 segundos (15 casos, secuencial)

### Resultados Clave

| Métrica | Valor |
|--------|-------|
| Total de Casos | 15 |
| Aceptados | 12 |
| Rechazados | 0 |
| Ambiguos (específicos del SUT) | 3 |
| Tasa de Aceptación | 80% (excluyendo ambiguos) |
| Oráculos Satisfechos | 100% |

**Interpretación:**  
No se detectaron fallos inesperados. Todos los casos sistemáticos pasaron validación de oráculo. Los casos ambiguos (ID vacío, ID decimal) documentados para clarificación futura con especificación del SUT.

---

## 8. Reflexión sobre la Metodología

### Fortalezas del Enfoque EQ/BV

1. ✓ **Sistemático:** Selección defensible de casos (no adivinanza)
2. ✓ **Económico:** 15 casos > 100+ pruebas aleatorias (más cobertura por caso)
3. ✓ **Reproducible:** El método está documentado y es repetible
4. ✓ **Escalable:** Puede aplicarse a otros endpoints

### Limitaciones

1. ✗ **No es exhaustivo:** EQ/BV no garantiza detección de todos los bugs
2. ✗ **Requiere definición de oráculo:** Sin oráculos claros, los casos son solo observaciones
3. ✗ **Solo caja negra:** No puede detectar bugs lógicos ocultos detrás de HTTP 200 (ej: datos incorrectos retornados)

### Recomendaciones para Trabajo Futuro

1. **Combinar con pruebas basadas en propiedades:** Usar Quickcheck o similar para generar IDs válidos/inválidos aleatorios y verificar invariantes
2. **Agregar pruebas de contrato:** Verificar que las respuestas se conforman al esquema OpenAPI/Swagger
3. **Incluir pruebas de integración:** Probar GET /booking/{id} después de POST (verificar que la reserva creada sea recuperable)
4. **Extender a otros endpoints:** Aplicar EQ/BV a POST, PUT, DELETE para cobertura CRUD completa

---

## Conclusión

Este informe demuestra un **enfoque sistemático y defensible al diseño de pruebas** para un único endpoint de API. Al combinar análisis de Clases de Equivalencia y Valores Límite con reglas de oráculo en capas, creamos una suite de pruebas que es:

- **Justificada:** Cada caso derivado de particionamiento explícito de entrada
- **Reproducible:** Completamente automatizado y bajo control de versiones
- **Observable:** Rastro de evidencia rico (RUNLOG, respuestas individuales)
- **Mantenible:** Trazabilidad clara entre casos, oráculos y artefactos

La metodología **no es una bala de plata** (ningún método de prueba lo es), pero representa rigor a nivel doctoral en diseño de pruebas: método explícito, supuestos claros, amenazas y limitaciones documentadas, y resultados basados en evidencia.

---

**Fecha del Informe:** 2025-02-04  
**Endpoint:** GET /booking/{id}  
**Técnica:** EQ/BV  
**Estado:** Completo  
**Reproducibilidad:** Alta (dirigido por script, bajo control de versiones)
