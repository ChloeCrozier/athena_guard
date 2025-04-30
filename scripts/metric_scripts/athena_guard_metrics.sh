#!/bin/bash

# Set up paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../.env"

METRICS_FILE="/var/lib/node_exporter/textfile_collector/athenaguard.prom"
BACKUP_METRICS="$ATHENAGUARD_PATH/logs/athenaguard_latest_metrics.prom"
SECURE_LOG="/var/log/secure"

# Commands
SS="/usr/sbin/ss"
WHO="/usr/bin/who"
WC="/usr/bin/wc"
GREP="/usr/bin/grep"
AWK="/usr/bin/awk"
DATE="/usr/bin/date"
PS="/usr/bin/ps"
DU="/usr/bin/du"
SORT="/usr/bin/sort"
UNIQ="/usr/bin/uniq"

{
  echo "# AthenaGuard Metrics — $(date '+%Y-%m-%d %H:%M:%S')"
  echo

  ### 1. Authentication Metrics
  echo "# Authentication"
  echo "login_failure_total $($GREP 'Failed password' $SECURE_LOG | $WC -l)"
  echo "login_success_total $($GREP 'Accepted' $SECURE_LOG | $GREP -E 'password|publickey' | $WC -l)"
  echo "invalid_user_login_attempts $($GREP 'Invalid user' $SECURE_LOG | $WC -l)"
  REPEATED_FAILS=$($GREP 'Failed password' $SECURE_LOG | $AWK '{print $(NF-3)}' | $SORT | $UNIQ -c | $AWK '$1 > 3' | $WC -l)
  echo "repeat_failed_login_sources $REPEATED_FAILS"
  echo

  ### 2. User Activity Metrics
  echo "# User Sessions"
  ACTIVE_USERS=$($WHO | $WC -l)
  echo "logged_in_users $ACTIVE_USERS"

  $WHO | $AWK '{print $1}' | $SORT | $UNIQ | while read user; do
    echo "logged_in_user_list{user=\"$user\"} 1"
  done
  echo

  ### 3. Sudo Command Metrics
  echo "# Sudo Activity"
  SUDO_TOTAL=$($GREP 'COMMAND=' $SECURE_LOG | $WC -l)
  echo "sudo_command_total $SUDO_TOTAL"

  $GREP 'COMMAND=' $SECURE_LOG | $AWK '{print $(NF)}' | $SORT | $UNIQ -c | while read count cmd; do
    echo "sudo_command_user_total{command=\"$cmd\"} $count"
  done
  echo

  ### 4. Network Metrics
  echo "# Network"
  echo "open_ports_total $($SS -tuln | $GREP -c LISTEN)"
  echo "connections_external $($SS -nt | $GREP ESTAB | $GREP -v '127.0.0.1' | $GREP -v '::1' | $WC -l)"
  echo

  ### 5. System Health
  echo "# System"
  echo "zombie_processes_total $($PS aux | $AWK '$8 == "Z"' | $WC -l)"
  echo "home_dir_size_kb $($DU -s /home/* 2>/dev/null | $AWK '{sum+=$1} END {print sum}')"
  echo

  ### 6. Metadata
  echo "# Meta"
  echo "athenaguard_last_update $(date +%s)"
  echo "# End"
} > "$METRICS_FILE"

# Save backup
cp "$METRICS_FILE" "$BACKUP_METRICS"

