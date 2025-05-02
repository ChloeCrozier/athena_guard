#!/bin/bash
# network_change_alert.sh

# Load .env
source "$(dirname "$0")/../../../.env"

CURRENT_FILE="$ATHENAGUARD_PATH/configurations/state/current_network.txt"
LAST_FILE="$ATHENAGUARD_PATH/configurations/state/last_network.txt"
DISCORD_WEBHOOK="$DISCORD_WEBHOOK_URL"

# Ensure last file exists
if [ ! -f "$LAST_FILE" ]; then
    touch "$LAST_FILE"
fi

# Compare and get new changes
NEW_CHANGES=$(comm -23 <(sort "$CURRENT_FILE") <(sort "$LAST_FILE"))

if [[ -n "$NEW_CHANGES" ]]; then
    TIMESTAMP=$(date +"%F %T")
    CHANGE_LIST=$(echo "$NEW_CHANGES" | sed 's/^/• /')

    # Full message with newlines
    MESSAGE="📡 **AthenaGuard Network Alert** — $TIMESTAMP
**New Network Interfaces or IPs Detected**:
$CHANGE_LIST"

    # Use jq to escape multiline JSON safely
    JSON_PAYLOAD=$(jq -n --arg content "$MESSAGE" '{content: $content}')

    curl -H "Content-Type: application/json" -X POST \
      -d "$JSON_PAYLOAD" "$DISCORD_WEBHOOK"
fi

# Update the snapshot
cp "$CURRENT_FILE" "$LAST_FILE"

