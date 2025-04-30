#!/bin/bash

# Load environment variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../.env"

echo "♻️  Regenerating AthenaGuard configs from templates..."

# Export variables so envsubst can use them
set -a
source "$ATHENAGUARD_PATH/.env"
set +a

# Rebuild prometheus.yml
envsubst < "$ATHENAGUARD_PATH/configurations/prometheus.template.yml" > "$ATHENAGUARD_PATH/configurations/prometheus.yml"
echo "✅ prometheus.yml regenerated."

# Rebuild alertmanager.yml
envsubst < "$ATHENAGUARD_PATH/configurations/alertmanager.template.yml" > "$ATHENAGUARD_PATH/configurations/alertmanager.yml"
echo "✅ alertmanager.yml regenerated."

echo "✅ All configs updated."
