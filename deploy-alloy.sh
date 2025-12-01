#!/bin/bash

set -e

# Load environment variables
if [ -f ".env" ]; then
    export $(grep -v '^#' .env | xargs)
else
    echo "ERROR: .env file not found!"
    exit 1
fi

docker compose down

# Generate Alloy configuration
envsubst < config/config.alloy.tmpl > config/config.alloy
echo "✅ Configuration generated"

# Deploy with Docker Compose
echo "🚀 Deploying Alloy..."
docker compose up -d

# Wait a moment for startup
sleep 5

# Test endpoint
echo "🔍 Testing Alloy endpoint..."
if curl -s http://localhost:12345/-/healthy > /dev/null; then
    echo "✅ Alloy is healthy"
    echo "🌐 Access Alloy at: http://localhost:12345"
    echo "📊 Metrics at: http://localhost:12345/metrics"
else
    echo "❌ Alloy health check failed"
    echo "📋 Check logs: sudo docker-compose logs alloy"
fi