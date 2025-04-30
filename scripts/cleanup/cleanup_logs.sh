#!/bin/bash

# Navigate relative to script location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../.env"

LOG_DIR="$ATHENAGUARD_PATH/logs"

echo "🧹 Deleting all files in $LOG_DIR..."
rm -f "$LOG_DIR"/*
echo "✅ Log directory cleaned: $(date)"

