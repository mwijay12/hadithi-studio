#!/bin/bash
# Huweka preview hai: server ya ndani + tunnel ya Cloudflare.
#
# Kwa nini tunahitaji hii: `cloudflared` quick tunnel hudondoka, na SSH
# tunnel (`localhost.run`) hukaa "hai" kama process wakati upstream imekwisha
# kufa. Kwa hivyo hukagua kwa **HTML halisi**, si kwa kuwepo kwa process.
#
# TANBIHI: hatutumii `pkill -f "cloudflared tunnel"` kwa sababu script hii
# yenyewe ina maneno hayo kwenye cmdline yake — pkill ingejiua yenyewe.
# Tunatumia faili za PID badala yake.

set -u

PROJECT=/root/.accio/accounts/1794274703/agents/DID-82AD6B-2882AD6BU1792030-00965695d0a72fe745f1-4C995C/project
WEB="$PROJECT/build/web"
CF=/home/accio/bin/cloudflared
PORT=8080
URLFILE=/tmp/hadithi_url.txt
SRV_PIDFILE=/tmp/hadithi_srv.pid
CF_PIDFILE=/tmp/hadithi_cf.pid

log() { echo "$(date '+%H:%M:%S') $*" >> /tmp/hadithi_keepalive.log; }

start_server() {
  if [ -f "$SRV_PIDFILE" ]; then kill "$(cat "$SRV_PIDFILE")" 2>/dev/null; fi
  sleep 1
  cd "$WEB" || return 1
  nohup python3 "$PROJECT/tool/hadithi_preview_server.py" "$WEB" "$PORT" \
    >/tmp/hadithi_http.log 2>&1 &
  echo $! > "$SRV_PIDFILE"
  sleep 3
  log "server started pid=$(cat "$SRV_PIDFILE")"
}

start_tunnel() {
  if [ -f "$CF_PIDFILE" ]; then kill "$(cat "$CF_PIDFILE")" 2>/dev/null; fi
  sleep 2
  rm -f /tmp/hadithi_cf.log
  nohup "$CF" tunnel --url "http://localhost:$PORT" --no-autoupdate \
    >/tmp/hadithi_cf.log 2>&1 &
  echo $! > "$CF_PIDFILE"
  # Cloudflared huchukua ~20-25s kupata URL na kujiandikisha.
  for _ in $(seq 1 12); do
    sleep 5
    NEW=$(grep -oE "https://[a-z0-9-]+\.trycloudflare\.com" /tmp/hadithi_cf.log | head -1)
    if [ -n "$NEW" ]; then echo "$NEW" > "$URLFILE"; log "tunnel up: $NEW"; return 0; fi
  done
  log "tunnel FAILED to produce a URL"
  return 1
}

while true; do
  # 1) Server ya ndani
  if ! curl -s -m 6 -o /dev/null "http://127.0.0.1:$PORT/index.html"; then
    log "local server down -> restarting"
    start_server
  fi

  # 2) Tunnel — hukagua maudhui halisi ya HTML
  U=$(cat "$URLFILE" 2>/dev/null || true)
  OK=0
  if [ -n "$U" ]; then
    if curl -s -m 15 -H 'Cache-Control: no-cache' "$U/?cb=$RANDOM" 2>/dev/null \
        | grep -q "Hadithi Studio"; then
      OK=1
    fi
  fi
  if [ "$OK" -ne 1 ]; then
    log "tunnel down ($U) -> restarting"
    start_tunnel
  fi

  sleep 60
done
