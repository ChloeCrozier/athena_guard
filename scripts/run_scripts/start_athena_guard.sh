#!/bin/bash

# Load environment variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load environment variables relative to the script's directory
source "$SCRIPT_DIR/../../.env"

# Stop any old services first
echo "Stopping any services that are currently running..."
$ATHENAGUARD_PATH/scripts/run_scripts/stop_athena_guard.sh

echo ""
echo ""
echo "🚀 Starting AthenaGuard monitoring services..."

# Define paths
LOG_DIR="$ATHENAGUARD_PATH/logs"
PROMETHEUS_DIR="$ATHENAGUARD_PATH/prometheus"
NODE_EXPORTER_DIR="$ATHENAGUARD_PATH/node_exporter"
ALERTMANAGER_DIR="$ATHENAGUARD_PATH/alert_manager"
GRAFANA_DIR="$ATHENAGUARD_PATH/grafana/bin"

# Create log directory if it doesn't exist
mkdir -p "$LOG_DIR"

# Start Node Exporter
echo "🟢 Starting Node Exporter..."
cd "$NODE_EXPORTER_DIR"
nohup ./node_exporter --collector.textfile.directory=/var/lib/node_exporter/textfile_collector/ > "$LOG_DIR/node_exporter.log" 2>&1 &

# Start Alertmanager
echo "🟠 Starting Alertmanager..."
cd "$ALERTMANAGER_DIR"
nohup ./alertmanager --config.file="$ATHENAGUARD_PATH/configurations/alertmanager.yml" > "$LOG_DIR/alertmanager.log" 2>&1 &

# Start Prometheus
echo "🔵 Starting Prometheus..."
cd "$PROMETHEUS_DIR"
nohup ./prometheus --config.file="$ATHENAGUARD_PATH/configurations/prometheus.yml" > "$LOG_DIR/prometheus.log" 2>&1 &

# Start Grafana
echo "🟣 Starting Grafana Server..."
cd "$GRAFANA_DIR"
nohup ./grafana-server --homepath "$ATHENAGUARD_PATH/grafana" > "$LOG_DIR/grafana.log" 2>&1 &

echo "✅ All AthenaGuard services started! Logs are in $LOG_DIR"
