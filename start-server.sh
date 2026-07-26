#!/bin/bash
# Start AxonASP serving this checkout. Override AXONASP_HOME / LEADBBS_CONFIG if your
# install lives elsewhere; both defaults match a stock Debian/Ubuntu .deb install.
set -euo pipefail
AXONASP_HOME="${AXONASP_HOME:-/opt/axonasp}"
LEADBBS_CONFIG="${LEADBBS_CONFIG:-$(cd "$(dirname "$0")" && pwd)/axonasp.toml}"

if [ ! -f "$LEADBBS_CONFIG" ]; then
  echo "No config at $LEADBBS_CONFIG — copy axonasp.example.toml, set web_root, and retry." >&2
  exit 1
fi
cd "$AXONASP_HOME" && exec ./axonasp-http -c "$LEADBBS_CONFIG"
