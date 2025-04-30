
#!/bin/bash

# Load environment
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../.env"

STATE_DIR="$ATHENAGUARD_PATH/tmp/summary_state"
CURRENT_STATE="$STATE_DIR/current_summary.json"
LAST_STATE="$STATE_DIR/last_summary.json"
LOGFILE="$ATHENAGUARD_PATH/logs/summary.log"

mkdir -p "$STATE_DIR"

# Helper to send to Discord
send_discord_alert() {
  local message="$1"
  curl -s -X POST -H "Content-Type: application/json" \
    -d "{\"content\": \"$message\"}" \
    "$DISCORD_WEBHOOK_URL" > /dev/null
}

# Get current login/sudo/fail status
get_current_state() {
  LOG_FILE="/var/log/secure"

  LOGGED_IN=$(who | awk '{print $1}' | sort | uniq | xargs)
  SUDO=$(grep "COMMAND=" "$LOG_FILE" | tail -n 10 | awk '{print $1, $2, $3, $(NF)}' | xargs)
  FAILS=$(grep "Failed password" "$LOG_FILE" | tail -n 10 | awk '{print $1, $2, $3, $(NF-5)}' | xargs)

  echo "{\"logins\": \"$LOGGED_IN\", \"sudo\": \"$SUDO\", \"fails\": \"$FAILS\"}" > "$CURRENT_STATE"
}

# Load and compare
get_current_state

# If no last state, initialize and exit
if [[ ! -f "$LAST_STATE" ]]; then
  cp "$CURRENT_STATE" "$LAST_STATE"
  echo "[Init] Snapshot saved at $(date)" >> "$LOGFILE"
  exit 0
fi

DIFF=$(diff "$CURRENT_STATE" "$LAST_STATE")

if [[ -z "$DIFF" ]]; then
  echo "[No Change] $(date)" >> "$LOGFILE"
  exit 0
else
  # Format message
  LOGINS=$(jq -r .logins "$CURRENT_STATE")
  SUDO=$(jq -r .sudo "$CURRENT_STATE")
  FAILS=$(jq -r .fails "$CURRENT_STATE")

  MESSAGE="🛡️ AthenaGuard Summary — $(date +'%Y-%m-%d %H:%M:%S')"
  [[ ! -z "$LOGINS" ]] && MESSAGE+="\n✅ Logged in: $LOGINS"
  [[ ! -z "$SUDO" ]] && MESSAGE+="\n🔐 Recent sudo: $SUDO"
  [[ ! -z "$FAILS" ]] && MESSAGE+="\n🛑 Failed logins: $FAILS"

  send_discord_alert "$MESSAGE"
  echo "$MESSAGE" >> "$LOGFILE"
  cp "$CURRENT_STATE" "$LAST_STATE"
fi

