#!/bin/bash
source "$(dirname "$0")/../../../.env"

CURRENT_FILE="$ATHENAGUARD_PATH/configurations/state/current_sudo_commands.txt"
LAST_FILE="$ATHENAGUARD_PATH/configurations/state/last_sudo_commands.txt"
DISCORD_WEBHOOK="$DISCORD_WEBHOOK_URL"

touch "$LAST_FILE"
NEW_COMMANDS=$(comm -23 <(sort "$CURRENT_FILE") <(sort "$LAST_FILE"))

if [[ -n "$NEW_COMMANDS" ]]; then
    TIMESTAMP=$(date +"%F %T")
    CMD_LIST=$(echo "$NEW_COMMANDS" | sed 's/^/🔐 /')

    MESSAGE="⚠️ **Suspicious Sudo Usage** — $TIMESTAMP
$CMD_LIST"

    JSON=$(jq -n --arg content "$MESSAGE" '{content: $content}')
    curl -H "Content-Type: application/json" -X POST -d "$JSON" "$DISCORD_WEBHOOK"
fi

cp "$CURRENT_FILE" "$LAST_FILE"

