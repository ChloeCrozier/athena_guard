#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../.env"

NOW=$(date +%s)
CUTOFF=$((NOW - 300))  # 5 minutes
CURRENT_YEAR=$(date +%Y)
SECURE_LOG="/var/log/secure"
LOG_FILE="$ATHENAGUARD_PATH/logs/quick_summary.log"

log_to_epoch() {
  log_time="$1"
  date -d "$log_time $CURRENT_YEAR" +%s 2>/dev/null
}

# Get recent sudo lines
NEW_SUDO=$(awk -v cutoff="$CUTOFF" -v year="$CURRENT_YEAR" '
/COMMAND=/ {
  line = $0
  datetime = sprintf("%s %s %s", $1, $2, $3)
  cmd_ts = mktime(year " " month(datetime) " " day(datetime) " " hour(datetime) " " min(datetime) " " sec(datetime))
  if (cmd_ts >= cutoff) print line
}
function month(str) { return (index("JanFebMarAprMayJunJulAugSepOctNovDec", substr(str, 1, 3)) + 2) / 3 }
function day(str)  { return substr(str, 5, 2) }
function hour(str) { return substr(str, 8, 2) }
function min(str)  { return substr(str, 11, 2) }
function sec(str)  { return substr(str, 14, 2) }
' "$SECURE_LOG")

# Get recent failed login lines
NEW_FAILS=$(awk -v cutoff="$CUTOFF" -v year="$CURRENT_YEAR" '
/Failed password/ {
  line = $0
  datetime = sprintf("%s %s %s", $1, $2, $3)
  cmd_ts = mktime(year " " month(datetime) " " day(datetime) " " hour(datetime) " " min(datetime) " " sec(datetime))
  if (cmd_ts >= cutoff) print line
}
function month(str) { return (index("JanFebMarAprMayJunJulAugSepOctNovDec", substr(str, 1, 3)) + 2) / 3 }
function day(str)  { return substr(str, 5, 2) }
function hour(str) { return substr(str, 8, 2) }
function min(str)  { return substr(str, 11, 2) }
function sec(str)  { return substr(str, 14, 2) }
' "$SECURE_LOG")

# Build message
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

# Log it
echo -e "$MESSAGE\n" >> "$LOG_FILE"

# Handle Discord message length
MAX_LEN=1900
if [[ ${#MESSAGE} -gt $MAX_LEN ]]; then
  ALERT="⚠️ AthenaGuard Summary — $(date '+%Y-%m-%d %H:%M:%S')\nToo many entries to display here.\n📄 See full summary: logs/quick_summary.log"
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

