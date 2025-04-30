#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../.env"

PROM_URL="http://localhost:$PROMETHEUS_PORT/api/v1/alerts"
TMP_DIR="$ATHENAGUARD_PATH/configurations/state"
CURRENT_FILE="$TMP_DIR/last_alerts.json"
LOG_FILE="$ATHENAGUARD_PATH/logs/rule_alerts.log"

mkdir -p "$TMP_DIR"

# Get current firing alerts from Prometheus
RESPONSE=$(curl -s "$PROM_URL")
FIRING=$(echo "$RESPONSE" | jq '.data.alerts[] | select(.state=="firing")')

# Exit if jq fails
if [ $? -ne 0 ]; then
  echo "[❌ Error parsing Prometheus response] $(date)" >> "$LOG_FILE"
  exit 1
fi

# Save current alerts state
echo "$RESPONSE" > "$CURRENT_FILE"

if [[ -z "$FIRING" ]]; then
  echo "[No new firing alerts] $(date '+%Y-%m-%d %H:%M:%S')" >> "$LOG_FILE"
  exit 0
fi

# Format the alert message
SUMMARY="🚨 *AthenaGuard Alert Summary* — $(date '+%Y-%m-%d %H:%M:%S')"
COUNT=0
DETAILS=""

while IFS= read -r alert; do
  ALERT_NAME=$(echo "$alert" | jq -r '.labels.alertname')
  SEVERITY=$(echo "$alert" | jq -r '.labels.severity')
  VALUE=$(echo "$alert" | jq -r '.annotations.description // empty')
  INSTANCE=$(echo "$alert" | jq -r '.labels.instance // "unknown"')

  DETAILS+="\n• [$SEVERITY] $ALERT_NAME on $INSTANCE — $VALUE"
  COUNT=$((COUNT + 1))
done < <(echo "$FIRING" | jq -c '.')

if [[ $COUNT -gt 0 ]]; then
  MESSAGE="$SUMMARY\n$DETAILS"

  if [ ${#MESSAGE} -gt 1900 ]; then
    SHORT="🚨 $COUNT alert(s) detected at $(date '+%Y-%m-%d %H:%M:%S')\n📄 See full: logs/rule_alerts.log"
    curl -s -X POST -H "Content-Type: application/json" \
      -d "{\"content\": \"$SHORT\"}" \
      "$DISCORD_WEBHOOK_URL"
    echo -e "$MESSAGE\n\n" >> "$LOG_FILE"
    echo "[⚠️ Truncated alert sent] $(date)"
  else
    curl -s -X POST -H "Content-Type: application/json" \
      -d "{\"content\": \"$MESSAGE\"}" \
      "$DISCORD_WEBHOOK_URL"
    echo -e "[✅ Rule alert sent to Discord] $(date)" >> "$LOG_FILE"
  fi
else
  echo "[No new alerts to send] $(date)" >> "$LOG_FILE"
fi

