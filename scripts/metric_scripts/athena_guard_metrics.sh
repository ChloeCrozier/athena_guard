#!/bin/bash

METRICS_FILE="/var/lib/node_exporter/textfile_collector/athenaguard.prom"

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
  FAILS=$($GREP "Failed password" $LOG | $WC -l)
  echo "login_failure_total $FAILS"

  SUCCESSES=$($GREP "Accepted" $LOG | $GREP -E "password|publickey" | $WC -l)
  echo "login_success_total $SUCCESSES"

  ACTIVE_USERS=$($WHO | $WC -l)
  echo "logged_in_users $ACTIVE_USERS"

  SUDO_COUNT=$($GREP "COMMAND=" $LOG | $WC -l)
  echo "sudo_command_total $SUDO_COUNT"

  OPEN_PORTS=$($SS -tuln | $GREP -c LISTEN)
  echo "open_ports_total $OPEN_PORTS"

  EXTERNAL_CONNS=$($SS -nt | $GREP -v "127.0.0.1" | $GREP -v "::1" | $GREP ESTAB | $WC -l)
  echo "connections_external $EXTERNAL_CONNS"

  REPEATED_FAILS=$($GREP "Failed password" $LOG | $AWK '{print $(NF-3)}' | $SORT | $UNIQ -c | $AWK '$1 > 3' | $WC -l)
  echo "repeat_failed_login_sources $REPEATED_FAILS"

  INVALID_USERS=$($GREP "Invalid user" $LOG | $WC -l)
  echo "invalid_user_login_attempts $INVALID_USERS"

  ZOMBIES=$($PS aux | $AWK '$8 == "Z"' | $WC -l)
  echo "zombie_processes_total $ZOMBIES"

  HOME_USAGE=$($DU -s /home/* 2>/dev/null | $AWK '{sum+=$1} END {print sum}')
  echo "home_dir_size_kb $HOME_USAGE"

  echo "athenaguard_last_update $($DATE +%s)"
  echo "# $($DATE '+%Y-%m-%d %H:%M:%S')"
  echo "athenaguard_last_update_human 1"

  $WHO | $AWK '{print $1}' | $SORT | $UNIQ | while read user; do
    echo "logged_in_user_list{user=\"$user\"} 1"
  done

  $GREP "COMMAND=" $LOG | $AWK '{print $1, $2, $3, $6}' | $AWK '{print $4}' | $SORT | $UNIQ -c | while read count user; do
    echo "sudo_command_user_total{user=\"$user\"} $count"
  done

  $GREP "Failed password" $LOG | $AWK '{print $(NF-5)}' | $SORT | $UNIQ -c | while read count user; do
    echo "login_failure_user_total{user=\"$user\"} $count"
  done

} > $METRICS_FILE
