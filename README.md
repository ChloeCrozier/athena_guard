# Athena Guard Documentation

## Getting Started

### Clone the Repository
```bash
git clone https://github.com/ChloeCrozier/athena_guard.git
```

### Download and Set Up Prometheus
```bash
curl -LO https://github.com/prometheus/prometheus/releases/download/v2.51.2/prometheus-2.51.2.linux-amd64.tar.gz
tar xvf prometheus-2.51.2.linux-amd64.tar.gz
mv prometheus-2.51.2.linux-amd64 prometheus
```

### Download and Set Up Node Exporter
```bash
curl -LO https://github.com/prometheus/node_exporter/releases/download/v1.8.1/node_exporter-1.8.1.linux-amd64.tar.gz
tar xvf node_exporter-1.8.1.linux-amd64.tar.gz
mv node_exporter-1.8.1.linux-amd64 node_exporter
```

### Download and Set Up Grafana
```bash
curl -LO https://dl.grafana.com/oss/release/grafana-10.2.3.linux-amd64.tar.gz
tar -zxvf grafana-10.2.3.linux-amd64.tar.gz
mv grafana-10.2.3 grafana
```

## Running the Services

Run the following commands in separate terminals (or use tools like `tmux` or `screen`):

1. **Node Exporter**
    ```bash
    cd node_exporter
    ./node_exporter
    ```

2. **Prometheus**
    ```bash
    cd prometheus
    ./prometheus --config.file=prometheus.yml
    ```

3. **Grafana**
    ```bash
    cd grafana/bin
    ./grafana-server web
    ```
    **Note:** The default password is `MunitionsAreUsed13!`.

## Customizations

1. Create the directory for custom metrics:
    ```bash
    mkdir -p /var/lib/node_exporter/textfile_collector/
    ```

2. Define the path for the metrics file:
    ```bash
    METRICS_FILE="/var/lib/node_exporter/textfile_collector/athenaguard.prom"
    ```

3. Output path for custom metrics:
    ```
    /var/lib/node_exporter/textfile_collector/athenaguard.prom
    ```

## Notes
- Ensure all services are running properly before proceeding with customizations.
- Use the provided paths and commands to set up and run Athena Guard effectively.
- For further assistance, refer to the official documentation or contact the repository maintainer.

## Accessing the Services

- **Grafana**: [http://130.127.89.162:3000/](http://130.127.89.162:3000/)
- **Prometheus**: [http://130.127.89.162:9090/](http://130.127.89.162:9090/)
- **Alertmanager**: [http://130.127.89.162:9093/](http://130.127.89.162:9093/)
- **Node Exporter**: [http://130.127.89.162:9100/](http://130.127.89.162:9100/)
