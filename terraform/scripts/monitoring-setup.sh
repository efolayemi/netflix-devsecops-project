#!/bin/bash
# monitoring-setup.sh

exec > >(tee /var/log/user-data.log) 2>&1
echo "Starting monitoring setup at $(date)"
echo "Region: ${region}"

# Update system
yum update -y

# Install Docker
yum install -y docker
systemctl start docker
systemctl enable docker
usermod -a -G docker ec2-user

# Create directories
mkdir -p /opt/prometheus
mkdir -p /opt/grafana

# Create Prometheus configuration
cat > /opt/prometheus/prometheus.yml <<EOL
global:
  scrape_interval: 15s
  evaluation_interval: 15s
  external_labels:
    region: '${region}'

rule_files:
  # - "first_rules.yml"

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'jenkins'
    static_configs:
      - targets: ['jenkins:8080']
    metrics_path: '/prometheus'

  - job_name: 'sonarqube'
    static_configs:
      - targets: ['sonarqube:9000']
EOL

# Start Prometheus
echo "Starting Prometheus container..."
docker run -d \
    --name prometheus \
    --restart unless-stopped \
    -p 9090:9090 \
    -v /opt/prometheus:/etc/prometheus \
    prom/prometheus:latest \
    --config.file=/etc/prometheus/prometheus.yml \
    --storage.tsdb.path=/prometheus \
    --web.console.libraries=/etc/prometheus/console_libraries \
    --web.console.templates=/etc/prometheus/consoles \
    --storage.tsdb.retention.time=200h \
    --web.enable-lifecycle

# Start Grafana
echo "Starting Grafana container..."
docker run -d \
    --name grafana \
    --restart unless-stopped \
    -p 3000:3000 \
    -e "GF_SECURITY_ADMIN_PASSWORD=admin" \
    -v /opt/grafana:/var/lib/grafana \
    grafana/grafana:latest

echo "Monitoring setup completed at $(date)"
echo "Region: ${region}"
echo "Prometheus available at port 9090"
echo "Grafana available at port 3000 (admin/admin)"