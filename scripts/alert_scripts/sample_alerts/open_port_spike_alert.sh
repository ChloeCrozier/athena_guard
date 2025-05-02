#!/bin/bash
source "$(dirname "$0")/../../../.env"

touch "$LAST_PORTS_PATH"
NEW_PORTS=$(comm -23 <(sort "$CURRENT_PORTS_PATH") <(sort "$LAST_PORTS_PATH"))

if [[ -n "$NEW_PORTS" ]]; then
    TIMESTAMP=$(date +"%F %T")
    PORT_LIST=$(echo "$NEW_PORTS" | sed 's/^/🆕 /')

    OLD_COUNT=$(wc -l < "$LAST_PORTS_PATH")
    NEW_COUNT=$(wc -l < "$CURRENT_PORTS_PATH")

    MESSAGE="🌐 **Open Port Spike** — $TIMESTAMP
🔢 Count: $OLD_COUNT ➡️ $NEW_COUNT
$PORT_LIST"

    JSON=$(jq -n --arg content "$MESSAGE" '{content: $content}')
    curl -H "Content-Type: application/json" -X POST -d "$JSON" "$DISCORD_WEBHOOK_URL"
fi

cp "$CURRENT_PORTS_PATH" "$LAST_PORTS_PATH"

