#!/bin/bash
# =============================================================================
# DEPTH measurement: which of LeadBBS's `action=` verbs do the Playwright suites
# actually put on the wire?
#
# `action` is the app's universal verb parameter — every dispatcher in the tree is a
# `Select Case Request("action")`. The verb list is therefore the app's real command
# surface, and "how many of them does a browser ever send" is a far better depth metric
# than "how many files got touched".
#
# THE VERB LIST (denominator) is extracted from the source: every distinct value the
# application itself emits in a URL as `?action=V` / `&action=V`. That is a mechanical,
# reproducible rule and it yields 54 verbs.
#
# THE DRIVEN SET (numerator) is measured at the BROWSER, not by grepping the suites:
# lib.mjs hooks every Playwright context and appends the `action=` of every request it
# issues — URL or POST body, including the multipart bodies that only a real form
# produces (§20) — to $LEADBBS_VERBLOG. So a verb counts as driven only if a real
# browser really sent it. Whether the resulting STATE is asserted is the suite's job;
# each verb below is exercised by a suite that checks a DB row or the rendered page.
#
# Usage:
#   bash test/coverage/verb_census.sh [verblog]      # analyse an existing log
#   (test/coverage/browser_census.sh produces the log as part of its own run)
# =============================================================================
set -u
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
LOG="${1:-/tmp/leadbbs-verbs.log}"
TMP="$(mktemp -d)"

grep -rhoE '[?&]action=[A-Za-z_][A-Za-z0-9_]*' \
  --include='*.asp' --include='*.js' --include='*.htm' "$ROOT" \
  | sed 's/.*action=//' | sort -u > "$TMP/all.txt"

if [ ! -s "$LOG" ]; then
  echo "no verb log at $LOG — run test/coverage/browser_census.sh first"; exit 1
fi
sort -u "$LOG" | grep -v '^$' > "$TMP/seen.txt"

TOT=$(wc -l < "$TMP/all.txt")
DRV=$(comm -12 "$TMP/all.txt" "$TMP/seen.txt" | wc -l)
echo "BROWSER-DRIVEN action= VERBS: $DRV / $TOT ($(awk "BEGIN{printf \"%.1f\", $DRV*100/$TOT}")%)"
echo "NOT DRIVEN BY ANY BROWSER SUITE:"
comm -23 "$TMP/all.txt" "$TMP/seen.txt" | sed 's/^/  /'
rm -rf "$TMP"
