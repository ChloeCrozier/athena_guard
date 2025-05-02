#!/bin/bash
source "$(dirname "$0")/../../../.env"

CURRENT_FILE="$ATHENAGUARD_PATH/configurations/state/current_job_status.txt"
LAST_FILE="$ATHENAGUARD_PATH/configurations/state/last_job_status.txt"
DISCORD_WEBHOOK="$DISCORD_WEBHOOK_URL"

touch "$LAST_FILE"

STALLED_JOBS=$(awk '
  BEGIN {
    while ((getline < "'"$LAST_FILE"'") > 0) {
      split($0, a, " ")
      last[a[1]] = a[4]
    }
  }
  {
    split($0, a, " ")
    job_id = a[1]
    user = a[2]
    state = a[3]
    ts = a[4]
    if (last[job_id] == ts && state ~ /RUNNING/) {
      print job_id, user, state
    }
  }
' "$CURRENT_FILE")

if [[ -n "$STALLED_JOBS" ]]; then
    TIMESTAMP=$(date +"%F %T")
    LIST=$(echo "$STALLED_JOBS" | sed 's/^/⏸️ /')

    MESSAGE="🚧 **Stalled SLURM Job Alert** — $TIMESTAMP
The following jobs have been running without updates:
$LIST"

    JSON=$(jq -n --arg content "$MESSAGE" '{content: $content}')
    curl -H "Content-Type: application/json" -X POST -d "$JSON" "$DISCORD_WEBHOOK"
fi

cp "$CURRENT_FILE" "$LAST_FILE"

