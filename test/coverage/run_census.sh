#!/bin/bash
# =============================================================================
# Reproducible runtime coverage census for LeadBBS-on-AxonASP.
# Instruments every source file, exercises the site (guest + admin + write),
# reports covered/total, then reverts the instrumentation via git.
#
# Run from the repo root. Requires: a clean git tree, AxonASP restartable,
# MariaDB up, an admin account (see LEADBBS_ADMIN_* in test/browser/lib.mjs), board 100.
# Usage: bash test/coverage/run_census.sh <axonasp_dir> <base_url> <toml>
# =============================================================================
set -u
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
AXDIR="${1:-/opt/axonasp}"; BASE="${2:-http://localhost:8801}"; TOML="${3:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/axonasp.toml}"
SC="$(mktemp -d)"

echo "[1/5] instrument"; python3 "$ROOT/test/coverage/instrument.py"
# ensure the dump page is reachable under the web root
cp "$ROOT/test/coverage/covdump.asp" "$ROOT/_covdump.asp" 2>/dev/null || true
echo "[2/5] restart server"; (cd "$AXDIR"; pkill -x axonasp-http; sleep 1; ./axonasp-http -c "$TOML" >/dev/null 2>&1 &) ; sleep 3
echo "[3/5] exercise"; bash "$ROOT/test/coverage/exercise.sh" "$BASE"
echo "[4/5] collect + compute"
curl -s "$BASE/_covdump.asp" | tr -d '\r' | tr 'A-Z' 'a-z' | sort -u > "$SC/covered.txt"
find "$ROOT" -type f \( -name '*.asp' -o -name '*.asa' -o -name '*.inc' \) ! -type l \
  | grep -vE '/\.git/|/_test/|/_diag/|/test/' | sed "s|^$ROOT/||" | tr 'A-Z' 'a-z' | sort -u > "$SC/all.txt"
TOT=$(wc -l < "$SC/all.txt"); COV=$(comm -12 "$SC/all.txt" "$SC/covered.txt" | wc -l)
echo "COVERAGE: $COV / $TOT files ($(awk "BEGIN{printf \"%.1f\", $COV*100/$TOT}")%)"
echo "UNCOVERED:"; comm -23 "$SC/all.txt" "$SC/covered.txt" | sed 's/^/  /'
echo "[5/5] revert instrumentation"; rm -f "$ROOT/_covdump.asp"; (cd "$ROOT"; git checkout -- .)
echo "done. artifacts in $SC"
