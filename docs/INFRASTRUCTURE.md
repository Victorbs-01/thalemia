# Infrastructure & Deployment

This document describes the infrastructure topology, node assignments, and deployment configuration for Entrepreneur-OS.

## Node Assignments (DV01-DV06)

The platform runs on distributed infrastructure across physical nodes:

| Node   | Services                                          | Purpose                           |
| ------ | ------------------------------------------------- | --------------------------------- |
| **DV02** | vendure-master, postgres-master, redis, K3s master | Master PIM instance & K3s control |
| **DV04** | vendure-ecommerce, postgres-ecommerce, n8n, storefronts | Ecommerce instance & automation |
| **DV05** | OpenSearch (hot tier), Prometheus, Grafana, Wazuh | Monitoring & security (SSD)       |
| **DV06** | OpenSearch (warm tier), Vector, Redpanda, Uptime Kuma | Log processing & streaming (HDD) |
| **Digital Ocean** | Nginx, WireGuard, SSL termination             | Public gateway & VPN              |

**For complete node inventory:** See `infrastructure/ansible/inventory/hosts.yml`

## Docker Services

The `docker-compose.yml` defines all services for local development:

### Database Services

| Service             | Port  | Description                      |
| ------------------- | ----- | -------------------------------- |
| postgres-master     | 5432  | Master instance database         |
| postgres-ecommerce  | 5433  | Ecommerce instance database      |
| redis               | 6379  | Shared cache layer               |
| adminer             | 8080  | Database UI (http://localhost:8080) |

### Application Services

| Service            | Ports      | Description                           |
| ------------------ | ---------- | ------------------------------------- |
| vendure-master     | 3000, 3001 | PIM API (3000), Admin UI (3001)       |
| vendure-ecommerce  | 3002, 3003 | Ecommerce API (3002), Admin UI (3003) |
| n8n                | 5678       | Workflow automation                   |

### Monitoring Services (Production)

| Service              | Port  | Description                          |
| -------------------- | ----- | ------------------------------------ |
| Prometheus           | 9090  | Metrics collection                   |
| Grafana              | 3010  | Visualization & alerting             |
| OpenSearch           | 9200  | Log aggregation & search             |
| OpenSearch Dashboards| 5601  | Security dashboards                  |
| Wazuh                | 1514  | Security event monitoring            |

## Port Reference

**Quick Reference:**

```
Vendure Master:       3000 (API), 3001 (Admin)
Vendure Ecommerce:    3002 (API), 3003 (Admin)
PostgreSQL Master:    5432
PostgreSQL Ecommerce: 5433
Redis:                6379
n8n:                  5678
Adminer:              8080
Prometheus:           9090
Grafana:              3010
OpenSearch:           9200
OpenSearch Dashboards:5601
```

## Docker Commands

```bash
# Start all services
pnpm run docker:up

# Stop services (preserve state)
pnpm run docker:stop

# Stop and remove containers
pnpm run docker:down

# Restart all services
pnpm run docker:restart

# View logs
pnpm run docker:logs

# Check status
pnpm run docker:ps

# Force rebuild
pnpm run docker:rebuild

# Clean everything
pnpm run docker:clean
```

## China Deployment

The platform includes specialized configuration for China deployment:

### Environment Variables

```bash
USE_CHINA_MIRRORS=true
CHINA_MIRROR_URL=https://mirrors.tuna.tsinghua.edu.cn
NPM_REGISTRY=https://registry.npmmirror.com
```

### Ansible Playbooks

```bash
# Setup China mirrors (in infrastructure/ansible/playbooks/)
ansible-playbook 00-china-mirrors.yml

# Setup Tailscale for GFW bypass
ansible-playbook 03-tailscale-setup.yml
```

### Docker Registry Mirrors

Configured in `infrastructure/ansible/roles/docker/` for Aliyun registry access.

## Key Infrastructure Files

| Path                            | Purpose                              |
| ------------------------------- | ------------------------------------ |
| `docker-compose.yml`            | Local development services           |
| `infrastructure/compose/`       | Service-specific Docker Compose      |
| `infrastructure/ansible/`       | Infrastructure as Code               |
| `infrastructure/kubernetes/`    | K3s manifests for production         |
| `infrastructure/ansible/inventory/hosts.yml` | Complete node inventory |

## Network Architecture

```
Internet
    ↓
Digital Ocean VPS (Nginx + WireGuard)
    ↓ (VPN tunnel)
DV02 (K3s Master) → Ingress Controller
    ↓
├── vendure-master (DV02:3000/3001)
├── vendure-ecommerce (DV04:3002/3003)
├── n8n (DV04:5678)
├── Grafana (DV05:3010)
└── OpenSearch Dashboards (DV05:5601)
```

## Storage Architecture

- **SSD (Hot tier)**: DV05 - OpenSearch hot indices (7 days)
- **HDD (Warm tier)**: DV06 - OpenSearch warm indices (30 days)
- **S3 (Cold tier)**: MinIO - Archived logs (90 days)
- **Delete**: After 180 days

For index lifecycle management details, see [ARCHITECTURE.md](ARCHITECTURE.md).
