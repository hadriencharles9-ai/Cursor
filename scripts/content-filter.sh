#!/usr/bin/env bash
set -euo pipefail

MARKER_START="# >>> content-filter-block START"
MARKER_END="# <<< content-filter-block END"
HOSTS_FILE="/etc/hosts"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f /usr/local/share/content-filter/domains.txt ]]; then
  DOMAINS_FILE="/usr/local/share/content-filter/domains.txt"
else
  DOMAINS_FILE="${SCRIPT_DIR}/../config/domains.txt"
fi
REDIRECT_IP="0.0.0.0"

usage() {
  cat <<'EOF'
Usage: content-filter.sh <command>

Commands:
  block     Ajoute les domaines bloqués dans /etc/hosts
  unblock   Retire le blocage de /etc/hosts
  status    Affiche l'état actuel du blocage
  sync      Applique le blocage si l'heure est entre 23h et 17h
EOF
}

require_root() {
  if [[ "${EUID}" -ne 0 ]]; then
    echo "Erreur : exécutez ce script avec sudo." >&2
    exit 1
  fi
}

is_blocked() {
  grep -qF "${MARKER_START}" "${HOSTS_FILE}" 2>/dev/null
}

is_blocking_hours() {
  local hour
  hour="$(date +%H)"
  hour="${hour#0}"
  # Blocage actif de 23h à 16h59 (fenêtre autorisée : 17h-22h59)
  [[ "${hour}" -ge 23 || "${hour}" -lt 17 ]]
}

build_block_section() {
  echo "${MARKER_START}"
  while IFS= read -r line || [[ -n "${line}" ]]; do
    line="${line%%#*}"
    line="$(echo "${line}" | xargs)"
    [[ -z "${line}" ]] && continue
    echo "${REDIRECT_IP} ${line}"
    if [[ "${line}" != www.* ]]; then
      echo "${REDIRECT_IP} www.${line}"
    fi
  done < "${DOMAINS_FILE}"
  echo "${MARKER_END}"
}

block() {
  require_root

  if is_blocked; then
    echo "Le blocage est déjà actif."
    return 0
  fi

  {
    echo ""
    build_block_section
  } >> "${HOSTS_FILE}"

  echo "Blocage activé pour TikTok, Instagram, X, Netflix, Prime Video et HBO/Max."
}

unblock() {
  require_root

  if ! is_blocked; then
    echo "Aucun blocage actif."
    return 0
  fi

  awk -v start="${MARKER_START}" -v end="${MARKER_END}" '
    $0 == start { in_block = 1; next }
    $0 == end { in_block = 0; next }
    !in_block { print }
  ' "${HOSTS_FILE}" > "${HOSTS_FILE}.tmp"

  cat "${HOSTS_FILE}.tmp" > "${HOSTS_FILE}"
  rm -f "${HOSTS_FILE}.tmp"
  echo "Blocage désactivé."
}

status() {
  if is_blocked; then
    echo "État : BLOQUÉ"
  else
    echo "État : AUTORISÉ"
  fi

  if is_blocking_hours; then
    echo "Plage horaire actuelle : période de blocage (23h-17h)"
  else
    echo "Plage horaire actuelle : période autorisée (17h-23h)"
  fi
}

sync() {
  require_root

  if is_blocking_hours; then
    block
  else
    unblock
  fi
}

main() {
  local command="${1:-}"

  case "${command}" in
    block) block ;;
    unblock) unblock ;;
    status) status ;;
    sync) sync ;;
    -h|--help|help|"") usage ;;
    *)
      echo "Commande inconnue : ${command}" >&2
      usage
      exit 1
      ;;
  esac
}

main "$@"
