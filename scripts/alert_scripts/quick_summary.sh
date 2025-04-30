#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../.env"

SECURE_LOG="/var/log/secure"
LOG_FILE="$ATHENAGUARD_PATH/logs/extended_summary.log"
STATE_FILE="$ATHENAGUARD_PATH/configurations/state/last_summary_time"
mkdir -p "$(dirname "$STATE_FILE")"

CURRENT_YEAR=$(date +%Y)
NOW=$(date +%s)
LAST_RUN=$(cat "$STATE_FILE" 2>/dev/null || echo 0)

# Function: Convert log timestamps (e.g. Apr 30 12:34:55) to epoch
parse_ts() {
  local ts="$1"
  date -d "$ts $CURRENT_YEAR" +%s 2>/dev/null
}

get_new_lines() {
  local pattern="$1"
  grep "$pattern" "$SECURE_LOG" | while read -r line; do
    ts=$(echo "$line" | awk '{print $1, $2, $3}')
    epoch=$(parse_ts "$ts")
    if [[ $epoch -gt $LAST_RUN ]]; then
      echo "$line"
    fi
  done
}

NEW_SUDO=$(get_new_lines "COMMAND=")
NEW_FAILS=$(get_new_lines "Failed password")

# 🧾 Build summary
MESSAGE="🛡️ **AthenaGuard Summary** — $(date '+%Y-%m-%d %H:%M:%S')"
USERS=$(who | awk '{print $1}' | sort -u | paste -sd ' ')
MESSAGE+="\n✅ Logged in: ${USERS:-None}"

if [[ -n "$NEW_SUDO" ]]; then
  FORMATTED_SUDO=$(echo "$NEW_SUDO" | awk '{print $1, $2, $3, $(NF)}' | paste -sd ', ')
  MESSAGE+="\n🔐 Recent sudo: $FORMATTED_SUDO"
fi

if [[ -n "$NEW_FAILS" ]]; then
  FORMATTED_FAILS=$(echo "$NEW_FAILS" | awk '{print $1, $2, $3, $(NF-5)}' | paste -sd ', ')
  MESSAGE+="\n🛑 Failed logins: $FORMATTED_FAILS"
fi

# 💾 Log message
echo -e "$MESSAGE\n" >> "$LOG_FILE"

# 📣 Send to Discord
MAX_LEN=1900
if [[ ${#MESSAGE} -gt $MAX_LEN ]]; then
  ALERT="⚠️ AthenaGuard Summary — $(date '+%Y-%m-%d %H:%M:%S')\nToo many entries to display here.\n📄 See full summary: logs/extended_summary.log"
  curl -s -X POST -H "Content-Type: application/json" \
    -d "{\"content\": \"$ALERT\"}" \
    "$DISCORD_WEBHOOK_URL"
  echo "[⚠️ Truncated alert sent] $(date)"
elif [[ -n "$NEW_SUDO" || -n "$NEW_FAILS" ]]; then
  curl -s -X POST -H "Content-Type: application/json" \
    -d "{\"content\": \"$MESSAGE\"}" \
    "$DISCORD_WEBHOOK_URL"
  echo "[✅ Alert sent to Discord] $(date)"
else
  echo "[No new activity] $(date)"
fi

# Save current timestamp for next run
echo "$NOW" > "$STATE_FILE"

