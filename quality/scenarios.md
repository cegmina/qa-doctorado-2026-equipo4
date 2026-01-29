# Escenarios de Calidad

## Descripción General

Este documento define los escenarios de calidad utilizados para evaluar la aplicación Restful-Booker. Los escenarios de calidad ayudan a establecer criterios medibles para los requisitos no funcionales.

# Semana 2 — Escenarios de calidad (falsables y medibles)

Referencia de formato:
- Un escenario debe tener: Estímulo, Entorno, Respuesta, Medida, Evidencia.

## Escenario Q1 — Crea una nueva reserva en la API
- Estímulo: se solicita la creación de una reserva con 
   ```json
   {
     "firstname": "Grupo-4",
     "lastname": "Grupo-4",
     "totalprice": 112,
     "depositpaid": true,
     "bookingdates": {
       "checkin": "2017-12-31",
       "checkout": "2018-12-31"
     }
   }
   
- Entorno: ejecución local, SUT iniciado
- Respuesta: el SUT realiza la reserva
- Medida (falsable): HTTP 200 y el cuerpo de la respuesat contiene el Id de la nueva reserva y los nuevos campos, se verifica que el Id exista y que los campos sean iguales."
- Evidencia: evidence/week2/createBooking.log

## Escenario Q2 — Devuelve una reserva específica según el ID de la reserva proporcionado
- Estímulo: se realiza solicitudes typo GET, primero para obtener la lista de reservas y de esas tomar la primera para obtener una reserva según un Id especifico
- Entorno: ejecución local, sin carga externa en la primera petición, sin embargo se envía un Id para la segunda petición
- Respuesta: el SUT procesa con éxito las peticiones.
- Medida (falsable): el SUT responde con HTTP 200 en ambas peticiones, en ls segunda petición retorna con éxito el objeto asociado al ID
- Evidencia: evidence/week2/getBookingById.log

## Escenario Q3 — Actualiza una reserva existente
- Estímulo: se solicita PUT /booking/{id} con un ID de reserva válido existente y token de autenticación, con los siguientes valores:
  ```json
   {
     "firstname": "UpdatedSmokeTest Grupo4",
     "lastname": "UpdatedUser Grupo4",
     "totalprice": 456,
     "depositpaid": false,
     "bookingdates": {
       "checkin": "2026-02-01",
       "checkout": "2026-02-03"
     },
     "additionalneeds": "Lunch"
   }
   ```
  - Primero se obtiene un ID de reserva mediante GET /booking
  - Se genera un token de autenticación con POST /auth usando credenciales `{"username": "admin", "password": "password123"}`
  - Se ejecuta PUT /booking/{id} con el token en el encabezado Cookie y Accept: application/json
- Entorno: ejecución local, sin carga, con autenticación requerida
- Respuesta: el SUT actualiza la reserva completa exitosamente
- Medida (falsable): 
  - La petición PUT devuelve HTTP 200
  - Una petición GET posterior al mismo ID confirma que el campo `firstname` fue actualizado a "UpdatedSmokeTest Grupo4"
  - Se verifica que los cambios fueron aplicados correctamente
- Evidencia: evidence/week2/updateBooking.log

## Escenario Q4 — Elimina una reserva de la API
- Estímulo: se solicita DELETE /booking/{id} con un ID de reserva válido existente y token de autenticación
  - Primero se obtiene un ID de reserva mediante GET /booking
  - Se genera un token de autenticación con POST /auth usando credenciales `{"username": "admin", "password": "password123"}`
  - Se ejecuta DELETE /booking/{id} con el token en el encabezado Cookie
- Entorno: ejecución local, sin carga, con autenticación requerida
- Respuesta: el SUT elimina la reserva exitosamente
- Medida (falsable): 
  - La petición DELETE devuelve HTTP 201
  - Una petición GET posterior al mismo ID devuelve HTTP 404 con mensaje "Not Found"
  - Se confirma que la reserva fue eliminada del sistema
- Evidencia: evidence/week2/deleteBooking.log

# Semana 3 — Escenarios de Calidad para Top 3 Riesgos

## Escenario Q5 — Verifica persistencia de datos (Semana 3 – Top 3: R001)
- Estímulo: Se crea una reserva con POST /booking, se obtiene su ID, se detiene el SUT, se reinicia y se consulta nuevamente
- Entorno: ejecución local, SUT con persistencia en base de datos, reinicio del servicio
- Respuesta: El SUT recupera la reserva exactamente como fue creada después del reinicio
- Medida (falsable):
  - POST devuelve HTTP 200 con ID de la nueva reserva (ej: 42)
  - GET /booking/42 antes del reinicio retorna la reserva con campos intactos
  - Tras reinicio: GET /booking/42 devuelve HTTP 200 con los mismos datos (firstname, lastname, totalprice, bookingdates)
  - No hay diferencia en el contenido antes/después del reinicio
- Evidencia: evidence/week3/persistency_test.log

## Escenario Q6 — Carga concurrente múltiples reservas (Semana 3 – Top 3: R003)
- Estímulo: Se lanzan 10 peticiones POST /booking simultáneamente, cada una creando una reserva con datos distintos
- Entorno: ejecución local, SUT iniciado, carga concurrente (10 hilos/procesos en paralelo)
- Respuesta: El SUT procesa todas las peticiones sin degradación crítica
- Medida (falsable):
  - Todas las 10 peticiones devuelven HTTP 200 (ninguna 5xx)
  - Cada petición contiene un ID único en la respuesta (42, 43, 44, ... 51)
  - Latencia máxima por petición ≤ 2 segundos (umbral de rendimiento aceptable)
  - GET /booking valida que existen 10 reservas nuevas en el sistema
  - No hay pérdida de datos: todas las reservas son recuperables por su ID
- Evidencia: evidence/week3/concurrent_load_test.log

## Escenario Q7 — Rechazo de actualización sin token (Semana 3 – Top 3: R002)
- Estímulo: Se intenta ejecutar PUT /booking/{id} sin proporcionar token de autenticación (omitir Cookie header)
- Entorno: ejecución local, SUT con requerimiento de autenticación, reserva existente en el sistema
- Respuesta: El SUT rechaza la petición sin procesar la actualización
- Medida (falsable):
  - PUT /booking/{id} sin token devuelve HTTP 403 (Forbidden) o HTTP 401 (Unauthorized)
  - El cuerpo de respuesta contiene mensaje de error explicativo
  - GET /booking/{id} posterior confirma que la reserva NO fue modificada (valores originales intactos)
  - La autorización falla antes de procesar la lógica de negocio
- Evidencia: evidence/week3/authentication_failure.log

## Criterios de Éxito

Cada caso contempla criterios de aceptación concretos que son evaluados durante las fases de prueba. Los resultados son documentados en las carpetas de evidencia.