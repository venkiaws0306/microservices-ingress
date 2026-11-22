#!/bin/bash
set -euxo pipefail
apt-get update -y
apt-get install -y wget tar adduser libfontconfig1 musl
# Prometheus
useradd --system --no-create-home --shell /usr/sbin/nologin prometheus || true
cd /tmp
wget -q https://github.com/prometheus/prometheus/releases/download/v2.55.1/prometheus-2.55.1.linux-amd64.tar.gz
tar xzf prometheus-2.55.1.linux-amd64.tar.gz
install -m 0755 prometheus-2.55.1.linux-amd64/prometheus /usr/local/bin/prometheus
install -m 0755 prometheus-2.55.1.linux-amd64/promtool /usr/local/bin/promtool
mkdir -p /etc/prometheus /data/prometheus
cp -r prometheus-2.55.1.linux-amd64/consoles prometheus-2.55.1.linux-amd64/console_libraries /etc/prometheus/
cat > /etc/prometheus/prometheus.yml <<'EOF'
global:
  scrape_interval: 15s
scrape_configs:
  - job_name: prometheus
    static_configs:
      - targets: ['localhost:9090']
  - job_name: node_exporter
    static_configs:
      - targets: ['localhost:9100']
EOF
chown -R prometheus:prometheus /etc/prometheus /data/prometheus
cat > /etc/systemd/system/prometheus.service <<'EOF'
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target
[Service]
User=prometheus
Group=prometheus
Type=simple
Restart=on-failure
ExecStart=/usr/local/bin/prometheus --config.file=/etc/prometheus/prometheus.yml --storage.tsdb.path=/data/prometheus --web.console.templates=/etc/prometheus/consoles --web.console.libraries=/etc/prometheus/console_libraries --web.listen-address=0.0.0.0:9090
[Install]
WantedBy=multi-user.target
EOF
# Node Exporter
useradd --system --no-create-home --shell /usr/sbin/nologin node_exporter || true
wget -q https://github.com/prometheus/node_exporter/releases/download/v1.8.2/node_exporter-1.8.2.linux-amd64.tar.gz
tar xzf node_exporter-1.8.2.linux-amd64.tar.gz
install -m 0755 node_exporter-1.8.2.linux-amd64/node_exporter /usr/local/bin/node_exporter
cat > /etc/systemd/system/node_exporter.service <<'EOF'
[Unit]
Description=Prometheus Node Exporter
Wants=network-online.target
After=network-online.target
[Service]
User=node_exporter
Group=node_exporter
Type=simple
Restart=on-failure
ExecStart=/usr/local/bin/node_exporter
[Install]
WantedBy=multi-user.target
EOF
# Grafana official repository
mkdir -p /etc/apt/keyrings
wget -qO- https://apt.grafana.com/gpg.key | gpg --dearmor -o /etc/apt/keyrings/grafana.gpg
chmod 644 /etc/apt/keyrings/grafana.gpg
echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" > /etc/apt/sources.list.d/grafana.list
apt-get update -y
apt-get install -y grafana
systemctl daemon-reload
systemctl enable --now prometheus node_exporter grafana-server
