#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../../.env"

STATE_FILE="$ATHENAGUARD_PATH/configurations/state/known_users.txt"
CURRENT_USERS="chloe jon mark hacker"
NEW_USERS=()

# Ensure state file exists
mkdir -p "$(dirname "$STATE_FILE")"
touch "$STATE_FILE"

# Check for new users
for user in $CURRENT_USERS; do
  if ! grep -qx "$user" "$STATE_FILE"; then
    NEW_USERS+=("$user")
    echo "$user" >> "$STATE_FILE"
  fi
done

# Send Discord alert if there are new users
if [ ${#NEW_USERS[@]} -gt 0 ]; then
  TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
  MESSAGE="🚨 **New User Login Detected** — *$TIMESTAMP*\n"
  for user in "${NEW_USERS[@]}"; do
    MESSAGE+="🔐 \`$user\`\n"
  done

  # Truncate if needed
  MAX_LEN=1900
  if [[ ${#MESSAGE} -gt $MAX_LEN ]]; then
    MESSAGE="🚨 **New User Login Detected** — *$TIMESTAMP*\nToo many new users. See logs/known_users.txt"
  fi

  # Send to Discord
  curl -s -X POST -H "Content-Type: application/json" \
    -d "{\"content\": \"$MESSAGE\"}" \
    "$DISCORD_WEBHOOK_URL"

  echo "[✅ Sent new user alert to Discord] $TIMESTAMP"
else
  echo "[No new users detected] $(date)"
fi

