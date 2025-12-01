# 🚀 Grafana Alloy Agent - Distributed Metrics Collection

[![Grafana Alloy](https://img.shields.io/badge/Grafana_Alloy-1.10.1-F46800?logo=grafana&logoColor=white)](https://grafana.com/docs/alloy/)
[![Docker](https://img.shields.io/badge/Docker-24.x-2496ED?logo=docker&logoColor=white)](https://www.docker.com/)
[![Prometheus](https://img.shields.io/badge/Push_to-Prometheus-E6522C?logo=prometheus&logoColor=white)](https://prometheus.io/)

Grafana Alloy agent for distributed metrics collection across LCX cryptocurrency exchange infrastructure. Pushes metrics to central Prometheus via remote_write API.

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Configuration](#configuration)
- [Deployment](#deployment)
- [Monitoring Targets](#monitoring-targets)
- [Security](#security)
- [Troubleshooting](#troubleshooting)

## 🎯 Overview

This Alloy agent deployment is designed for:

- **Push-Based Metrics**: Collects and pushes metrics to central Prometheus
- **Multi-Service Monitoring**: Accounts, Exchange, Kafka, Wallets services
- **System Metrics**: CPU, memory, disk, network via node_exporter
- **Docker Monitoring**: Container discovery and metrics
- **Log Collection**: Optional Loki integration for log aggregation
- **Auto-Discovery**: Docker container auto-discovery with relabeling

## ✨ Features

### Metrics Collection

- ✅ **Node Exporter**: System-level metrics (CPU, memory, disk, network)
- ✅ **Application Metrics**: Node.js application metrics (custom endpoints)
- ✅ **Docker Containers**: Auto-discovery and container metrics
- ✅ **Kafka JMX**: Kafka broker metrics via JMX exporter
- ✅ **Custom Services**: Regula DocReader, custom endpoints

### Log Collection (Optional)

- ✅ **File Logs**: Application log files with parsing
- ✅ **Docker Logs**: Container log collection
- ✅ **Log Processing**: Level extraction, timestamp parsing
- ✅ **Push to Loki**: Centralized log aggregation

### Security

- 🔒 **Container Hardening**: Dropped capabilities, security options
- 🔒 **Basic Auth**: Authenticated push to Prometheus/Loki
- 🔒 **TLS Support**: HTTPS connections with cert validation
- 🔒 **Network Mode**: Host network for complete system visibility

## 🏛️ Architecture

```
┌──────────────────────────────────────────────────┐
│          Target Server (Your Application)        │
│                                                   │
│  ┌────────────────────────────────────────────┐ │
│  │         Grafana Alloy Agent                 │ │
│  │                                             │ │
│  │  • Node Exporter (system metrics)          │ │
│  │  • Docker Discovery (containers)           │ │
│  │  • App Scraper (Node.js apps)              │ │
│  │  • Kafka Scraper (JMX metrics)             │ │
│  │  • Log Collector (file/docker logs)        │ │
│  └─────────────────┬───────────────────────────┘ │
│                    │                              │
└────────────────────┼──────────────────────────────┘
                     │
                     │ Push via Remote Write
                     │ (Metrics + Logs)
                     ▼
┌──────────────────────────────────────────────────┐
│          Central Monitoring Stack                 │
│                                                   │
│  ┌─────────────────┐      ┌──────────────────┐  │
│  │   Prometheus    │      │      Loki        │  │
│  │ (Metrics TSDB)  │      │ (Log Aggregator) │  │
│  │                 │      │                  │  │
│  │ /api/v1/write   │      │ /loki/api/v1/push│  │
│  └─────────────────┘      └──────────────────┘  │
│                                                   │
│  ┌─────────────────────────────────────────────┐│
│  │              Grafana                         ││
│  │         (Visualization)                      ││
│  └─────────────────────────────────────────────┘│
└──────────────────────────────────────────────────┘
```

### Push-Based Model

**Unlike traditional Prometheus scraping**, Alloy agents:
1. **Collect metrics** locally on the target server
2. **Push metrics** to central Prometheus via `/api/v1/write`
3. **No firewall rules** needed for inbound connections
4. **Self-register** - no manual target configuration needed

## 📦 Prerequisites

- Docker 24.x+
- Docker Compose 2.x+
- Target server with applications to monitor
- Central Prometheus with remote_write enabled
- 512MB+ RAM
- Network access to Prometheus endpoint

## 🚀 Quick Start

### 1. Clone Repository

```bash
git clone https://github.com/lcx/alloy-agent.git
cd alloy-agent
```

### 2. Configure Environment

```bash
# Copy example environment file
cp .env.example .env

# Edit configuration
nano .env
```

**Required Variables:**

```bash
# Server Identification
SERVER_NAME=accounts-server
ENVIRONMENT=production

# Prometheus Remote Write
PROMETHEUS_URL=https://prometheus.yourdomain.com:9090/api/v1/write
PROMETHEUS_USERNAME=agent-user
PROMETHEUS_PASSWORD=secure-password

# Loki Remote Write (Optional)
LOKI_URL=https://loki.yourdomain.com/loki/api/v1/push
LOKI_USERNAME=agent-user
LOKI_PASSWORD=secure-password

# Application Configuration
APP_NAME=accounts
APP_PORT=3000
APP_METRICS_PATH=/system-stats
APP_METRICS_USERNAME=metrics-user
APP_METRICS_PASSWORD=metrics-password

# Kafka Configuration (if monitoring Kafka)
KAFKA_BROKER_1=localhost:9401
KAFKA_BROKER_2=localhost:9402
KAFKA_BROKER_3=localhost:9403

# Service-specific
REGULA_PORT=8080
```

### 3. Choose Configuration

The `config/` directory contains different configurations:

- **`unified-config.alloy.tmpl`** - All-in-one configuration (recommended)
- **`accounts.alloy.tmpl`** - Accounts service only
- **`exchange.alloy.tmpl`** - Exchange service with logs
- **`kafka.alloy.tmpl`** - Kafka monitoring only

Update `docker-compose.yml` to use your desired config:

```yaml
volumes:
  - ./config/unified-config.alloy:/etc/alloy/config.alloy:ro
```

### 4. Deploy Alloy Agent

```bash
# Make deploy script executable
chmod +x deploy-alloy.sh

# Deploy
./deploy-alloy.sh
```

The script will:
1. Load environment variables from `.env`
2. Generate configuration from template
3. Deploy Alloy agent container
4. Verify health check

### 5. Verify Deployment

```bash
# Check Alloy status
docker ps | grep alloy

# Check logs
docker logs alloy-agent

# Access Alloy UI
curl http://localhost:12345/-/healthy

# View metrics being collected
curl http://localhost:12345/metrics
```

## ⚙️ Configuration

### Unified Configuration Structure

The unified config (`config/unified-config.alloy.tmpl`) includes:

#### 1. Node Exporter (System Metrics)
```alloy
prometheus.exporter.unix "node" {
  disable_collectors = [
    "powersupplyclass", "hwmon", "arp", "bcache",
    // ... other unnecessary collectors
  ]
}
```

#### 2. Remote Write (Prometheus)
```alloy
prometheus.remote_write "default" {
  endpoint {
    url = "${PROMETHEUS_URL}"
    basic_auth {
      username = "${PROMETHEUS_USERNAME}"
      password = "${PROMETHEUS_PASSWORD}"
    }
    tls_config {
      insecure_skip_verify = true  // Set false with valid certs
    }
  }
}
```

#### 3. System Metrics Collection
```alloy
prometheus.scrape "server_metrics" {
  targets = prometheus.exporter.unix.node.targets
  scrape_interval = "15s"
  job_name = "${SERVER_NAME}-node-exporter"
  forward_to = [prometheus.remote_write.default.receiver]
}
```

#### 4. Application Metrics
```alloy
prometheus.scrape "app_metrics" {
  targets = [{
    __address__ = "172.17.0.1:${APP_PORT}",
  }]
  
  metrics_path = "${APP_METRICS_PATH}"
  job_name = "${APP_NAME}"
  forward_to = [prometheus.remote_write.default.receiver]
  
  basic_auth {
    username = "${APP_METRICS_USERNAME}"
    password = "${APP_METRICS_PASSWORD}"
  }
}
```

#### 5. Docker Container Discovery
```alloy
discovery.docker "containers" {
  host = "unix:///var/run/docker.sock"
}

prometheus.scrape "docker_containers" {
  targets = discovery.docker.containers.targets
  job_name = "${SERVER_NAME}-docker"
  
  // Relabel container names
  relabel {
    source_labels = ["__meta_docker_container_name"]
    regex         = "/(.*)"
    target_label  = "container_name"
  }
  
  forward_to = [prometheus.remote_write.default.receiver]
}
```

#### 6. Kafka Monitoring
```alloy
prometheus.scrape "kafka_brokers" {
  targets = [
    {
      __address__ = "${KAFKA_BROKER_1}",
      broker_id   = "1",
    },
    {
      __address__ = "${KAFKA_BROKER_2}",
      broker_id   = "2",
    },
    {
      __address__ = "${KAFKA_BROKER_3}",
      broker_id   = "3",
    },
  ]
  
  job_name = "kafka-brokers"
  forward_to = [prometheus.remote_write.default.receiver]
}
```

#### 7. Log Collection (Optional)
```alloy
loki.write "default" {
  endpoint {
    url = "${LOKI_URL}"
    basic_auth {
      username = "${LOKI_USERNAME}"
      password = "${LOKI_PASSWORD}"
    }
  }
}

loki.source.file "app_logs" {
  targets = [{
    __path__ = "/var/log/app/*.log",
    job = "${APP_NAME}",
  }]
  
  forward_to = [loki.process.app_logs.receiver]
}
```

### Environment Variables Reference

| Variable | Description | Example | Required |
|----------|-------------|---------|----------|
| `SERVER_NAME` | Server identifier | `accounts-server` | ✅ |
| `ENVIRONMENT` | Environment name | `production` | ✅ |
| `PROMETHEUS_URL` | Prometheus endpoint | `https://prom.local/api/v1/write` | ✅ |
| `PROMETHEUS_USERNAME` | Auth username | `agent` | ✅ |
| `PROMETHEUS_PASSWORD` | Auth password | `secret123` | ✅ |
| `APP_NAME` | Application name | `accounts` | ✅ |
| `APP_PORT` | Application port | `3000` | ✅ |
| `APP_METRICS_PATH` | Metrics endpoint | `/metrics` | ✅ |
| `APP_METRICS_USERNAME` | App auth user | `metrics` | ⚠️ |
| `APP_METRICS_PASSWORD` | App auth password | `secret` | ⚠️ |
| `LOKI_URL` | Loki endpoint | `https://loki.local/loki/api/v1/push` | ❌ |
| `KAFKA_BROKER_1` | Kafka broker 1 | `localhost:9401` | ❌ |

✅ Required | ⚠️ Required if app uses auth | ❌ Optional

## 🚀 Deployment

### Standard Deployment

```bash
# 1. Configure environment
cp .env.example .env
nano .env

# 2. Deploy
./deploy-alloy.sh

# 3. Verify
docker logs -f alloy-agent
```

### Manual Deployment

```bash
# Generate config
envsubst < config/unified-config.alloy.tmpl > config/config.alloy

# Start container
docker-compose up -d

# Check status
docker-compose ps
docker-compose logs -f
```

### Multiple Servers

Deploy Alloy on each server you want to monitor:

```bash
# Server 1: Accounts
SERVER_NAME=accounts-server APP_NAME=accounts ./deploy-alloy.sh

# Server 2: Exchange
SERVER_NAME=exchange-server APP_NAME=exchange ./deploy-alloy.sh

# Server 3: Kafka
SERVER_NAME=kafka-server ./deploy-alloy.sh
```

Each agent will:
- Collect local metrics
- Push to central Prometheus
- Self-identify with `SERVER_NAME` label

## 📊 Monitoring Targets

### What Gets Monitored

**System Level:**
- CPU usage (user, system, iowait)
- Memory (used, free, cached, buffers)
- Disk I/O (reads, writes, utilization)
- Network (bytes in/out, errors, drops)
- Filesystem usage per mount point
- Load average (1m, 5m, 15m)

**Application Level:**
- Custom application metrics (Node.js, etc.)
- Request rates and latencies
- Error rates
- Business metrics

**Docker Level:**
- Container CPU usage
- Container memory usage
- Container network I/O
- Container block I/O
- Container state (running, stopped)

**Kafka Level (if enabled):**
- Broker state and health
- Partition metrics
- Consumer lag
- Request rates
- Network I/O

### Checking Collected Metrics

```bash
# View Alloy's own metrics
curl http://localhost:12345/metrics

# Check what's being forwarded
docker logs alloy-agent | grep "remote_write"

# Verify in Prometheus
curl "http://prometheus:9090/api/v1/query?query=up{job=\"${SERVER_NAME}-node-exporter\"}"
```

## 🔐 Security

### Container Security

```yaml
# Applied in docker-compose.yml
security_opt:
  - no-new-privileges:true    # Prevent privilege escalation

cap_drop:
  - ALL                       # Drop all capabilities

cap_add:
  - CHOWN                     # Only needed capabilities
  - DAC_OVERRIDE
  - SETUID
  - SETGID
  - SYS_PTRACE               # For system metrics
  - NET_RAW                  # For network metrics
  - SYS_ADMIN                # For Docker access

tmpfs:
  - /tmp:rw,size=1g,noexec,nosuid,nodev
```

### Authentication

**Prometheus Push:**
- Basic Authentication required
- Credentials in `.env` file
- TLS encryption in transit

**Application Scraping:**
- Optional basic auth for app metrics
- Configure per application

### Network Security

**Host Network Mode:**
- Required for complete system visibility
- Access to Docker socket
- Access to host network interfaces

**Firewall Rules:**
- **Outbound**: Allow HTTPS to Prometheus/Loki
- **Inbound**: Block 12345 from external (Alloy UI)

### Best Practices

1. **Rotate credentials** every 90 days
2. **Use strong passwords** (20+ characters)
3. **Enable TLS verification** (`insecure_skip_verify = false`) with valid certs
4. **Restrict Docker socket** access
5. **Monitor Alloy logs** for errors
6. **Keep Alloy updated**: `docker-compose pull`

## 🔧 Troubleshooting

### Alloy Won't Start

```bash
# Check logs
docker logs alloy-agent

# Common issues:
# 1. Configuration syntax error
docker exec alloy-agent alloy fmt /etc/alloy/config.alloy

# 2. Port already in use
sudo netstat -tlnp | grep 12345

# 3. Missing environment variables
cat .env | grep -v "^#"

# 4. Docker socket permission
ls -la /var/run/docker.sock
```

### Metrics Not Reaching Prometheus

```bash
# Check Alloy health
curl http://localhost:12345/-/healthy

# Check remote write errors in logs
docker logs alloy-agent | grep -i "error\|failed"

# Test Prometheus endpoint
curl -X POST \
  -H "Content-Type: application/x-protobuf" \
  --user username:password \
  ${PROMETHEUS_URL}

# Verify network connectivity
docker exec alloy-agent ping prometheus.yourdomain.com
```

### Application Metrics Not Collected

```bash
# Test application metrics endpoint
curl http://172.17.0.1:${APP_PORT}${APP_METRICS_PATH}

# Check if auth is required
curl -u ${APP_METRICS_USERNAME}:${APP_METRICS_PASSWORD} \
  http://172.17.0.1:${APP_PORT}${APP_METRICS_PATH}

# Check Alloy scrape targets
docker logs alloy-agent | grep "app_metrics"
```

### Docker Container Discovery Not Working

```bash
# Check Docker socket access
docker exec alloy-agent ls -la /var/run/docker.sock

# Test Docker API access
docker exec alloy-agent wget -O- \
  --unix-socket=/var/run/docker.sock \
  http://localhost/containers/json

# Check discovery component
docker logs alloy-agent | grep "discovery.docker"
```

### High Memory Usage

```bash
# Check Alloy memory
docker stats alloy-agent

# Reduce scrape frequency in config
# Change: scrape_interval = "30s"  # from 15s

# Limit metrics cardinality
# Add metric_relabel_configs to drop high-cardinality labels
```

### Configuration Changes Not Applied

```bash
# Regenerate configuration
./deploy-alloy.sh

# Or manually:
envsubst < config/config.alloy.tmpl > config/config.alloy
docker-compose restart alloy

# Verify new config loaded
docker exec alloy-agent cat /etc/alloy/config.alloy
```

## 📈 Maintenance

### Regular Tasks

**Daily:**
- Monitor Alloy health: `curl http://localhost:12345/-/healthy`
- Check logs for errors: `docker logs alloy-agent | grep -i error`

**Weekly:**
- Verify metrics in Prometheus
- Check remote_write success rate
- Review container resource usage

**Monthly:**
- Update Alloy image: `docker-compose pull && docker-compose up -d`
- Review and optimize configuration
- Rotate credentials

### Updates

```bash
# Pull latest Alloy image
docker-compose pull

# Restart with new image
docker-compose up -d

# Verify version
docker exec alloy-agent alloy --version
```

### Backup

```bash
# Backup configuration
tar czf alloy-backup-$(date +%Y%m%d).tar.gz \
  config/ .env docker-compose.yml

# Backup Alloy data
docker run --rm \
  -v alloy-agent_alloy_data:/data \
  -v $(pwd)/backups:/backup \
  alpine tar czf /backup/alloy-data-$(date +%Y%m%d).tar.gz -C /data .
```

## 📄 License

MIT License

## 👤 Author

**DevSecOps Team @ LCX**

## 📞 Support

- **GitLab Issues**: https://gitlab.com/lcx/alloy-agent/-/issues
- **Internal Slack**: #devops-monitoring
- **Email**: devops@lcx.com

---

**Distributed metrics collection for cryptocurrency exchange infrastructure** 🚀📊