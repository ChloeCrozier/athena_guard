#!/bin/bash

# Load environment
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../.env"

PROM_FILE="/var/lib/node_exporter/textfile_collector/athenaguard.prom"
NOW=$(date +%s)

echo "✅ Triggering test alerts by writing to $PROM_FILE..."

# Sudo usage spike (triggers sudo_alerts.yml)
echo "sudo_command_total $((RANDOM % 100 + 50))" >> "$PROM_FILE"

# Too many logged-in users (triggers login_alerts.yml)
echo "logged_in_users 15" >> "$PROM_FILE"

# Disk usage high (triggers disk_usage_alerts.yml)
echo "home_dir_size_kb 999999999" >> "$PROM_FILE"

# External connections high (triggers external_connection_alerts.yml)
echo "connections_external 50" >> "$PROM_FILE"

# Many successful logins (triggers login_success_alerts.yml)
echo "login_success_total 200" >> "$PROM_FILE"

# Invalid login attempts (triggers invalid_login_alerts.yml)
echo "invalid_user_login_attempts 7" >> "$PROM_FILE"

# Repeated failed logins (triggers repeat_failed_login_alerts.yml)
echo "repeat_failed_login_sources 3" >> "$PROM_FILE"

# Update timestamps
echo "athenaguard_last_update $NOW" >> "$PROM_FILE"
echo "# $(date '+%Y-%m-%d %H:%M:%S')"
echo "athenaguard_last_update_human 1" >> "$PROM_FILE"

echo "🧪 Test metrics written. Give Prometheus a few seconds to scrape."

