#!/bin/bash
source "$(dirname "$0")/../../../.env"

POWER_LOG="$ATHENAGUARD_PATH/configurations/state/power_usage_log.txt"
JOB_FILE="$ATHENAGUARD_PATH/configurations/state/job_times.txt"
DISCORD_WEBHOOK="$DISCORD_WEBHOOK_URL"
POWER_CAP=500

# Check most recent entry
LAST_ENTRY=$(tail -n 1 "$POWER_LOG")
TIMESTAMP=$(echo "$LAST_ENTRY" | awk '{print $1}')
POWER_READING=$(echo "$LAST_ENTRY" | awk '{print $2}')

if (( POWER_READING > POWER_CAP )); then
    # Find overlapping jobs
    OVERLAPPING=$(awk -v ts="$TIMESTAMP" '
      {
        if ($3 <= ts && $4 >= ts) {
          print "⚡ Job: "$1", User: "$2", Time: "strftime("%Y-%m-%d %H:%M:%S", $3)" → "strftime("%Y-%m-%d %H:%M:%S", $4)
        }
      }
    ' "$JOB_FILE")

    MESSAGE="🔋 **Power Cap Violation Alert** — $(date +"%F %T")
Current Power: ${POWER_READING}W (Cap: ${POWER_CAP}W)
Affected Jobs:
$OVERLAPPING"

    JSON=$(jq -n --arg content "$MESSAGE" '{content: $content}')
    curl -H "Content-Type: application/json" -X POST -d "$JSON" "$DISCORD_WEBHOOK"
fi

