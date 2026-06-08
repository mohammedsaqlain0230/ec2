#!/bin/bash
set -e

echo "Starting Datadog installation..."

# Datadog Configuration
export DD_API_KEY="4a2205982a6e230b275c98b7a5892531"
export DD_SITE="datadoghq.com"

# Install Datadog Agent
bash -c "$(curl -L https://install.datadoghq.com/scripts/install_script_agent7.sh)"

sleep 10

# Enable Linux Auditd
apt-get update
apt-get install -y auditd audispd-plugins

systemctl enable auditd
systemctl start auditd

# Docker Integration
mkdir -p /etc/datadog-agent/conf.d/docker.d

cat > /etc/datadog-agent/conf.d/docker.d/conf.yaml <<EOF
init_config:

instances:
  - url: "unix:///var/run/docker.sock"

logs:
  - type: docker
    container_collect_all: true
EOF

# Auditd Integration
mkdir -p /etc/datadog-agent/conf.d/auditd.d

cat > /etc/datadog-agent/conf.d/auditd.d/conf.yaml <<EOF
logs:
  - type: file
    path: /var/log/audit/audit.log
    service: linux-audit
    source: auditd
EOF

# Syslog Collection
mkdir -p /etc/datadog-agent/conf.d/system_logs.d

cat > /etc/datadog-agent/conf.d/system_logs.d/conf.yaml <<EOF
logs:
  - type: file
    path: /var/log/syslog
    service: ubuntu
    source: syslog
EOF

# Main Datadog Configuration
cat >> /etc/datadog-agent/datadog.yaml <<EOF

logs_enabled: true

listeners:
  - name: docker

config_providers:
  - name: docker
    polling: true

logs_config:
  container_collect_all: true

process_config:
  process_collection:
    enabled: true

tags:
  - env:poc
  - project:datadog
  - team:devops
EOF

# Network Monitoring + Runtime Security
cat > /etc/datadog-agent/system-probe.yaml <<EOF
system_probe_config:
  enabled: true

network_config:
  enabled: true

runtime_security_config:
  enabled: true
EOF

# Allow Datadog Agent to access Docker
usermod -aG docker dd-agent || true

# System Probe Capabilities
setcap cap_sys_admin,cap_net_admin,cap_net_raw+ep \
/opt/datadog-agent/embedded/bin/system-probe || true

# Common Audit Rules
auditctl -w /etc/passwd -p wa -k identity || true
auditctl -w /etc/shadow -p wa -k identity || true
auditctl -w /etc/sudoers -p wa -k privilege || true

# Restart Services
systemctl daemon-reload

systemctl enable datadog-agent
systemctl restart datadog-agent

# Process Agent
if systemctl list-unit-files | grep -q datadog-agent-process; then
    systemctl enable datadog-agent-process
    systemctl restart datadog-agent-process
fi

# System Probe
if systemctl list-unit-files | grep -q datadog-agent-sysprobe; then
    systemctl enable datadog-agent-sysprobe
    systemctl restart datadog-agent-sysprobe
fi

# Security Agent
if systemctl list-unit-files | grep -q datadog-agent-security; then
    systemctl enable datadog-agent-security
    systemctl restart datadog-agent-security
fi

echo "Datadog installation completed successfully"
