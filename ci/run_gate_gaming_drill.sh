#!/usr/bin/env bash
# Modo estricto: falla por variables no definidas y por errores dentro de pipes.
set -uo pipefail

# Resolver rutas absolutas del script y de la raíz del proyecto.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
cd "${PROJECT_ROOT}"

# Rutas de evidencia y archivos de trabajo.
BEFORE_DIR="evidence/week6/before"
AFTER_DIR="evidence/week6/after"
SUMMARY_FILE="evidence/week6/summary.txt"
# tomando el mismo gate para BEFORE y AFTER, pero se manipula temporalmente para simular gaming tactic en BEFORE.
GATE_FILE="ci/run_quality_gates.sh"


WEEK4_DIR="evidence/week4"
WEEK5_DIR="evidence/week5"

# Crear carpetas de salida y limpiar resultados previos del drill.
mkdir -p "${BEFORE_DIR}" "${AFTER_DIR}"
rm -rf "${BEFORE_DIR:?}"/*
rm -rf "${AFTER_DIR:?}"/*

# Parámetros configurables por entorno (con valores por defecto).
BASE_URL="${BASE_URL:-http://localhost:3001}"
SKIP_SUT_START="${SKIP_SUT_START:-1}"
RELAX_SYSTEMATIC_CHECK="${RELAX_SYSTEMATIC_CHECK:-1}"
GIT_BASH_EXE="${GIT_BASH_EXE:-/mnt/c/Program Files/Git/bin/bash.exe}"
USE_WEEK5_REPORTS="${USE_WEEK5_REPORTS:-0}"

# Directorio temporal para backups y restauración segura.
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/gate-drill.XXXXXX" 2>/dev/null || echo "/tmp/gate-drill.$$")"
GATE_BAK="${TMP_DIR}/run_quality_gates.original.sh"
EVIDENCE_BAK="${TMP_DIR}/evidence_backup"
WEEK4_EXISTS=0
WEEK5_EXISTS=0

mkdir -p "${TMP_DIR}"

# Restaurar estado original al salir (éxito o error): gate + evidencias + temporales.
cleanup() {
	cp -f "${GATE_BAK}" "${GATE_FILE}" 2>/dev/null || true
	restore_evidence_dirs
	rm -rf "${TMP_DIR}" 2>/dev/null || true
}
trap cleanup EXIT

# Backup del gate original antes de cualquier manipulación del escenario BEFORE.
cp -f "${GATE_FILE}" "${GATE_BAK}"

# Respaldar week4/week5 para que el drill no deje efectos laterales en esas evidencias.
backup_evidence_dirs() {
	mkdir -p "${EVIDENCE_BAK}/week4" "${EVIDENCE_BAK}/week5"

	if [ -d "${WEEK4_DIR}" ]; then
		WEEK4_EXISTS=1
		cp -a "${WEEK4_DIR}/." "${EVIDENCE_BAK}/week4/" 2>/dev/null || true
	fi

	if [ -d "${WEEK5_DIR}" ]; then
		WEEK5_EXISTS=1
		cp -a "${WEEK5_DIR}/." "${EVIDENCE_BAK}/week5/" 2>/dev/null || true
	fi
}

# Restaurar week4/week5 a su estado previo (si existían, restaurar; si no, eliminar).
restore_evidence_dirs() {
	if [ "${WEEK4_EXISTS}" = "1" ]; then
		rm -rf "${WEEK4_DIR}"
		mkdir -p "${WEEK4_DIR}"
		cp -a "${EVIDENCE_BAK}/week4/." "${WEEK4_DIR}/" 2>/dev/null || true
	else
		rm -rf "${WEEK4_DIR}"
	fi

	if [ "${WEEK5_EXISTS}" = "1" ]; then
		rm -rf "${WEEK5_DIR}"
		mkdir -p "${WEEK5_DIR}"
		cp -a "${EVIDENCE_BAK}/week5/." "${WEEK5_DIR}/" 2>/dev/null || true
	else
		rm -rf "${WEEK5_DIR}"
	fi
}

# Ejecutar backup inicial de evidencias históricas.
backup_evidence_dirs

# Detectar si el script corre dentro de WSL.
is_wsl() {
	grep -qiE 'microsoft|wsl' /proc/version 2>/dev/null
}

# Validar si el SUT local responde (200/201) en /booking.
can_reach_local_sut() {
	curl -sS -o /dev/null -m 3 -w "%{http_code}" "${BASE_URL}/booking" 2>/dev/null | grep -qE '^(200|201)$'
}

# Buscar marcadores de manipulación/comentado en el gate.
contains_commented_test_markers() {
	local file_path="$1"
	grep -qE "COMMENTED_OUT|GAMED_CHECK2|CHECK 2 comentado manualmente" "${file_path}"
}

# Buscar evidencia en RUNLOG de que el CHECK 2 fue comentado durante BEFORE.
detected_before_gaming_evidence() {
	local before_runlog="$1"
	grep -qE "CHECK 2 comentado por gaming drill|GAMED_CHECK2" "${before_runlog}"
}

# Construir versión gamificada del gate para BEFORE (modificación temporal sobre copia en disco).
build_before_gamed_copy() {
	python3 - "${GATE_FILE}" "${GATE_FILE}" <<'PY'
import sys

# src/dst apuntan al mismo archivo para reescribirlo in-place.
src, dst = sys.argv[1], sys.argv[2]
with open(src, encoding='utf-8') as f:
    lines = f.readlines()

# Ubicar el bloque del CHECK 2 delimitado por encabezados de CHECK 2 y CHECK 3.
start = None
end = None
for idx, line in enumerate(lines):
    if start is None and '# CHECK 2: Persistencia de datos (R001 / Q5)' in line:
        start = idx
    if '# CHECK 3: Rechazo sin autenticación (R002 / Q7)' in line:
        end = idx
        break

# Si no se encuentran los marcadores, abortar para evitar editar una sección incorrecta.
if start is None or end is None or end <= start:
    raise SystemExit('No se pudieron ubicar los marcadores de Check 2/3 para gaming BEFORE.')

# Separar el archivo en: prefijo + bloque CHECK2 + sufijo.
prefix = lines[:start]
check2_block = lines[start:end]
suffix = lines[end:]

# Inyección del escenario gaming:
# 1) comentar el CHECK 2 real con heredoc
# 2) forzar PASS sintético
# 3) dejar trazabilidad explícita en artefactos y RUNLOG
injected = [
    ": <<'GAMED_CHECK2'\n",
    *check2_block,
    "GAMED_CHECK2\n",
    "\n",
    "HTTP2=\"200\"\n",
    "FIELDS_OK=\"1\"\n",
    "echo '{\"note\":\"CHECK 2 comentado por gaming drill\"}' > \"${OUT_DIR}/persistency_response.json\"\n",
    "{\n",
    "  echo \"[$(date -u +\\\"%Y-%m-%d %H:%M:%S UTC\\\")] CHECK 2 comentado por gaming drill\"\n",
    "  echo \"HTTP_CODE=${HTTP2}\"\n",
    "  echo \"RESULT: PASS\"\n",
    "} > \"${OUT_DIR}/persistency_check.log\"\n",
    "echo \"  → CHECK 2 comentado por gaming drill (no ejecutado)\" >> \"${RUNLOG}\"\n",
    "\n",
]

with open(dst, 'w', encoding='utf-8', newline='\n') as f:
    f.writelines(prefix + injected + suffix)
PY

	# Retornar el código de salida del bloque Python.
	return $?
}

# Ejecutar el gate con estrategia multi-entorno:
# - Bash nativo si el SUT responde
# - Git Bash (en WSL) si aplica
# - Fallback nativo aunque el SUT no responda
run_gate_script() {
	local gate_script="$1"
	local out_dir="$2"
	local log_file="$3"
	local runner_file="$4"
	local win_root

	if can_reach_local_sut; then
		echo "native-bash" > "${runner_file}"
		OUT_DIR="${out_dir}" BASE_URL="${BASE_URL}" SKIP_SUT_START="${SKIP_SUT_START}" RELAX_SYSTEMATIC_CHECK="${RELAX_SYSTEMATIC_CHECK}" bash "${gate_script}" > "${log_file}" 2>&1
		return $?
	fi

	if is_wsl && [ -x "${GIT_BASH_EXE}" ]; then
		win_root="$(wslpath -w "${PROJECT_ROOT}")"
		echo "git-bash-exe" > "${runner_file}"
		"${GIT_BASH_EXE}" -lc "cd '${win_root}' && OUT_DIR='${out_dir}' BASE_URL='${BASE_URL}' SKIP_SUT_START='${SKIP_SUT_START}' RELAX_SYSTEMATIC_CHECK='${RELAX_SYSTEMATIC_CHECK}' bash '${gate_script}'" > "${log_file}" 2>&1
		return $?
	fi

	echo "native-bash-unreachable-sut" > "${runner_file}"
	OUT_DIR="${out_dir}" BASE_URL="${BASE_URL}" SKIP_SUT_START="${SKIP_SUT_START}" RELAX_SYSTEMATIC_CHECK="${RELAX_SYSTEMATIC_CHECK}" bash "${gate_script}" > "${log_file}" 2>&1
	return $?
}

# Conservar sólo RUNLOG/SUMMARY en each escenario y normalizar referencias internas.
keep_only_run_reports() {
	local out_dir="$1"
	local src_runlog="${out_dir}/RUNLOG.md"
	local src_summary="${out_dir}/SUMMARY.md"
	local tmp_runlog="${out_dir}/.RUNLOG.tmp"
	local tmp_summary="${out_dir}/.SUMMARY.tmp"

	if [ "${USE_WEEK5_REPORTS}" = "1" ]; then
		src_runlog="evidence/week5/RUNLOG.md"
		src_summary="evidence/week5/SUMMARY.md"
	fi

	if [ -f "${src_runlog}" ]; then
		cp -f "${src_runlog}" "${tmp_runlog}"
	else
		echo "RUNLOG no generado por el gate en este escenario." > "${tmp_runlog}"
	fi

	if [ -f "${src_summary}" ]; then
		cp -f "${src_summary}" "${tmp_summary}"
	else
		echo "SUMMARY no generado por el gate en este escenario." > "${tmp_summary}"
	fi

	rm -rf "${out_dir:?}"/*

	[ -f "${tmp_runlog}" ] && mv -f "${tmp_runlog}" "${out_dir}/RUNLOG.md"
	[ -f "${tmp_summary}" ] && mv -f "${tmp_summary}" "${out_dir}/SUMMARY.md"
	normalize_runlog_evidence "${out_dir}"
	normalize_summary_evidence "${out_dir}"
	return 0
}

# Ajustar RUNLOG para que apunte a evidencia del escenario actual y no a week4.
normalize_runlog_evidence() {
	local out_dir="$1"
	local runlog_file="${out_dir}/RUNLOG.md"
	local rel_dir
	local tmp_file

	[ -f "${runlog_file}" ] || return 0

	rel_dir="${out_dir%/}/"
	tmp_file="${runlog_file}.tmp"

	awk -v rel="${rel_dir}" '
	BEGIN { replaced=0; skipping=0 }
	{
	  if ($0 ~ /Directorio de Evidencia: evidence\/week4/) {
	    next
	  }
	  if ($0 ~ /^Evidencia guardada en: evidence\/week4$/) {
	    next
	  }
	  if ($0 ~ /^Resumen: evidence\/week4\/summary.txt$/) {
	    next
	  }
	  if ($0 ~ /^Registro: evidence\/week4\/RUNLOG.md$/) {
	    next
	  }

	  if (!replaced && $0 ~ /^## Evidencia producida/) {
	    print "## Evidencia producida"
	    print "- " rel "RUNLOG.md"
	    print "- " rel "SUMMARY.md"
	    replaced=1
	    skipping=1
	    next
	  }

	  if (skipping) {
	    if ($0 ~ /^- /) {
	      next
	    }
	    skipping=0
	  }

	  print $0
	}
	END {
	  if (!replaced) {
	    print ""
	    print "## Evidencia producida"
	    print "- " rel "RUNLOG.md"
	    print "- " rel "SUMMARY.md"
	  }
	}
	' "${runlog_file}" > "${tmp_file}" && mv -f "${tmp_file}" "${runlog_file}"
}

# Ajustar SUMMARY para mostrar sólo RUNLOG/SUMMARY del directorio de salida actual.
normalize_summary_evidence() {
	local out_dir="$1"
	local summary_file="${out_dir}/SUMMARY.md"
	local rel_dir
	local tmp_file

	[ -f "${summary_file}" ] || return 0

	rel_dir="${out_dir%/}/"
	tmp_file="${summary_file}.tmp"

	awk -v rel="${rel_dir}" '
	BEGIN { replaced=0; skipping=0 }
	{
	  if (!replaced && $0 ~ /^## Evidencia en /) {
	    print "## Evidencia en `" rel "`"
	    print "- RUNLOG.md"
	    print "- SUMMARY.md"
	    replaced=1
	    skipping=1
	    next
	  }

	  if (skipping) {
	    if ($0 ~ /^- /) {
	      next
	    }
	    skipping=0
	  }

	  print $0
	}
	END {
	  if (!replaced) {
	    print ""
	    print "## Evidencia en `" rel "`"
	    print "- RUNLOG.md"
	    print "- SUMMARY.md"
	  }
	}
	' "${summary_file}" > "${tmp_file}" && mv -f "${tmp_file}" "${summary_file}"
}

# String de comando base para trazabilidad en el resumen final.
COMMAND_EXACT="OUT_DIR=<before|after> BASE_URL=${BASE_URL} SKIP_SUT_START=${SKIP_SUT_START} RELAX_SYSTEMATIC_CHECK=${RELAX_SYSTEMATIC_CHECK} bash ./ci/run_quality_gates.sh"

# ------------------------
# ESCENARIO BEFORE
# ------------------------
echo "================== BEFORE =================="
# Generar versión temporal del gate con CHECK 2 debilitado.
build_before_gamed_copy
# Permitir capturar rc sin abortar el script completo.
set +e
run_gate_script "${GATE_FILE}" "${BEFORE_DIR}" "${BEFORE_DIR}/gate_console.log" "${BEFORE_DIR}/runner.txt"
BEFORE_EXIT=$?
# Reactivar salida por error para el resto del flujo.
set -e
BEFORE_RUNNER="$(cat "${BEFORE_DIR}/runner.txt" 2>/dev/null || echo "native-bash")"
keep_only_run_reports "${BEFORE_DIR}"

# Restaurar gate original antes del AFTER
cp -f "${GATE_BAK}" "${GATE_FILE}"

# ------------------------
# ESCENARIO AFTER
# ------------------------
echo "================== AFTER =================="
# Si detecta manipulación en gate o en evidencia del BEFORE, forzar FAIL defensivo.
if contains_commented_test_markers "${GATE_FILE}" || detected_before_gaming_evidence "${BEFORE_DIR}/RUNLOG.md"; then
	echo "AFTER FAIL: Oráculo mínimo obligatorio que no se puede “relajar” sin registro. Intento de gaming detectado (test comentado en BEFORE o marcador en gate)." > "${AFTER_DIR}/RUNLOG.md"
	echo "AFTER FAIL: Oráculo mínimo obligatorio que no se puede “relajar” sin registro. Intento de gaming detectado (test comentado en BEFORE o marcador en gate)." > "${AFTER_DIR}/SUMMARY.md"
	echo "validation-only" > "${AFTER_DIR}/runner.txt"
	AFTER_EXIT=1
	AFTER_RUNNER="validation-only"
	keep_only_run_reports "${AFTER_DIR}"
else
	# Si no hay indicios de gaming, correr gate normal en AFTER.
	set +e
	run_gate_script "${GATE_FILE}" "${AFTER_DIR}" "${AFTER_DIR}/gate_console.log" "${AFTER_DIR}/runner.txt"
	AFTER_EXIT=$?
	set -e
	AFTER_RUNNER="$(cat "${AFTER_DIR}/runner.txt" 2>/dev/null || echo "native-bash")"
	keep_only_run_reports "${AFTER_DIR}"
fi

# Escribir resumen consolidado del drill (BEFORE vs AFTER) para evidencia final.
{
	echo "Semana 6 — Resultado del Gaming Drill"
	echo ""
	echo "Comando base: ${COMMAND_EXACT}"
	echo ""
	echo "BEFORE (sin integridad): rc=${BEFORE_EXIT}"
	echo "- Esperado: el gate puede completar/parecer exitoso aunque se haya debilitado el check de persistencia."
	echo "- Runner: ${BEFORE_RUNNER}"
	echo "- Carpeta: ${BEFORE_DIR}"
	echo ""
	echo "AFTER (con integridad): rc=${AFTER_EXIT}"
	echo "- Táctica: Oráculo mínimo obligatorio → evita que el gate pueda ser “relajado” comentando código o ignorando fallos."
	echo "- Runner: ${AFTER_RUNNER}"
	echo "- Carpeta: ${AFTER_DIR}"
	echo ""
	echo "Táctica aplicada:"
	echo "- BEFORE: comentar temporalmente el test de persistencia (debilitar oráculo)."
	echo "- AFTER: validación anti-gaming por marcadores/evidencia del BEFORE."
	echo ""
	echo "Evidencia:"
	echo "- evidence/week6/before/RUNLOG.md"
	echo "- evidence/week6/before/SUMMARY.md"
	echo "- evidence/week6/after/RUNLOG.md"
	echo "- evidence/week6/after/SUMMARY.md"
} > "${SUMMARY_FILE}"

# Mensaje final de finalización.
echo "Drill completado. Evidencia en evidence/week6/."
