#!/bin/bash
METRICS_FILE="/var/lib/node_exporter/textfile_collector/athenaguard.prom"

cat <<EOF > $METRICS_FILE
login_failure_total 3
login_success_total 2
sudo_command_total 30
athenaguard_last_update $(date +%s)
EOF

echo "️ Triggered sudo_command_total spike."

