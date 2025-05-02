#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../.env"

PROM_URL="http://localhost:$PROMETHEUS_PORT/api/v1/alerts"
TMP_DIR="$ATHENAGUARD_PATH/configurations/state"
CURRENT_FILE="$TMP_DIR/last_alerts.json"
LOG_FILE="$ATHENAGUARD_PATH/logs/rule_alerts.log"

mkdir -p "$TMP_DIR"

# Fetch alerts from Prometheus
RESPONSE=$(curl -s "$PROM_URL")

if ! echo "$RESPONSE" | jq . > /dev/null 2>&1; then
  echo "[❌ Invalid Prometheus response] $(date)" >> "$LOG_FILE"
  exit 1
fi

# Save full response
echo "$RESPONSE" > "$CURRENT_FILE"

FIRING=$(echo "$RESPONSE" | jq '.data.alerts[] | select(.state=="firing")')
PENDING=$(echo "$RESPONSE" | jq '.data.alerts[] | select(.state=="pending")')

SUMMARY="🛡️ **AthenaGuard Alert Summary** — $(date '+%Y-%m-%d %H:%M:%S')"
FIRING_LIST=""
PENDING_LIST=""
FIRING_COUNT=0
PENDING_COUNT=0

# Format firing alerts
while IFS= read -r alert; do
  ALERT_NAME=$(echo "$alert" | jq -r '.labels.alertname')
  SEVERITY=$(echo "$alert" | jq -r '.labels.severity // "info"')
  DESC=$(echo "$alert" | jq -r '.annotations.description // "No description"')
  FIRING_LIST+="\n• [$SEVERITY] **$ALERT_NAME** — $DESC"
  FIRING_COUNT=$((FIRING_COUNT + 1))
done < <(echo "$FIRING" | jq -c '.')

# Format pending alerts
while IFS= read -r alert; do
  ALERT_NAME=$(echo "$alert" | jq -r '.labels.alertname')
  DESC=$(echo "$alert" | jq -r '.annotations.description // "No description"')
  PENDING_LIST+="\n• ⏳ **$ALERT_NAME** (pending) — $DESC"
  PENDING_COUNT=$((PENDING_COUNT + 1))
done < <(echo "$PENDING" | jq -c '.')

# Compose final message
MESSAGE="$SUMMARY"

if [[ $FIRING_COUNT -gt 0 ]]; then
  MESSAGE+="\n\n🚨 **Firing Alerts ($FIRING_COUNT):**$FIRING_LIST"
fi

if [[ $PENDING_COUNT -gt 0 ]]; then
  MESSAGE+="\n\n⏳ **Pending Alerts ($PENDING_COUNT):**$PENDING_LIST"
fi

# Send to Discord if anything is active
if [[ $FIRING_COUNT -gt 0 || $PENDING_COUNT -gt 0 ]]; then
  if [ ${#MESSAGE} -gt 1900 ]; then
    SHORT="🚨 $FIRING_COUNT firing / $PENDING_COUNT pending alerts at $(date '+%Y-%m-%d %H:%M')\n📄 See: logs/rule_alerts.log"
    curl -s -X POST -H "Content-Type: application/json" \
      -d "{\"content\": \"$SHORT\"}" "$DISCORD_WEBHOOK_URL"
    echo -e "$MESSAGE\n\n" >> "$LOG_FILE"
    echo "[⚠️ Truncated alert sent] $(date)" >> "$LOG_FILE"
  else
    curl -s -X POST -H "Content-Type: application/json" \
      -d "{\"content\": \"$MESSAGE\"}" "$DISCORD_WEBHOOK_URL"
    echo "[✅ Sent rule alert to Discord] $(date)" >> "$LOG_FILE"
  fi
else
  echo "[ℹ️ No alerts to send] $(date)" >> "$LOG_FILE"
fi

