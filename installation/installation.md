# AthenaGuard Installation Guide

This guide walks you through installing and configuring all the required services for AthenaGuard, a real-time security and system monitoring framework for HPC and SLURM clusters.

---

## 1. Clone the Repository

```bash
git clone https://github.com/ChloeCrozier/athena_guard.git
cd athena_guard
```

---

## 2. Install Dependencies

### Prometheus

```bash
curl -LO https://github.com/prometheus/prometheus/releases/download/v2.51.2/prometheus-2.51.2.linux-amd64.tar.gz
tar xvf prometheus-2.51.2.linux-amd64.tar.gz
mv prometheus-2.51.2.linux-amd64 prometheus
```

### Node Exporter

```bash
curl -LO https://github.com/prometheus/node_exporter/releases/download/v1.8.1/node_exporter-1.8.1.linux-amd64.tar.gz
tar xvf node_exporter-1.8.1.linux-amd64.tar.gz
mv node_exporter-1.8.1.linux-amd64 node_exporter
```

### Grafana

```bash
curl -LO https://dl.grafana.com/oss/release/grafana-10.2.3.linux-amd64.tar.gz
tar -zxvf grafana-10.2.3.linux-amd64.tar.gz
mv grafana-10.2.3 grafana
```

---

## 3. Set Up Custom Metrics Directory

```bash
mkdir -p $ATHENAGUARD_PATH/node_exporter
export METRICS_FILE="$ATHENAGUARD_PATH/node_exporter/athenaguard.prom"
```

Ensure Node Exporter runs with:

```bash
./node_exporter --collector.textfile.directory=$ATHENAGUARD_PATH/node_exporter
```

---

## 4. Configure Prometheus

Edit `prometheus/prometheus.yml` and add:

```yaml
- job_name: 'athenaguard-custom'
  static_configs:
    - targets: ['localhost:9100']
```

Make sure the textfile collector is active in Node Exporter.

---

## 5. Add Prometheus Alert Rules

All alert rules are located in `alert_rules/`.
Prometheus automatically loads all `*.yml` files in this directory.

In `prometheus.yml`, add or update:

```yaml
rule_files:
  - ../alert_rules/*.yml
```

Reload Prometheus after making changes:

```bash
curl -X POST http://localhost:9090/-/reload
```

---

## 6. Start Services

In separate terminals or with `tmux`:

**Node Exporter**

```bash
cd node_exporter
./node_exporter --collector.textfile.directory=$ATHENAGUARD_PATH/node_exporter
```

**Prometheus**

```bash
cd prometheus
./prometheus --config.file=prometheus.yml
```

**Grafana**

```bash
cd grafana/bin
./grafana-server web
```

Default Grafana login: `admin / {password}`

---