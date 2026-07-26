#!/bin/bash
# Run every browser suite in order and summarise.
#
# These drive the REAL UI in headless Chromium (Playwright) — real forms, real links,
# real AJAX — and assert against the database row each action was supposed to write.
# Nearly every AxonASP divergence in the README was found this way, after the same flow
# had passed a curl-level test.
#
# Prereqs: AxonASP serving the site (default http://localhost:9596), MariaDB up,
# an admin account (LEADBBS_ADMIN_USER/_PASS/_ANSWER, defaulting to the install defaults),
# and the loopback-gated helpers in
# test/ and _test/ present. Playwright + a Chromium build must be installed.
#
# Usage: bash test/browser/run-all.sh [base_url]
set -u
cd "$(dirname "$0")"
export LEADBBS_URL="${1:-http://localhost:9596}"
export PLAYWRIGHT_BROWSERS_PATH="${PLAYWRIGHT_BROWSERS_PATH:-$HOME/.cache/ms-playwright}"
BUN="${BUN:-$(command -v bun 2>/dev/null || echo "$HOME/.bun/bin/bun")}"

# README §32: AxonASP leaks a VM pool slot on every script timeout, and once vm_pool_size of
# them have leaked the server deadlocks for good. Heap pressure is one route in (it retains
# ~5 MB per distinct page path), but load alone is another — 07-links tripped it at 320 MB.
# There is no in-process recovery, so the harness gives each suite a FRESH server. It costs
# ~15 s per suite and makes the whole run deterministic; without it, whichever suite follows
# the crawler inherits a poisoned server and reports phantom failures.

# Where the server lives. Defaults suit a checkout that is its own web root; override
# LEADBBS_HOME/LEADBBS_START if AxonASP is started from somewhere else.
LEADBBS_HOME="${LEADBBS_HOME:-$(cd ../.. && pwd)}"   # cwd is this script's dir (see the cd above)
LEADBBS_START="${LEADBBS_START:-$LEADBBS_HOME/start-server.sh}"
LEADBBS_LOG="${LEADBBS_LOG:-$LEADBBS_HOME/axonasp.log}"

restart_server() {
  local old new_pid i
  old=$(pgrep -f 'axonasp-http -c' | head -1)
  if [ -n "$old" ]; then
    kill -9 "$old" 2>/dev/null
    # wait for it to actually die AND release the port: a deadlocked AxonASP ignores
    # SIGTERM, and if the port is still bound the replacement exits with
    # "address already in use" while the OLD, still-wedged process keeps answering —
    # which looks like a successful restart and silently poisons every later suite.
    for i in $(seq 1 30); do kill -0 "$old" 2>/dev/null || break; sleep 1; done
    for i in $(seq 1 30); do ss -tln 2>/dev/null | grep -q ":${LEADBBS_URL##*:} " || break; sleep 1; done
  fi
  (cd "$LEADBBS_HOME" && setsid --fork "$LEADBBS_START" >"$LEADBBS_LOG" 2>&1 </dev/null &)
  disown -a 2>/dev/null || true
  for i in $(seq 1 30); do
    new_pid=$(pgrep -f 'axonasp-http -c' | head -1)
    if [ -n "$new_pid" ] && [ "$new_pid" != "$old" ] \
       && curl -s -o /dev/null --max-time 5 "$LEADBBS_URL/Boards.asp"; then
      return 0
    fi
    sleep 2
  done
  echo "!!! AxonASP did not restart cleanly (old=$old new=$new_pid) — aborting run"
  exit 1
}

pass=0; fail=0; failed=()
for s in [0-9][0-9]-*.mjs; do
  restart_server
  echo "=============== $s"
  "$BUN" "$s" > /tmp/leadbbs-suite.$$ 2>&1
  rc=$?
  grep -E '^(PASS|FAIL|===|FAILED| )' /tmp/leadbbs-suite.$$
  if [ $rc -eq 0 ]; then pass=$((pass+1)); else fail=$((fail+1)); failed+=("$s"); fi
done
rm -f /tmp/leadbbs-suite.$$
echo "==============================================="
echo "suites passed: $pass, failed: $fail"
[ $fail -gt 0 ] && echo "failing: ${failed[*]}"
exit $((fail > 0))
