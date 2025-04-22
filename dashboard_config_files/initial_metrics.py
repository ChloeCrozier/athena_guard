import json

# Define a basic Grafana dashboard template with panels for AthenaGuard metrics
dashboard = {
    "id": None,
    "uid": None,
    "title": "AthenaGuard Cluster Security Dashboard",
    "timezone": "browser",
    "schemaVersion": 38,
    "version": 1,
    "refresh": "30s",
    "panels": [
        {
            "type": "stat",
            "title": "Failed SSH Logins",
            "gridPos": {"x": 0, "y": 0, "w": 6, "h": 3},
            "targets": [{"expr": "login_failure_total", "refId": "A"}],
        },
        {
            "type": "stat",
            "title": "Successful SSH Logins",
            "gridPos": {"x": 6, "y": 0, "w": 6, "h": 3},
            "targets": [{"expr": "login_success_total", "refId": "A"}],
        },
        {
            "type": "stat",
            "title": "Logged-In Users",
            "gridPos": {"x": 0, "y": 3, "w": 6, "h": 3},
            "targets": [{"expr": "logged_in_users", "refId": "A"}],
        },
        {
            "type": "stat",
            "title": "Sudo Commands",
            "gridPos": {"x": 6, "y": 3, "w": 6, "h": 3},
            "targets": [{"expr": "sudo_command_total", "refId": "A"}],
        },
        {
            "type": "stat",
            "title": "External Connections",
            "gridPos": {"x": 0, "y": 6, "w": 6, "h": 3},
            "targets": [{"expr": "connections_external", "refId": "A"}],
        },
        {
            "type": "stat",
            "title": "Open Ports",
            "gridPos": {"x": 6, "y": 6, "w": 6, "h": 3},
            "targets": [{"expr": "open_ports_total", "refId": "A"}],
        },
        {
            "type": "bargauge",
            "title": "Sudo Commands by User",
            "gridPos": {"x": 0, "y": 9, "w": 12, "h": 5},
            "targets": [{"expr": "sudo_command_user_total", "refId": "A"}],
        },
        {
            "type": "bargauge",
            "title": "Login Failures by User",
            "gridPos": {"x": 0, "y": 14, "w": 12, "h": 5},
            "targets": [{"expr": "login_failure_user_total", "refId": "A"}],
        },
        {
            "type": "stat",
            "title": "Zombie Processes",
            "gridPos": {"x": 0, "y": 19, "w": 6, "h": 3},
            "targets": [{"expr": "zombie_processes_total", "refId": "A"}],
        },
        {
            "type": "stat",
            "title": "Home Dir Usage (KB)",
            "gridPos": {"x": 6, "y": 19, "w": 6, "h": 3},
            "targets": [{"expr": "home_dir_size_kb", "refId": "A"}],
        },
    ],
}

# Save as JSON file
dashboard_json = json.dumps({"dashboard": dashboard, "overwrite": True}, indent=2)
with open("/mnt/data/athenaguard_grafana_dashboard.json", "w") as f:
    f.write(dashboard_json)

"/mnt/data/athenaguard_grafana_dashboard.json"

