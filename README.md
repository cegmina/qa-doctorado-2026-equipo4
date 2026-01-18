# QA Doctorado 2026 — Equipo 4

## Descripción del Proyecto

El presente repositorio contiene el conjunto completo de artefactos técnicos, académicos y organizativos correspondientes al proyecto **QA Doctorado 2026**, desarrollado por el Equipo 4. El trabajo se orienta al diseño, ejecución y análisis de estrategias de aseguramiento de la calidad aplicadas a un _System Under Test_ (SUT) seleccionado, bajo un enfoque metodológico riguroso y reproducible.

El SUT utilizado en este proyecto es **Restful Booker**, una API REST pública y reproducible, empleada como sistema de referencia para la ejecución de pruebas, recolección de evidencias y análisis comparativo de resultados.

## Estructura del Repositorio

La organización del repositorio responde a criterios de trazabilidad, separación de responsabilidades y claridad académica:

- **setup/** — Scripts para levantar, detener y verificar la salud del SUT
- **scripts/** — Scripts de pruebas, automatización y mediciones
- **evidence/** — Evidencias recolectadas semanalmente
- **quality/** — Escenarios de calidad, criterios y glosario
- **risk/** — Identificación de riesgos y estrategia de pruebas
- **design/** — Diseño de casos de prueba y reglas de oráculo
- **ci/** — Configuración de integración continua
- **memos/** — Memorándums de avance semanal
- **reports/** — Reportes técnicos y de resultados
- **study/** — Materiales del estudio de investigación
- **paper/** — Documento del _paper_ final
- **slides/** — Materiales de presentación académica
- **peer_review/** — Materiales de revisión por pares

## Primeros Pasos

Antes de ejecutar cualquier actividad técnica, se recomienda revisar los acuerdos del grupo de trabajo, los cuales definen responsabilidades, estándares de calidad y mecanismos de coordinación:

- **Agreements:** `AGREEMENTS.md`

## Requisitos del Entorno

El proyecto requiere un entorno con los siguientes componentes instalados:

- Docker
- Docker Compose (plugin o versión clásica)
- _Shell_ compatible con _bash_
- Herramienta `curl`

La instalación de Docker puede realizarse siguiendo la documentación oficial:

- **Docker:** https://docs.docker.com/get-docker/

## Instalación y Levantamiento del SUT

El SUT **Restful Booker** se ejecuta de forma local mediante contenedores. Los scripts necesarios se encuentran en el directorio `setup/`.

Para asignar permisos de ejecución a los scripts:

```bash
make perm
```

Para iniciar el SUT:

```bash
make up
```

Para verificar la salud del sistema:

```bash
make health
```

Para detener el SUT:

```bash
make down
```

En caso de requerir un reinicio completo del entorno:

```bash
make restart
```

Si el entorno de ejecución no dispone de la herramienta make, los scripts pueden ejecutarse manualmente desde el directorio setup/, en el orden que resulte conveniente para la actividad.

##Uso del Makefile

El Makefile actúa como una capa de abstracción sobre los scripts del SUT, permitiendo un control uniforme del ciclo de vida del sistema. Su uso reduce errores operativos, facilita la repetibilidad de los experimentos y estandariza la ejecución entre los integrantes del equipo.

Para visualizar todos los comandos disponibles:

```bash
make help
```

##Consideraciones de Uso

El SUT se utiliza exclusivamente como sistema de referencia para la ejecución de pruebas y análisis de calidad. No se contempla la modificación de su código fuente, con el objetivo de preservar la reproducibilidad y la comparabilidad de los resultados obtenidos.

Cualquier incidencia durante la ejecución deberá documentarse en el directorio correspondiente de evidencias o memorándums, según aplique.

##Miembros del Equipo

- Kenji Kawaida Villegas
- Windsor Alvarez Davila
- Rolando Kerlin Ruiz Justiniano
- Daniel Adolfo Blanco Adrian
- Cegmina Clemencia Apaza Leon
