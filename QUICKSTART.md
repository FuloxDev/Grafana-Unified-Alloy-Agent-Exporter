# 🚀 Quick Start Guide - Grafana Alloy Agent

Get your Alloy agent collecting and pushing metrics in under 5 minutes!

## Prerequisites

- Docker and Docker Compose installed
- Access to central Prometheus with remote_write enabled
- Application with `/metrics` endpoint (optional)

## Step 1: Clone Repository

```bash
git clone https://github.com/lcx/alloy-agent.git
cd alloy-agent
```

## Step 2: Configure

```bash
# Copy environment template
cp .env.example .env

# Edit configuration
nano .env
```

**Minimal Required Configuration:**

```bash
# Server identification
SERVER_NAME=my-server
ENVIRONMENT=production

# Prometheus remote write endpoint
PROMETHEUS_URL=https://prometheus.yourdomain.com:9090/api/v1/write
PROMETHEUS_USERNAME=agent-user
PROMETHEUS_PASSWORD=your-secure-password

# Your application
APP_NAME=my-app
APP_PORT=3000
APP_METRICS_PATH=/metrics
```

## Step 3: Deploy

```bash
# Make script executable
chmod +x deploy-alloy.sh

# Deploy
./deploy-alloy.sh
```

## Step 4: Verify

```bash
# Check if running
docker ps | grep alloy

# Check health
curl http://localhost:12345/-/healthy

# View metrics being collected
curl http://localhost:12345/metrics
```

## Step 5: Check Prometheus

```bash
# Query Prometheus for your server's metrics
curl "http://prometheus:9090/api/v1/query?query=up{server=\"my-server\"}"
```

## What Gets Monitored

By default, Alloy collects:

✅ **System Metrics**
- CPU usage
- Memory usage
- Disk I/O
- Network traffic
- Load average

✅ **Application Metrics** (if available)
- Custom metrics from your app's `/metrics` endpoint

✅ **Docker Containers**
- All running containers on the host
- Container resource usage

## Access Alloy UI

Open http://localhost:12345 in your browser to see:
- Component graph
- Scrape targets
- Metrics being forwarded
- Agent health status

## Common Commands

```bash
# View logs
docker logs -f alloy-agent

# Restart agent
docker-compose restart

# Stop agent
docker-compose down

# Update configuration
./deploy-alloy.sh
```

## Next Steps

- Add more applications by editing `.env` and `config/unified-config.alloy.tmpl`
- Enable Kafka monitoring (uncomment in config)
- Enable Loki log collection (uncomment in config)
- Deploy Alloy on other servers

## Troubleshooting

**Container won't start?**
```bash
docker logs alloy-agent
```

**Metrics not reaching Prometheus?**
```bash
# Check remote write errors
docker logs alloy-agent | grep "remote_write"

# Test Prometheus endpoint
curl -X POST --user username:password ${PROMETHEUS_URL}
```

**Application metrics not collected?**
```bash
# Test if endpoint is accessible
curl http://172.17.0.1:3000/metrics
```

## Need Help?

- Check [README.md](README.md) for full documentation
- Review [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for common issues
- Contact: devops@lcx.com

---

**You're all set! Alloy is now pushing metrics to your central Prometheus.** 🎉