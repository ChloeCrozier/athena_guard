#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../.env"

PROM_API="http://$ATHENAGUARD_IP:$PROMETHEUS_PORT/api/v1/alerts"
LAST_FILE="$SCRIPT_DIR/.last_alerts.json"

# Get current firing alerts
ALERTS_JSON=$(curl -s "$PROM_API")
CURRENT=$(date +%s)

# Make sure we have something to compare to
if [ ! -f "$LAST_FILE" ]; then echo '{}' > "$LAST_FILE"; fi

# Loop through all firing alerts
echo "$ALERTS_JSON" | jq -c '.data.alerts[]' | while read -r alert; do
  ALERT_NAME=$(echo "$alert" | jq -r '.labels.alertname')
  ALERT_SUMMARY=$(echo "$alert" | jq -r '.annotations.summary')
  ALERT_DESC=$(echo "$alert" | jq -r '.annotations.description')
  ALERT_HASH=$(echo "$alert" | jq -r '.fingerprint')

  # Check if we’ve already sent this one recently
  LAST_SENT=$(jq -r --arg hash "$ALERT_HASH" '.[$hash] // 0' "$LAST_FILE")

  if (( CURRENT - LAST_SENT >= 60 )); then
    # Send Discord Alert
    curl -s -X POST -H "Content-Type: application/json" \
      -d "{\"content\":\"🚨 **$ALERT_NAME**\n$ALERT_SUMMARY\n$ALERT_DESC\"}" \
      "$DISCORD_WEBHOOK_URL"

    # Update the tracking file
    jq --arg hash "$ALERT_HASH" --argjson time "$CURRENT" '. + {($hash): $time}' "$LAST_FILE" > "$LAST_FILE.tmp" && mv "$LAST_FILE.tmp" "$LAST_FILE"
  fi
done

