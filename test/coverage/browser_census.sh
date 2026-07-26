#!/bin/bash

# Where the server lives (see test/browser/run-all.sh).
LEADBBS_HOME="${LEADBBS_HOME:-$(cd ../.. && pwd)}"   # cwd is this script's dir (see the cd above)
LEADBBS_START="${LEADBBS_START:-$LEADBBS_HOME/start-server.sh}"
LEADBBS_LOG="${LEADBBS_LOG:-$LEADBBS_HOME/axonasp.log}"
# =============================================================================
# BREADTH measurement: which source files do the PLAYWRIGHT suites actually execute?
#
# The original census (run_census.sh) exercises the site with a curl crawl, which answers
# "can this file run", not "does the test suite drive it". This runs the same instrumentation
# but exercises it with test/browser/*.mjs, so the number means: the browser suites reached
# this code.
#
# run-all.sh restarts AxonASP before every suite (README §32), and a restart wipes the
# Application-backed accumulator — so this dumps coverage after EACH suite and merges.
#
# Usage (from the repo root, CLEAN git tree — it reverts via git checkout):
#   bash test/coverage/browser_census.sh [base_url]
# =============================================================================
set -u
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
BASE="${1:-http://localhost:9596}"
OUT="$(mktemp -d)"
export PLAYWRIGHT_BROWSERS_PATH="${PLAYWRIGHT_BROWSERS_PATH:-$HOME/.cache/ms-playwright}"
BUN="${BUN:-$(command -v bun 2>/dev/null || echo "$HOME/.bun/bin/bun")}"

restart() {
  local old new i
  old=$(pgrep -f 'axonasp-http -c' | head -1)
  [ -n "$old" ] && kill -9 "$old" 2>/dev/null
  for i in $(seq 1 30); do kill -0 "$old" 2>/dev/null || break; sleep 1; done
  for i in $(seq 1 30); do ss -tln 2>/dev/null | grep -q ':9596 ' || break; sleep 1; done
  (cd "$LEADBBS_HOME" && setsid --fork "$LEADBBS_START" >"$LEADBBS_LOG" 2>&1 </dev/null &)
  disown -a 2>/dev/null || true
  for i in $(seq 1 30); do
    new=$(pgrep -f 'axonasp-http -c' | head -1)
    [ -n "$new" ] && [ "$new" != "$old" ] && curl -s -o /dev/null --max-time 5 "$BASE/Boards.asp" && return 0
    sleep 2
  done
  echo "!!! server did not restart"; exit 1
}

echo "[1/4] instrument"
# Clear the manifest BEFORE probing, not after: instrument.py writes it, so removing it
# afterwards threw away the record of everything that had just been modified and left the
# whole instrumented tree behind at the end of the run.
export LEADBBS_INSTRUMENT_MANIFEST="${LEADBBS_INSTRUMENT_MANIFEST:-/tmp/leadbbs-instrumented.txt}"
rm -f "$LEADBBS_INSTRUMENT_MANIFEST"
python3 "$ROOT/test/coverage/instrument.py"
cp "$ROOT/test/coverage/covdump.asp" "$ROOT/_covdump.asp"

# DEPTH is measured in the same run: lib.mjs appends every `action=` verb a Playwright
# context puts on the wire here, and verb_census.sh turns it into a number afterwards.
export LEADBBS_VERBLOG="${LEADBBS_VERBLOG:-/tmp/leadbbs-verbs.log}"
: > "$LEADBBS_VERBLOG"

