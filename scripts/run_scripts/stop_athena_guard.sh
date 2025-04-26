#!/bin/bash

# Load environment variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load environment variables relative to the script's directory
source "$SCRIPT_DIR/../../.env"

echo "🛑 Stopping AthenaGuard services..."

# Stop Prometheus
PROMETHEUS_PID=$(pgrep -f "prometheus.*--config.file")
if [ -n "$PROMETHEUS_PID" ]; then
  echo "🔵 Stopping Prometheus (PID: $PROMETHEUS_PID)..."
  kill "$PROMETHEUS_PID"
else
  echo "🔵 Prometheus not running."
fi

# Stop Node Exporter
NODE_EXPORTER_PID=$(pgrep -f "node_exporter.*textfile_collector")
if [ -n "$NODE_EXPORTER_PID" ]; then
  echo "🟢 Stopping Node Exporter (PID: $NODE_EXPORTER_PID)..."
  kill "$NODE_EXPORTER_PID"
else
  echo "🟢 Node Exporter not running."
fi

# Stop Alertmanager
ALERTMANAGER_PID=$(pgrep -f "alertmanager.*--config.file")
if [ -n "$ALERTMANAGER_PID" ]; then
  echo "🟠 Stopping Alertmanager (PID: $ALERTMANAGER_PID)..."
  kill "$ALERTMANAGER_PID"
else
  echo "🟠 Alertmanager not running."
fi

# Stop Grafana
GRAFANA_PID=$(pgrep -f "grafana-server")
if [ -n "$GRAFANA_PID" ]; then
  echo "🟣 Stopping Grafana Server (PID: $GRAFANA_PID)..."
  kill "$GRAFANA_PID"
else
  echo "🟣 Grafana not running."
fi

echo "✅ AthenaGuard services stopped."
