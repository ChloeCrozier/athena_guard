#!/bin/bash

# Load environment
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../.env"

STATE_DIR="$ATHENAGUARD_PATH/tmp/summary_state"
CURRENT_STATE="$STATE_DIR/current_summary.json"
LAST_STATE="$STATE_DIR/last_summary.json"
LAST_CHECK_FILE="$STATE_DIR/last_check_time"
LOGFILE="$ATHENAGUARD_PATH/logs/summary.log"

mkdir -p "$STATE_DIR"

# Get current timestamp and last check time
NOW_EPOCH=$(date +%s)
if [[ -f "$LAST_CHECK_FILE" ]]; then
  LAST_EPOCH=$(cat "$LAST_CHECK_FILE")
else
  LAST_EPOCH=0
fi
echo "$NOW_EPOCH" > "$LAST_CHECK_FILE"

# Helper to send to Discord
send_discord_alert() {
  local message="$1"
  curl -s -X POST -H "Content-Type: application/json" \
    -d "{\"content\": \"$message\"}" \
    "$DISCORD_WEBHOOK_URL" > /dev/null
}

# Basic system state (always included)
LOGGED_IN=$(who | awk '{print $1}' | sort | uniq | xargs)
OPEN_PORTS=$(ss -tuln | grep -c LISTEN)

# New sudo commands since last check
NEW_SUDO=$(awk -v last="$LAST_EPOCH" '
  $0 ~ /COMMAND=/ {
    timestamp = sprintf("%s %s %s", $1, $2, $3)
    cmd_epoch = mktime(gensub(/:/, " ", "g", timestamp " 00"))
    if (cmd_epoch > last) {
      user = $6
      cmd = $NF
      print "- " user ": " timestamp " " cmd
    }
  }
' /var/log/secure)

# New failed logins since last check
NEW_FAILS=$(awk -v last="$LAST_EPOCH" '
  $0 ~ /Failed password/ {
    timestamp = sprintf("%s %s %s", $1, $2, $3)
    fail_epoch = mktime(gensub(/:/, " ", "g", timestamp " 00"))
    if (fail_epoch > last) {
      user = $(NF-5)
      print "- " user ": " timestamp
    }
  }
' /var/log/secure)

# Exit if nothing changed
if [[ -z "$NEW_SUDO" && -z "$NEW_FAILS" ]]; then
  echo "[No Change] $(date)" >> "$LOGFILE"
  exit 0
fi

# Build the summary message
MESSAGE="🛡️ AthenaGuard Summary — $(date +'%Y-%m-%d %H:%M:%S')"
MESSAGE+="\n\n✅ Logged in: $LOGGED_IN"
MESSAGE+="\n📡 Open ports: $OPEN_PORTS"

[[ ! -z "$NEW_SUDO" ]] && MESSAGE+="\n\n🔐 New sudo commands:\n$NEW_SUDO"
[[ ! -z "$NEW_FAILS" ]] && MESSAGE+="\n\n🛑 Failed login attempts:\n$NEW_FAILS"

# Send and log
send_discord_alert "$MESSAGE"
echo -e "$MESSAGE\n" >> "$LOGFILE"