echo "[2/4] run each browser suite against a fresh server, dumping coverage after each"
cd "$ROOT/test/browser"
for s in [0-9][0-9]-*.mjs; do
  restart
  # Sample the accumulator WHILE the suite runs. Several pages call
  # Application.Contents.RemoveAll — manage/update.asp does it on every render, through
  # restartbbs() — which erases everything recorded so far. With a single dump at the end,
  # one such page late in a suite loses that whole suite's coverage; suite 17 was reporting
  # 23 files instead of ~130 for exactly this reason. Sampling costs one request every few
  # seconds and bounds the loss to that window.
  ( while :; do
      curl -s --max-time 10 "$BASE/_covdump.asp" | tr -d '\r' | tr 'A-Z' 'a-z' >> "$OUT/covered_raw.txt"
      sleep 3
    done ) &
  sampler=$!
  "$BUN" "$s" > "$OUT/suite_$s.log" 2>&1
  kill "$sampler" 2>/dev/null; wait "$sampler" 2>/dev/null
  printf '  %-28s %s\n' "$s" "$(grep -oE '=== .*passed ===' "$OUT/suite_$s.log" | head -1)"
  curl -s --max-time 30 "$BASE/_covdump.asp" | tr -d '\r' | tr 'A-Z' 'a-z' >> "$OUT/covered_raw.txt"
  # Re-probe. The suites make the application regenerate some of its own sources
  # (inc/IncHtm/*, article/inc/cache/CACHE_*, inc/*_Setup.asp), and every rewrite drops the
  # probe; without this a file a LATER suite really does execute is reported unreached.
  python3 "$ROOT/test/coverage/instrument.py" > /dev/null
done
cd "$ROOT"

echo "[3/4] compute"
sort -u "$OUT/covered_raw.txt" | grep -v '^$' > "$OUT/covered.txt"
# The denominator is SOURCE files. A .asp/.inc/.asa holding no server code is data with an
# .asp extension — LeadBBS ships several (the registration agreement, the CMS contact blocks,
# the channel-list records, and data/global.asa, the original binary Access database) which
# are read with ADODB_LoadFile and never executed. instrument.py skips them for the same
# reason, so counting them could only ever penalise files that have no code to run. The
# `runat=` alternative keeps inc/sha1.asp, which is server-side JScript with no <% at all.
# _covdump.asp is this script's own probe, not part of the application.
find "$ROOT" -type f \( -name '*.asp' -o -name '*.asa' -o -name '*.inc' \) ! -type l \
  | grep -vE '/\.git/|/_test/|/_diag/|/test/|/_covdump\.asp$' \
  | xargs grep -lE '<%|runat *=' 2>/dev/null \
  | sed "s|^$ROOT/||" | tr 'A-Z' 'a-z' | sort -u > "$OUT/all.txt"
TOT=$(wc -l < "$OUT/all.txt"); COV=$(comm -12 "$OUT/all.txt" "$OUT/covered.txt" | wc -l)
echo "BROWSER-DRIVEN COVERAGE: $COV / $TOT files ($(awk "BEGIN{printf \"%.1f\", $COV*100/$TOT}")%)"
echo "NOT REACHED BY ANY BROWSER SUITE:"
comm -23 "$OUT/all.txt" "$OUT/covered.txt" | sed 's/^/  /'

echo
bash "$ROOT/test/coverage/verb_census.sh" "$LEADBBS_VERBLOG"

echo "[4/4] revert instrumentation"
# Revert ONLY the files instrument.py probed. This used to be `git checkout -- .`, which
# reverts the whole working tree — it silently threw away edits that were in progress
# alongside the census more than once.
rm -f "$ROOT/_covdump.asp"
MANIFEST="${LEADBBS_INSTRUMENT_MANIFEST:-/tmp/leadbbs-instrumented.txt}"
if [ -s "$MANIFEST" ]; then
  # one path per invocation: a single unmatched pathspec must not abort the whole cleanup
  (cd "$ROOT" && tr '\n' '\0' < "$MANIFEST" | xargs -0 -r -n 1 git checkout -- 2>/dev/null)
  rm -f "$MANIFEST"
else
  echo "!!! no instrumentation manifest at $MANIFEST — leaving the tree alone"
fi
echo "artifacts in $OUT (verb log: $LEADBBS_VERBLOG)"
