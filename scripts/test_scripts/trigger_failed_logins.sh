#!/bin/bash
METRICS_FILE="/var/lib/node_exporter/textfile_collector/athenaguard.prom"

cat <<EOF > $METRICS_FILE
# HELP login_failure_total Metric read from athenaguard
# TYPE login_failure_total untyped
login_failure_total 50
login_success_total 2
sudo_command_total 1
athenaguard_last_update $(date +%s)
EOF

echo "Triggered login_failure_total spike."

