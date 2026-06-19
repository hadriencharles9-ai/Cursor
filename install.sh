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

install -m 644 "${SCRIPT_DIR}/systemd/"*.service /etc/systemd/system/
install -m 644 "${SCRIPT_DIR}/systemd/"*.timer /etc/systemd/system/

systemctl daemon-reload
systemctl enable content-filter-block.timer
systemctl enable content-filter-unblock.timer
systemctl enable content-filter-sync.service
systemctl start content-filter-block.timer
systemctl start content-filter-unblock.timer
systemctl start content-filter-sync.service

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
