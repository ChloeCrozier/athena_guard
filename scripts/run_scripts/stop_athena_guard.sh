#!/bin/bash

# Load environment variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../.env"

echo "🛑 Stopping AthenaGuard services..."

# Stop Prometheus
PROMETHEUS_PID=$(pgrep -f "prometheus.*--config.file")
if [ -n "$PROMETHEUS_PID" ]; then
  echo "🔵 Stopping Prometheus (PID: $PROMETHEUS_PID)"
  kill "$PROMETHEUS_PID"
else
  echo "🔵 Prometheus not running."
fi

PROM_PORT_PID=$(lsof -ti:$PROMETHEUS_PORT)
if [ -n "$PROM_PORT_PID" ]; then
  echo "🔵 Killing process on Prometheus port $PROMETHEUS_PORT (PID: $PROM_PORT_PID)"
  kill -9 "$PROM_PORT_PID"
fi

# Stop Node Exporter
NODE_EXPORTER_PID=$(pgrep -f "node_exporter.*textfile_collector")
if [ -n "$NODE_EXPORTER_PID" ]; then
  echo "🟢 Stopping Node Exporter (PID: $NODE_EXPORTER_PID)"
  kill "$NODE_EXPORTER_PID"
else
  echo "🟢 Node Exporter not running."
fi

NODE_PORT_PID=$(lsof -ti:$NODE_EXPORTER_PORT)
if [ -n "$NODE_PORT_PID" ]; then
  echo "🟢 Killing process on Node Exporter port $NODE_EXPORTER_PORT (PID: $NODE_PORT_PID)"
  kill -9 "$NODE_PORT_PID"
fi

# Stop Alertmanager
ALERTMANAGER_PID=$(pgrep -f "alertmanager.*--config.file")
if [ -n "$ALERTMANAGER_PID" ]; then
  echo "🟠 Stopping Alertmanager (PID: $ALERTMANAGER_PID)"
  kill "$ALERTMANAGER_PID"
else
  echo "🟠 Alertmanager not running."
fi

ALERT_PORT_PID=$(lsof -ti:$ALERTMANAGER_PORT)
if [ -n "$ALERT_PORT_PID" ]; then
  echo "🟠 Killing process on Alertmanager port $ALERTMANAGER_PORT (PID: $ALERT_PORT_PID)"
  kill -9 "$ALERT_PORT_PID"
fi

# Stop Grafana
GRAFANA_PID=$(pgrep -f "grafana")
if [ -n "$GRAFANA_PID" ]; then
  echo "🟣 Stopping Grafana (PID: $GRAFANA_PID)"
  kill "$GRAFANA_PID"
else
  echo "🟣 Grafana not running."
fi

GRAFANA_PORT_PID=$(lsof -ti:$GRAFANA_PORT)
if [ -n "$GRAFANA_PORT_PID" ]; then
  echo "🟣 Killing process on Grafana port $GRAFANA_PORT (PID: $GRAFANA_PORT_PID)"
  kill -9 "$GRAFANA_PORT_PID"
fi

echo "✅ AthenaGuard services fully stopped."

