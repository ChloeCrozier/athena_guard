#!/bin/bash

#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Metrics output file
METRICS_FILE="/var/lib/node_exporter/textfile_collector/athenaguard.prom"

# System commands
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
LOG="/var/log/secure"

{
  #### 1. Authentication Metrics
  FAILS=$($GREP "Failed password" $LOG | $WC -l)
  echo "login_failure_total $FAILS"

  SUCCESSES=$($GREP "Accepted" $LOG | $GREP -E "password|publickey" | $WC -l)
  echo "login_success_total $SUCCESSES"

  INVALID_USERS=$($GREP "Invalid user" $LOG | $WC -l)
  echo "invalid_user_login_attempts $INVALID_USERS"

  REPEATED_FAILS=$($GREP "Failed password" $LOG | $AWK '{print $(NF-3)}' | $SORT | $UNIQ -c | $AWK '$1 > 3' | $WC -l)
  echo "repeat_failed_login_sources $REPEATED_FAILS"

  echo ""

  #### 2. User Activity Metrics
  ACTIVE_USERS=$($WHO | $WC -l)
  echo "logged_in_users $ACTIVE_USERS"

  $WHO | $AWK '{print $1}' | $SORT | $UNIQ | while read user; do
    echo "logged_in_user_list{user=\"$user\"} 1"
  done

  echo ""

  #### 3. Sudo Command Metrics
  SUDO_COUNT=$($GREP "COMMAND=" $LOG | $WC -l)
  echo "sudo_command_total $SUDO_COUNT"

  $GREP "COMMAND=" $LOG | $AWK '{print $1, $2, $3, $6}' | $AWK '{print $4}' | $SORT | $UNIQ -c | while read count user; do
    echo "sudo_command_user_total{user=\"$user\"} $count"
  done

  echo ""

  #### 4. Network Metrics
  OPEN_PORTS=$($SS -tuln | $GREP -c LISTEN)
  echo "open_ports_total $OPEN_PORTS"

  EXTERNAL_CONNS=$($SS -nt | $GREP -v "127.0.0.1" | $GREP -v "::1" | $GREP ESTAB | $WC -l)
  echo "connections_external $EXTERNAL_CONNS"

  echo ""

  #### 5. System Health Metrics
  ZOMBIES=$($PS aux | $AWK '$8 == "Z"' | $WC -l)
  echo "zombie_processes_total $ZOMBIES"

  HOME_USAGE=$($DU -s /home/* 2>/dev/null | $AWK '{sum+=$1} END {print sum}')
  echo "home_dir_size_kb $HOME_USAGE"

  echo ""

  #### 6. Metadata / Timestamps
  echo "athenaguard_last_update $($DATE '+%Y-%m-%d %H:%M:%S')"

} > $METRICS_FILE

cp "$METRICS_FILE" "$SCRIPT_DIR/../../logs/athenaguard_latest_metrics.prom"
