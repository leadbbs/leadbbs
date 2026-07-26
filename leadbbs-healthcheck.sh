#!/bin/bash
# LeadBBS health check -- recovers from the AxonASP VM-pool wedge.
#
# AxonASP 2.3.5 leaks a VM-pool slot whenever a script hits default_script_timeout. After
# vm_pool_size such timeouts it stops executing scripts entirely -- but the process stays alive
# and keeps the port bound, so systemd's Restart=always never fires and the site returns 502
# until somebody notices. See docs/axonasp-divergences.md §32. This has happened on an idle
# public forum after only 31 requests, so it is not a stress-test curiosity.
#
# Install alongside the service (adjust paths for your deployment):
#
#   sudo install -m 755 leadbbs-healthcheck.sh /usr/local/bin/
#
#   # /etc/systemd/system/leadbbs-health.service
#   [Unit]
#   Description=Health check for LeadBBS (recovers from the §32 VM-pool wedge)
#   After=leadbbs.service
#   [Service]
#   Type=oneshot
#   ExecStart=/usr/local/bin/leadbbs-healthcheck.sh
#
#   # /etc/systemd/system/leadbbs-health.timer
#   [Unit]
#   Description=Probe LeadBBS every minute
#   [Timer]
#   OnBootSec=2min
#   OnUnitActiveSec=1min
#   AccuracySec=10s
#   [Install]
#   WantedBy=timers.target
#
#   sudo systemctl enable --now leadbbs-health.timer
#
# The forum service itself wants two settings for this to work well:
#   Environment=GOTRACEBACK=all     -- so SIGQUIT dumps every goroutine, not just one
#   TimeoutStopSec=20               -- so a wedged process gets SIGKILLed promptly
#
# Verify it rather than trusting it: `systemctl stop leadbbs` and watch the log below.
set -u

URL="${LEADBBS_HEALTH_URL:-http://127.0.0.1:9596/Boards.asp}"
SERVICE="${LEADBBS_SERVICE:-leadbbs}"
LOG="${LEADBBS_HEALTH_LOG:-/var/log/leadbbs-health.log}"
APPLOG="${LEADBBS_APP_LOG:-}"          # AxonASP's own log; where the goroutine dump lands
TIMEOUT="${LEADBBS_HEALTH_TIMEOUT:-10}"

probe() { curl -fsS -o /dev/null --max-time "$TIMEOUT" "$URL"; }
note()  { echo "$(date -Is)  $*" >> "$LOG"; }

probe && exit 0
sleep 5
probe && exit 0                        # one transient failure is not a wedge

# Before restarting, ask the Go runtime for a goroutine dump. SIGQUIT is answered even when the
# ASP workers are deadlocked, and the process is about to be killed anyway, so this costs
# nothing and is the only evidence that says what the blocked workers were waiting on.
PID=$(systemctl show "$SERVICE" -p MainPID --value 2>/dev/null)
note "unresponsive after 2 probes -- SIGQUIT pid ${PID:-?}, then restarting $SERVICE"
if [ -n "${PID:-}" ] && [ "$PID" != "0" ]; then
  [ -n "$APPLOG" ] && echo "=== $(date -Is) WEDGE DETECTED -- goroutine dump follows ===" >> "$APPLOG"
  kill -QUIT "$PID" 2>/dev/null
  sleep 5
fi

systemctl restart "$SERVICE"
sleep 8
if probe; then
  note "recovered"
else
  note "STILL DOWN after restart -- needs a human"
fi
