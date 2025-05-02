#!/bin/bash
source "$(dirname "$0")/../../../.env"

THRESHOLD=5
NOW=$(date +%s)
DISCORD_WEBHOOK="$DISCORD_WEBHOOK_URL"

FAIL_COUNT=$(grep "Failed password" /var/log/secure | awk -v now="$NOW" '
{
  cmd = "date -d \"" $1 " " $2 " " $3 "\" +%s"
  cmd | getline t
  close(cmd)
  if (now - t < 60) print
}' | wc -l)

if (( FAIL_COUNT > THRESHOLD )); then
    TIMESTAMP=$(date +"%F %T")
    MESSAGE="🚨 **Login Failure Spike** — $TIMESTAMP
❗ $FAIL_COUNT failed logins in the last 60 seconds"

    JSON=$(jq -n --arg content "$MESSAGE" '{content: $content}')
    curl -H "Content-Type: application/json" -X POST -d "$JSON" "$DISCORD_WEBHOOK"
fi

