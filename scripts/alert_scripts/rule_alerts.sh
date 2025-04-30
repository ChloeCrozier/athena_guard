#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../.env"

RULE_DIR="$ATHENAGUARD_PATH/alert_rules"
LOG_FILE="$ATHENAGUARD_PATH/logs/incremental_rule_alerts.log"
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

ALERT_OUTPUT=$(curl -s "http://localhost:$PROMETHEUS_PORT/api/v1/alerts" | jq '.data.alerts[] | select(.state=="firing") | "- " + .labels.alertname + ": " + .annotations.description')

if [[ -n "$ALERT_OUTPUT" ]]; then
  ALERT_COUNT=$(echo "$ALERT_OUTPUT" | wc -l)
  MESSAGE="🚨 **AthenaGuard Rule Alerts** — $TIMESTAMP\n📢 $ALERT_COUNT alert(s) triggered:\n$ALERT_OUTPUT"

  echo -e "$MESSAGE\n" >> "$LOG_FILE"

  if [[ ${#MESSAGE} -gt 1900 ]]; then
    SHORT_MSG="🚨 $ALERT_COUNT alerts triggered at $TIMESTAMP. See logs/incremental_rule_alerts.log"
    curl -s -X POST -H "Content-Type: application/json" -d "{\"content\": \"$SHORT_MSG\"}" "$DISCORD_WEBHOOK_URL"
    echo "[⚠️ Truncated rule alert sent] $TIMESTAMP"
  else
    curl -s -X POST -H "Content-Type: application/json" -d "{\"content\": \"$MESSAGE\"}" "$DISCORD_WEBHOOK_URL"
    echo "[✅ Rule alert sent to Discord] $TIMESTAMP"
  fi
else
  echo "[No new firing alerts] $TIMESTAMP"
fi

