#!/bin/bash
source "$(dirname "$0")/../../../.env"

ZOMBIES=$(ps aux | awk '$8=="Z"')
COUNT=$(echo "$ZOMBIES" | wc -l)

if (( COUNT > 0 )); then
    TIMESTAMP=$(date +"%F %T")
    MESSAGE="🧟 **Zombie Process Alert** — $TIMESTAMP
💀 Zombie Count: $COUNT"

    JSON=$(jq -n --arg content "$MESSAGE" '{content: $content}')
    curl -H "Content-Type: application/json" -X POST -d "$JSON" "$DISCORD_WEBHOOK_URL"
fi

