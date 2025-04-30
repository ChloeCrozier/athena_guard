#!/bin/bash

# Load environment variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../.env"

echo "🚀 Starting AthenaGuard monitoring services..."

# Stop services first
$ATHENAGUARD_PATH/scripts/run_scripts/stop_athena_guard.sh
echo ""

# Start Node Exporter
echo "🟢 Starting Node Exporter..."
cd "$ATHENAGUARD_PATH/$NODE_EXPORTER_FOLDER"
nohup ./node_exporter --collector.textfile.directory=/var/lib/node_exporter/textfile_collector/ \
  > "$ATHENAGUARD_PATH/logs/node_exporter.log" 2>&1 &
cd - > /dev/null

# Start Alertmanager
# ✅ Generate Alertmanager config from template
echo "⚙️  Generating Alertmanager config from template..."
set -a
source "$ATHENAGUARD_PATH/.env"
set +a
envsubst < "$ATHENAGUARD_PATH/configurations/alertmanager.template.yml" > "$ATHENAGUARD_PATH/configurations/alertmanager.yml"

# Start Alertmanager
echo "🟠 Starting Alertmanager..."
cd "$ATHENAGUARD_PATH/$ALERTMANAGER_FOLDER"
nohup ./alertmanager --config.file="$ATHENAGUARD_PATH/configurations/alertmanager.yml" \
  > "$ATHENAGUARD_PATH/logs/alertmanager.log" 2>&1 &
cd - > /dev/null

# ✅ Generate Prometheus config
echo "⚙️  Generating Prometheus config from template..."
set -a
source "$ATHENAGUARD_PATH/.env"
set +a
envsubst < "$ATHENAGUARD_PATH/configurations/prometheus.template.yml" > "$ATHENAGUARD_PATH/configurations/prometheus.yml"

# Start Prometheus
echo "🔵 Starting Prometheus..."
cd "$ATHENAGUARD_PATH/$PROMETHEUS_FOLDER"
nohup ./prometheus --config.file="$ATHENAGUARD_PATH/configurations/prometheus.yml" \
  > "$ATHENAGUARD_PATH/logs/prometheus.log" 2>&1 &
cd - > /dev/null

# Start Grafana
echo "🟣 Starting Grafana Server..."
cd "$ATHENAGUARD_PATH/$GRAFANA_FOLDER/bin"
nohup ./grafana-server web > "$ATHENAGUARD_PATH/logs/grafana.log" 2>&1 &
cd - > /dev/null

echo "✅ All AthenaGuard services started! Logs are in $ATHENAGUARD_PATH/logs"
echo ""
echo "🔗 Service Status:"
echo "- Prometheus    : http://$ATHENAGUARD_IP:$PROMETHEUS_PORT"
echo "- Node Exporter : http://$ATHENAGUARD_IP:$NODE_EXPORTER_PORT"
echo "- Alertmanager  : http://$ATHENAGUARD_IP:$ALERTMANAGER_PORT"
echo "- Grafana       : http://$ATHENAGUARD_IP:$GRAFANA_PORT"
echo ""

