#!/usr/bin/env bash
# Apply local hosts-based blocking for listed apps.
# Requires sudo on Linux/macOS.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BLOCKLIST="${SCRIPT_DIR}/../blocklists/hosts"
HOSTS_FILE="/etc/hosts"
MARKER_START="# BEGIN cursor-app-blocklist"
MARKER_END="# END cursor-app-blocklist"

if [[ ! -f "$BLOCKLIST" ]]; then
  echo "Blocklist not found: $BLOCKLIST" >&2
  exit 1
fi

if [[ $EUID -ne 0 ]]; then
  echo "Run with sudo: sudo $0" >&2
  exit 1
fi

# Remove previous blocklist section if present
if grep -q "$MARKER_START" "$HOSTS_FILE"; then
  sed -i "/$MARKER_START/,/$MARKER_END/d" "$HOSTS_FILE"
fi

{
  echo ""
  echo "$MARKER_START"
  grep -v '^#' "$BLOCKLIST" | grep -v '^$'
  echo "$MARKER_END"
} >> "$HOSTS_FILE"

echo "App blocklist applied to $HOSTS_FILE"
