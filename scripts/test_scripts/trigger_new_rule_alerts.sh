#!/bin/bash
source "$(dirname "$0")/../../.env"

PROM_FILE="$ATHENAGUARD_PATH/node_exporter/athenaguard.prom"

cat <<EOF > "$PROM_FILE"
# HELP gpu_utilization GPU utilization percentage
# TYPE gpu_utilization gauge
gpu_utilization 0

# HELP power_usage_watts Current power usage in watts
# TYPE power_usage_watts gauge
power_usage_watts 550

# HELP job_last_updated_seconds Last update time of job (epoch seconds)
# TYPE job_last_updated_seconds gauge
job_last_updated_seconds $(date -d '2 hours ago' +%s)
EOF

echo "[✔] Trigger metrics written to $PROM_FILE"

