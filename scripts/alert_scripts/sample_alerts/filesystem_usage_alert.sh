#!/bin/bash
source "$(dirname "$0")/../../../.env"

DISCORD_WEBHOOK="$DISCORD_WEBHOOK_URL"
THRESHOLD=80
ALERTS=""

for dir in /home /tmp; do
    USAGE=$(df "$dir" | tail -1 | awk '{print $5}' | tr -d '%')
    if (( USAGE > THRESHOLD )); then
        ALERTS+="📁 $dir: ${USAGE}% used\n"
    fi
done

if [[ -n "$ALERTS" ]]; then
    TIMESTAMP=$(date +"%F %T")
    MESSAGE="💽 **Filesystem Usage Alert** — $TIMESTAMP
$ALERTS"

    JSON=$(jq -n --arg content "$MESSAGE" '{content: $content}')
    curl -H "Content-Type: application/json" -X POST -d "$JSON" "$DISCORD_WEBHOOK"
fi

