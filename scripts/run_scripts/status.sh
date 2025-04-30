#!/bin/bash

# Load environment variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../.env"

echo "🔍 Checking AthenaGuard service status..."

# Check Node Exporter
if pgrep -f "node_exporter" > /dev/null; then
  echo "🟢 Node Exporter is running"
else
  echo "🔴 Node Exporter is NOT running"
fi

# Check Alertmanager
if pgrep -f "alertmanager" > /dev/null; then
  echo "🟠 Alertmanager is running"
else
  echo "🔴 Alertmanager is NOT running"
fi

# Check Prometheus
if pgrep -f "prometheus" > /dev/null; then
  echo "🔵 Prometheus is running"
else
  echo "🔴 Prometheus is NOT running"
fi

# Check Grafana
if pgrep -f "grafana" > /dev/null; then
  echo "🟣 Grafana is running"
else
  echo "🔴 Grafana is NOT running"
fi

CRON_STATUS=$(systemctl is-active crond)
if [[ "$CRON_STATUS" == "active" ]]; then
  echo "🕒 Cron (crond) is running"
else
  echo "🔴 Cron (crond) is NOT running"
fi


echo "✅ Status check complete."

