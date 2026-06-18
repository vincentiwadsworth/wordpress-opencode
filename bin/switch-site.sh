#!/usr/bin/env bash
# bin/switch-site.sh — Switch active site context for the AI workspace
#
# Usage:
#   ./bin/switch-site.sh <site-id>
#   ./bin/switch-site.sh list
#   ./bin/switch-site.sh status
#
# This sets ACTIVE_SITE env var and writes a .current-site marker file
# so the AI knows which client site is active across sessions.

set -euo pipefail

SITES_DIR="$(cd "$(dirname "$0")/../sites" && pwd)"
MARKER_FILE="$(cd "$(dirname "$0")/.." && pwd)/.current-site"

case "${1:-}" in
  list)
    echo "=== Sitios configurados ==="
    for f in "$SITES_DIR"/*.yaml; do
      basename "$f" .yaml
    done
    ;;
  status)
    if [ -f "$MARKER_FILE" ]; then
      SITE_ID=$(cat "$MARKER_FILE")
      SITE_FILE="$SITES_DIR/$SITE_ID.yaml"
      if [ -f "$SITE_FILE" ]; then
        echo "=== Sitio activo: $SITE_ID ==="
        echo "URL:     $(grep '^url:' "$SITE_FILE" | cut -d' ' -f2-)"
        echo "Builder: $(grep '^builder:' "$SITE_FILE" | cut -d' ' -f2-)"
        echo "Theme:   $(grep '^theme:' "$SITE_FILE" | cut -d' ' -f2-)"
      else
        echo "WARNING: Marker points to '$SITE_ID' but no config file found at $SITE_FILE"
        rm -f "$MARKER_FILE"
      fi
    else
      echo "No hay sitio activo. Usa: ./bin/switch-site.sh <site-id>"
    fi
    ;;
  *)
    if [ -z "${1:-}" ]; then
      echo "Uso: ./bin/switch-site.sh <site-id> | list | status"
      exit 1
    fi
    SITE_FILE="$SITES_DIR/$1.yaml"
    if [ ! -f "$SITE_FILE" ]; then
      echo "ERROR: No se encontró sitio '$1' en $SITES_DIR"
      echo "Sitios disponibles:"
      for f in "$SITES_DIR"/*.yaml; do
        echo "  - $(basename "$f" .yaml)"
      done
      exit 1
    fi
    echo "$1" > "$MARKER_FILE"
    export ACTIVE_SITE="$1"
    echo "✅ Switched to: $1"
    echo "   URL:     $(grep '^url:' "$SITE_FILE" | cut -d' ' -f2-)"
    echo "   Builder: $(grep '^builder:' "$SITE_FILE" | cut -d' ' -f2-)"
    ;;
esac
