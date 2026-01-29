# Mapeo Top 3 Riesgos → Escenarios de Calidad (Semana 3)

## Objetivo
Vincular cada riesgo crítico (Top 3) con un escenario de prueba específico que valide la mitigación del riesgo mediante casos de prueba falsables y medibles.

---

## TOP 3 Risk Mapping

### 1. R001 – Pérdida de datos de reservas (Score: 20)
**Atributo:** Reliability  
**Causa raíz:** Fallo de persistencia o corrupción de datos durante transacciones

#### Escenario Asociado: [Q5 – Verifica persistencia de datos](../quality/scenarios.md#Q5)

| Elemento | Descripción |
|----------|-------------|
| **Estímulo** | 1. Crear reserva con POST /booking<br>2. Obtener ID (ej: 42)<br>3. Verificar con GET /booking/42<br>4. **Detener SUT** (parar servicio)<br>5. **Reiniciar SUT** (iniciar servicio)<br>6. Consultar nuevamente GET /booking/42 |
| **Entorno** | Ejecución local, SUT con persistencia en base de datos, reinicio completo del servicio |
| **Respuesta Esperada** | El SUT recupera la reserva exactamente como fue creada después del reinicio |
| **Medida (Falsable)** | ✅ POST devuelve HTTP 200 con ID único<br>✅ GET antes del reinicio: HTTP 200 + objeto con firstname="Grupo-4"<br>✅ Tras reinicio: GET /booking/42 devuelve HTTP 200<br>✅ Campos idénticos (firstname, lastname, totalprice, bookingdates)<br>✅ No hay diferencia antes/después |
| **Evidencia** | `evidence/week3/persistency_test.log` |
| **Pasa si** | Los datos persisten sin corrupción tras reinicio |
| **Falla si** | El ID no existe, datos diferentes, o GET devuelve 404 |

---

### 2. R003 – Degradación de performance bajo carga concurrente (Score: 16)
**Atributo:** Performance  
**Causa raíz:** Falta de manejo de conexiones concurrentes o índices en base de datos

#### Escenario Asociado: [Q6 – Carga concurrente múltiples reservas](../quality/scenarios.md#Q6)

| Elemento | Descripción |
|----------|-------------|
| **Estímulo** | Lanzar **10 peticiones POST /booking simultáneamente** desde múltiples procesos/hilos en paralelo:<br>Cada una crea una reserva con datos distintos (Grupo-4-1, Grupo-4-2, ..., Grupo-4-10) |
| **Entorno** | Ejecución local, SUT iniciado, carga concurrente (10 hilos/procesos en paralelo sin delay) |
| **Respuesta Esperada** | El SUT procesa todas las peticiones sin degradación crítica ni pérdida de datos |
| **Medida (Falsable)** | ✅ Todas las 10 peticiones devuelven HTTP 200 (ninguna 5xx)<br>✅ Cada respuesta contiene un ID único (42, 43, 44, ..., 51)<br>✅ Latencia máxima por petición ≤ 2000 ms (umbral de rendimiento)<br>✅ GET /booking valida 10+ reservas en el sistema<br>✅ Verificación: GET /booking/42, GET /booking/51 retornan datos íntegros |
| **Evidencia** | `evidence/week3/concurrent_load_test.log` |
| **Pasa si** | Todas las peticiones se procesan sin errores 5xx, IDs únicos, datos intactos |
| **Falla si** | Alguna petición devuelve 5xx, duplicados de ID, latencia > 2s, o datos perdidos |

---

### 3. R002 – Acceso no autorizado sin autenticación (Score: 15)
**Atributo:** Security  
**Causa raíz:** Token de autenticación débil o validación insuficiente

#### Escenario Asociado: [Q7 – Rechazo de actualización sin token](../quality/scenarios.md#Q7)

| Elemento | Descripción |
|----------|-------------|
| **Estímulo** | 1. Crear una reserva con POST /booking (obtener ID: ej: 42)<br>2. Intentar ejecutar **PUT /booking/42 SIN proporcionar token** (omitir Cookie header)<br>3. Enviar datos de actualización completos pero sin autenticación |
| **Entorno** | Ejecución local, SUT con requerimiento de autenticación, reserva preexistente en el sistema |
| **Respuesta Esperada** | El SUT rechaza la petición SIN procesar la actualización |
| **Medida (Falsable)** | ✅ PUT sin token devuelve **HTTP 403 (Forbidden) o HTTP 401 (Unauthorized)**<br>✅ Respuesta contiene mensaje de error explicativo<br>✅ GET /booking/42 posterior confirma reserva NO fue modificada<br>✅ Campos originales intactos (firstname="Grupo-4", totalprice=112)<br>✅ Autorización falla ANTES de ejecutar lógica de negocio |
| **Evidencia** | `evidence/week3/authentication_failure.log` |
| **Pasa si** | Petición rechazada con 401/403 y datos no modificados |
| **Falla si** | PUT procesa sin token, HTTP 200, o datos fueron modificados |

---

## Matriz de Trazabilidad

| Risk ID | Atributo | Escenario | Q# | Medida Clave | Status |
|---------|----------|-----------|----|--------------|----|
| R001 | Reliability | Persistencia | Q5 | Datos idénticos tras reinicio | TOP3 |
| R003 | Performance | Concurrencia | Q6 | 10 POST concurrentes sin 5xx | TOP3 |
| R002 | Security | Autenticación | Q7 | Rechazo 401/403 sin token | TOP3 |

---

## Próximos Pasos

1. **Implementar scripts de prueba** para Q5, Q6, Q7 (bash/curl)
2. **Ejecutar escenarios** contra Restful Booker en Semana 3
3. **Registrar evidencia** en carpetas `evidence/week3/`
4. **Validar pases/fallos** contra criterios de medida
5. **Documentar resultados** en [memos/week3_memo.md](../memos/week3_memo.md)
