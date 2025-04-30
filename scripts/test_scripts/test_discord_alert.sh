#!/bin/bash

# Load environment variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../.env"

LOG_FILE="/var/log/secure"

# Helper function to send to Discord
send_discord_alert() {
  local message="$1"
  curl -s -X POST -H "Content-Type: application/json" \
    -d "{\"content\": \"$message\"}" \
    "$DISCORD_WEBHOOK_URL" > /dev/null
}

# Track last alert time using a state file
STATE_FILE="/tmp/athenaguard_last_failed_login.log"

# Get last alert timestamp if it exists
LAST_ALERT_TIME=0
if [[ -f "$STATE_FILE" ]]; then
  LAST_ALERT_TIME=$(cat "$STATE_FILE")
fi

# Loop over new failed login attempts since last run
grep "Failed password" "$LOG_FILE" | while read -r line; do
  # Extract time and user
  LOG_TS=$(echo "$line" | awk '{print $1, $2, $3}')
  LOG_EPOCH=$(date -d "$LOG_TS" +"%s" 2>/dev/null)

  # Only continue if timestamp is valid and newer than last alert
  if [[ "$LOG_EPOCH" =~ ^[0-9]+$ && "$LOG_EPOCH" -gt "$LAST_ALERT_TIME" ]]; then
    USER=$(echo "$line" | awk '{print $(NF-5)}')
    send_discord_alert "🛑 Failed login attempt for user \`$USER\` at $LOG_TS"
    
    # Update last alert time
    echo "$LOG_EPOCH" > "$STATE_FILE"
  fi
done

