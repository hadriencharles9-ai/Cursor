#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_PREFIX="/usr/local"

if [[ "${EUID}" -ne 0 ]]; then
  echo "Exécutez ce script avec sudo : sudo ./install.sh"
  exit 1
fi

echo "Installation du filtre horaire..."

install -m 755 "${SCRIPT_DIR}/scripts/content-filter.sh" "${INSTALL_PREFIX}/bin/content-filter.sh"
install -d "${INSTALL_PREFIX}/share/content-filter"
install -m 644 "${SCRIPT_DIR}/config/domains.txt" "${INSTALL_PREFIX}/share/content-filter/domains.txt"

if systemctl is-system-running --quiet 2>/dev/null || pidof systemd >/dev/null 2>&1; then
  install -m 644 "${SCRIPT_DIR}/systemd/"*.service /etc/systemd/system/
  install -m 644 "${SCRIPT_DIR}/systemd/"*.timer /etc/systemd/system/
  systemctl daemon-reload
  systemctl enable content-filter-block.timer
  systemctl enable content-filter-unblock.timer
  systemctl enable content-filter-sync.service
  systemctl start content-filter-block.timer
  systemctl start content-filter-unblock.timer
  systemctl start content-filter-sync.service
  echo "Planification : systemd timers"
else
  if ! command -v crontab >/dev/null 2>&1; then
  apt-get update -qq && apt-get install -y -qq cron
  service cron start 2>/dev/null || true
  fi
  (crontab -l 2>/dev/null | grep -v content-filter.sh
   echo "# content-filter horaire"
   echo "0 23 * * * ${INSTALL_PREFIX}/bin/content-filter.sh block >> /var/log/content-filter.log 2>&1"
   echo "0 17 * * * ${INSTALL_PREFIX}/bin/content-filter.sh unblock >> /var/log/content-filter.log 2>&1"
   echo "@reboot sleep 30 && ${INSTALL_PREFIX}/bin/content-filter.sh sync >> /var/log/content-filter.log 2>&1"
  ) | crontab -
  echo "Planification : cron (systemd indisponible)"
fi

content-filter.sh sync

echo ""
echo "Installation terminée."
echo ""
content-filter.sh status
echo ""
echo "Commandes utiles :"
echo "  sudo content-filter.sh status   # Voir l'état"
echo "  sudo content-filter.sh block    # Forcer le blocage"
echo "  sudo content-filter.sh unblock  # Forcer le déblocage"
echo "  sudo content-filter.sh sync     # Appliquer selon l'heure"
