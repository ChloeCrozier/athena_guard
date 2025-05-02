#!/bin/bash
source "$(dirname "$0")/../../../.env"

SECURE_LOG="/var/log/secure"
BLACKLIST="$ATHENAGUARD_PATH/configurations/state/blacklisted_ips.txt"
DISCORD_WEBHOOK="$DISCORD_WEBHOOK_URL"

FOUND=$(grep "Failed password" "$SECURE_LOG" | awk '{print $(NF-3)}' | sort | uniq | grep -Ff "$BLACKLIST")

if [[ -n "$FOUND" ]]; then
    TIMESTAMP=$(date +"%F %T")
    IP_LIST=$(echo "$FOUND" | sed 's/^/🛑 /')

    MESSAGE="⛔ **Blacklisted IP Login Attempt** — $TIMESTAMP
$IP_LIST"

    JSON=$(jq -n --arg content "$MESSAGE" '{content: $content}')
    curl -H "Content-Type: application/json" -X POST -d "$JSON" "$DISCORD_WEBHOOK"
fi

