# AthenaGuard

![AthenaGuard Logo](https://github.com/ChloeCrozier/athena_guard/blob/main/documentation/athena_guard_icon.png)

AthenaGuard is an open-source, modular security and system monitoring framework for Linux-based HPC and SLURM clusters. It integrates Prometheus, Grafana, and custom monitoring scripts to deliver real-time alerting, visual dashboards, and actionable insights. Built for academic and research environments, AthenaGuard supports edge systems, containerized deployments, and distributed clusters.

---

## Features

- **Real-time Monitoring**: Prometheus & Grafana integration.
- **Security Event Detection**: Logins, sudo usage, zombie processes.
- **SLURM-Aware Metrics**: Idle GPUs, stalled jobs, job tracking.
- **Power & Network Monitoring**: Cap violations, port spikes, interface changes.
- **Dynamic Dashboards**: Auto-updating Grafana panels.
- **Discord Alerting**: Integration via webhook.
- **Modular Alert Rules**: Drop `.yml` files in `/alert_rules/`.
- **Easy Testing**: Sample scripts for quick validation.

---

## How to Start and Stop AthenaGuard

Navigate to the `scripts/` directory and use the helper scripts to manage AthenaGuard’s core services.

### Start

```bash
cd scripts/run_scripts
./start_all.sh
```

This starts:

- Node Exporter on port `9100`
- Prometheus on port `9090`
- Grafana on port `3000`
- Alertmanager on port `9093` (if configured)

> **Note**: Ensure correct paths and environment variables are set in `.env`.

### Stop

```bash
./stop_all.sh
```

This cleanly stops all services started by `start_all.sh`.

### Check Status

```bash
./status.sh
```

---

## Access the Interfaces

- **Grafana**: [http://130.127.89.162:3000](http://130.127.89.162:3000)
- **Prometheus**: [http://130.127.89.162:9090](http://130.127.89.162:9090)
- **Alertmanager**: [http://130.127.89.162:9093](http://130.127.89.162:9093)
- **Node Exporter**: [http://130.127.89.162:9100](http://130.127.89.162:9100)

---

## Using Crontab for Automation

AthenaGuard supports automation through `crontab` for periodic execution of monitoring scripts and alerts.

1. Open the crontab editor:
    ```bash
    crontab -e
    ```

2. Add entries to schedule scripts. For example, to run `detect_new_users.sh` every hour:
    ```bash
    0 * * * * /path/to/athena_guard/scripts/alert_scripts/detect_new_users.sh
    ```

3. Ensure the `.env` file is sourced in your scripts:
    ```bash
    source /path/to/athena_guard/configurations/.env
    ```

For more examples, see `documentation/sample_crontab_entries.md`.

---

## Trigger Sample Alerts

Use the sample scripts in `scripts/alert_scripts/sample_alerts/` to test Discord alerting or Prometheus triggers.

---

## Discord Integration

Define your webhook in `.env`:

```bash
DISCORD_WEBHOOK_URL=https://discord.com/api/webhooks/.../...
```

---

## Directory Overview

```
athena_guard/
├── alert_rules/              # YAML rule definitions for Prometheus
├── configurations/           # State files, IPs, summaries, and .env
├── scripts/
│   ├── alert_scripts/        # Rule + summary alerting logic
│   ├── run_scripts/          # Start/stop/status helpers
│   └── test_scripts/         # Scripts for testing and validation
├── node_exporter/            # Node Exporter + athenaguard.prom
├── prometheus/               # Prometheus binary and config
├── grafana/                  # Grafana frontend
├── dashboards/               # JSON dashboards for Grafana
└── README.md
```

---

## Alerts You Can Trigger

- **New User Logins**: `detect_new_users.sh`
- **Sudo Command Alerts**: `sudo_usage_alert.sh`
- **Zombie Process Detection**: `zombie_process_alert.sh`
- **Blacklisted IP Detection**: `failed_login_blacklist_alert.sh`
- **Filesystem Usage Warnings**: `filesystem_usage_alert.sh`
- **Open Port Spikes**: `open_port_spike_alert.sh`
- **Network Interface Changes**: `network_change_alert.sh`
- **Login Failure Spike**: `login_failure_spike_alert.sh`
- **Stalled SLURM Jobs**: `stalled_job_alert.sh`
- **GPU Idle Detection**: `gpu_idle_alert.sh`
- **Power Cap Violations**: `power_cap_violation_alert.sh`

Sample triggers are available in `scripts/alert_scripts/sample_alerts/`.

---

## Simulated Data Support

Simulate `.prom` metric values using scripts like `trigger_sudo_spike.sh` to test dashboards and Discord alerts without real data.

---

## Requirements

- Prometheus >= 2.50
- Node Exporter >= 1.8
- Grafana >= 10
- `jq`, `curl`, `bash`, `cron`

Installations are automated through the steps in `README-installation.md`.

---

## Contributions

Pull requests are welcome! Use GitHub Issues to report bugs or request features. AthenaGuard is open to collaboration for HPC education, research, and competitions.

---

## Maintainer

**Chloe Crozier** — [@ChloeCrozier](https://github.com/ChloeCrozier)