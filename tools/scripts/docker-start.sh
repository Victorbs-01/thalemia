#!/bin/bash
set -e

echo "🐳 Starting Docker infrastructure..."

# Levantar servicios base
docker-compose up -d postgres-master postgres-ecommerce redis

echo "⏳ Waiting for databases to be healthy..."
sleep 10

# Levantar servicios de monitoring
docker-compose up -d opensearch opensearch-dashboards prometheus grafana uptime-kuma

echo "⏳ Waiting for monitoring services..."
sleep 15

# Levantar n8n
docker-compose up -d n8n

echo "✅ All services are up!"
echo ""
echo "📊 Services:"
echo "  - PostgreSQL Master: localhost:5432"
echo "  - PostgreSQL Ecommerce: localhost:5433"
echo "  - Redis: localhost:6379"
echo "  - OpenSearch: http://localhost:9200"
echo "  - OpenSearch Dashboards: http://localhost:5601"
echo "  - Prometheus: http://localhost:9090"
echo "  - Grafana: http://localhost:3010 (admin/admin)"
echo "  - n8n: http://localhost:5678 (admin/admin)"
echo "  - Uptime Kuma: http://localhost:3011"
echo "  - Adminer: http://localhost:8080"
echo ""
echo "🔍 Check status: docker-compose ps"
echo "📋 View logs: docker-compose logs -f [service]"