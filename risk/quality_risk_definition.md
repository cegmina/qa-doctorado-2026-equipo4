# Definición de Riesgos de Calidad del Producto

## Objetivo
Establecer criterios claros para identificar y clasificar **riesgos de calidad** (relacionados con el producto y su comportamiento) versus **riesgos de gestión** (relacionados con procesos, recursos o entorno externo), evitando confusiones que diluyan el enfoque en atributos técnicos medibles.

---

## 1. Riesgos de Calidad del Producto (Incluidos)

Un **riesgo de calidad** es una condición o defecto potencial en el SUT que puede afectar atributos observables del sistema. Se evalúan mediante métricas técnicas y son controlables mediante prueba y corrección de código.

### Atributos de Calidad Considerados

#### 1.1 **Reliability (Confiabilidad)**
- **Definición:** Capacidad del sistema de mantener integridad y persistencia de datos bajo condiciones nominales.
- **Riesgos incluidos:**
  - Pérdida o corrupción de datos en base de datos
  - Fallos transaccionales que dejan datos en estado inconsistente
  - Recuperación incompleta tras fallos
- **Ejemplo:** *R001 – Pérdida de datos de reservas en base de datos*
- **Medida:** HTTP 200 + confirmación de persistencia en GET subsecuente

#### 1.2 **Security (Seguridad)**
- **Definición:** Capacidad de proteger datos contra acceso, modificación o revelación no autorizados.
- **Riesgos incluidos:**
  - Autenticación débil o validación insuficiente
  - Inyección de código (SQL, NoSQL, command injection)
  - Exposición de datos sensibles (reservas, credenciales)
  - Autorización incorrecta (un usuario accede a reservas de otro)
- **Ejemplo:** *R002 – Acceso no autorizado sin autenticación adecuada; R009 – Inyección de datos en campos*
- **Medida:** HTTP 401/403 para accesos no autorizados, sanitización verificable de entrada

#### 1.3 **Performance (Rendimiento)**
- **Definición:** Capacidad del sistema de responder en tiempos aceptables bajo carga esperada y concurrencia.
- **Riesgos incluidos:**
  - Degradación de latencia bajo múltiples peticiones concurrentes
  - Falta de índices o optimización de consultas
  - Manejo ineficiente de conexiones simultáneas
- **Ejemplo:** *R003 – Degradación bajo carga concurrente de múltiples reservas*
- **Medida:** Latencia en ms; throughput en requests/sec

#### 1.4 **Availability (Disponibilidad)**
- **Definición:** Capacidad del sistema de estar operativo y accesible cuando se solicita.
- **Riesgos incluidos:**
  - Fallos no manejados que causan crashes o timeouts
  - Excepciones no capturadas que interrumpen el servicio
  - Endpoints que devuelven 5xx en lugar de respuestas validadas
- **Ejemplo:** *R004 – Indisponibilidad por fallos no manejados en endpoints*
- **Medida:** Uptime en %; códigos HTTP en rango 2xx/4xx (no 5xx)

#### 1.5 **Correctness (Corrección Funcional)**
- **Definición:** Capacidad del sistema de cumplir sus especificaciones funcionales exactamente.
- **Riesgos incluidos:**
  - Actualización parcial (falta de atomicidad)
  - Lógica de negocio incorrecta
  - Valores retornados incorrectos (ej.: código de estado erróneo)
  - Búsquedas que retornan datos incorrectos
- **Ejemplo:** *R006 – Actualización parcial sin transacción atómica; R008 – DELETE devuelve HTTP 201 incorrecto*
- **Medida:** Ejecución de escenarios Q1-Q4; verificación de estados antes/después

#### 1.6 **Compatibility (Compatibilidad)**
- **Definición:** Capacidad del sistema de mantener consistencia en interfaz y comportamiento entre versiones.
- **Riesgos incluidos:**
  - Cambios en estructura JSON sin versionado
  - Cambios en códigos de error o mensajes que quiebran clientes existentes
  - Inconsistencia entre documentación y respuestas reales
- **Ejemplo:** *R005 – Inconsistencia en respuestas JSON entre versiones*
- **Medida:** Validación contra esquema JSON; compatibilidad con clientes previos

#### 1.7 **Functional Correctness (Exactitud Funcional)**
- **Definición:** Precisión en la ejecución de operaciones específicas.
- **Riesgos incluidos:**
  - Falsos positivos/negativos en búsquedas
  - Datos retornados que no coinciden con los solicitados
  - Lógica de filtrado o ordenamiento incorrecta
- **Ejemplo:** *R010 – Búsqueda de reserva por ID devuelve datos de otra reserva*
- **Medida:** Validación de contenido exacto en respuestas

#### 1.8 **Maintainability (Mantenibilidad)**
- **Definición:** Capacidad de localizar y corregir defectos rápidamente.
- **Riesgos incluidos:**
  - Código no modularizado que dificulta identificación de fallos
  - Bajo nivel de cobertura de pruebas (pruebas heredadas incompletas)
  - Documentación insuficiente para debugging
- **Ejemplo:** *R007 – Dificultad para identificar y reparar fallos en código monolítico*
- **Medida:** Cobertura de código en %; modularidad de funciones; trazabilidad de pruebas

---

## 2. Riesgos de Gestión (Excluidos)

**NO son riesgos de calidad del producto** los que derivan de:

### Recursos y Capacidad
- ❌ "No hay suficiente tiempo para completar pruebas"
- ❌ "Falta de personal especializado"
- ❌ "Presupuesto insuficiente para herramientas"

### Entorno Externo
- ❌ "Falló la conexión a internet"
- ❌ "El proveedor de hosting está caído"
- ❌ "Windows Update interrumpió los tests"

### Procesos de Desarrollo
- ❌ "No se asignó revisor de código"
- ❌ "El build fue cancelado manualmente"
- ❌ "Se perdió la rama de desarrollo"

### Riesgos Políticos o Empresariales
- ❌ "El cliente cambió los requisitos"
- ❌ "Se descontinuó el proyecto"
- ❌ "Cambio de prioridades por decisión ejecutiva"

---

## 3. Relación con Escenarios de Calidad (Q1-Q4)

Cada riesgo de calidad debe trazarse a al menos un escenario en [quality/scenarios.md](../quality/scenarios.md):

| Riesgo | Q1 (Create) | Q2 (Get) | Q3 (Update) | Q4 (Delete) |
|--------|-------------|----------|-------------|------------|
| R001 (Pérdida datos) | ✓ | ✓ | ✓ | ✓ |
| R002 (Autenticación) | | | ✓ | ✓ |
| R003 (Performance) | ✓ | | | |
| R004 (Disponibilidad) | | ✓ | | |
| R005 (Compatibility) | | ✓ | | |
| R006 (Atomicidad) | | | ✓ | |
| R007 (Mantenibilidad) | ✓ | ✓ | ✓ | ✓ |
| R008 (Correctness) | | | | ✓ |
| R009 (Inyección) | ✓ | | ✓ | |
| R010 (Búsqueda) | | ✓ | | |

---

## 4. Estructura de Análisis de Riesgo

Cada riesgo de calidad se documenta con:

```
Risk ID: R00X
Quality Attribute: [Reliability | Security | Performance | Availability | Correctness | Compatibility | Functional Correctness | Maintainability]
Description: [Qué puede fallar en el producto]
Cause: [Por qué está en riesgo técnicamente]
Impact (1-5): [Consecuencia observable para el usuario/negocio]
Probability (1-5): [Probabilidad técnica basada en diseño del SUT]
Score: Impact × Probability
Why This Score: [Justificación técnica en 1 línea]
Scenario Reference: [Q1, Q2, Q3, Q4 o combinación]
Evidence Reference: [Ruta a logs/artefactos de prueba]
Status: [TOP3 | BACKLOG]
```

---

## 5. Criterios de Priorización

### Top 3: Riesgos Críticos
- Score ≥ 15 **O**
- Impacto = 5 (pérdida de datos, exposición de seguridad)
- **Acción:** Investigación inmediata, pruebas exhaustivas, mitigación antes de release

### BACKLOG: Riesgos Secundarios
- Score < 15 **Y** Impacto < 5
- **Acción:** Monitoreo continuo, pruebas periódicas, corrección en ciclos posteriores

---

## 6. Exclusiones Explícitas

Por definición, **NO se incluyen**:

- Fallos en el entorno de test (máquina, SO, red local)
- Fallos en herramientas de prueba (curl, jq, shell scripts)
- Riesgos de CI/CD o deploy
- Riesgos de rendimiento esperado bajo DoS (fuera de carga nominal)
- Fallos en documentación de usuario (UX copy, help text)

---

## Resumen

Los riesgos de calidad del proyecto **Restful Booker – Semana 3** se centran en:
1. **Integridad y persistencia** de datos de reservas
2. **Seguridad** de autenticación y autorización
3. **Rendimiento** bajo concurrencia
4. **Disponibilidad** y manejo de errores
5. **Exactitud funcional** de operaciones CRUD

Todos están **controlables mediante prueba y corrección de código**, diferenciándolos claramente de riesgos de gestión o entorno.
