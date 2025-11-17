# System Architecture

Detailed architecture documentation for Entrepreneur-OS.

## Table of Contents

- [Dual-Vendure Pattern](#dual-vendure-pattern)
- [Multi-Tenancy Strategy](#multi-tenancy-strategy)
- [Database Architecture](#database-architecture)
- [Security & Monitoring](#security--monitoring)
- [China Deployment](#china-deployment)

## Dual-Vendure Pattern

### Overview

Entrepreneur-OS implements a **master/ecommerce separation** pattern where product data originates in a master PIM system and flows to operational ecommerce instances.

### Architecture Components

```
┌─────────────────────────────────────────────────────────────┐
│                    vendure-master (DV02)                     │
│  ┌────────────────────────────────────────────────────────┐ │
│  │ Product Information Management (PIM)                   │ │
│  │ - Product catalogs                                     │ │
│  │ - Supplier management                                  │ │
│  │ - Pricing rules                                        │ │
│  │ - Asset management                                     │ │
│  └────────────────────────────────────────────────────────┘ │
│                      postgres-master (5432)                  │
└───────────────────────────────┬─────────────────────────────┘
                                │
                        n8n sync workflows
                                │
                                ↓
┌─────────────────────────────────────────────────────────────┐
│                 vendure-ecommerce (DV04)                     │
│  ┌────────────────────────────────────────────────────────┐ │
│  │ Retail Operations                                      │ │
│  │ - Order processing                                     │ │
│  │ - Inventory management                                 │ │
│  │ - Customer transactions                                │ │
│  │ - Payment processing                                   │ │
│  └────────────────────────────────────────────────────────┘ │
│                   postgres-ecommerce (5433)                  │
└───────────────────────────────┬─────────────────────────────┘
                                │
                                ↓
                    ┌───────────────────────┐
                    │   Storefronts         │
                    │ - Next.js storefront  │
                    │ - Vite storefront     │
                    └───────────────────────┘
```

### Data Flow

1. **Product Master (vendure-master)**
   - Manages product catalog centrally
   - Single source of truth for product data
   - Handles supplier relationships
   - Manages pricing strategies

2. **n8n Sync Workflows**
   - Automated data synchronization
   - Product sync: master → ecommerce
   - Bi-directional sync for inventory updates
   - Order status sync: ecommerce → master

3. **Ecommerce Instance (vendure-ecommerce)**
   - Receives product data from master
   - Handles customer orders
   - Manages fulfillment workflows
   - Processes payments

4. **Storefronts**
   - Next.js (SSR/SSG for SEO)
   - Vite (SPA for interactive UX)
   - Connect to vendure-ecommerce GraphQL API

### Benefits

- **Independent Scaling**: Scale catalog management separately from retail operations
- **Tenant Isolation**: Each tenant can have dedicated ecommerce instances
- **Clear Separation**: PIM concerns separated from order fulfillment
- **Data Integrity**: Master instance is authoritative source
- **Horizontal Scaling**: Multiple ecommerce instances can share same master

### When to Use Each Instance

| Operation | Instance | Reason |
| --------- | -------- | ------ |
| Add new product | master | Single source of truth |
| Update pricing | master | Centralized pricing strategy |
| Process order | ecommerce | Operational workload |
| Customer checkout | ecommerce | Real-time transactional data |
| Inventory update | ecommerce → master | Bi-directional sync via n8n |
| Supplier management | master | PIM responsibility |

## Multi-Tenancy Strategy

### Implementation

Multi-tenancy is achieved through:

1. **Database Separation**
   - Separate PostgreSQL databases per Vendure instance
   - Physical isolation of tenant data
   - Independent scaling per tenant

2. **Custom Vendure Plugins** (`libs/vendure/plugins/`)
   - `MultiTenantPlugin`: Tenant context middleware
   - Tenant-aware GraphQL resolvers
   - Per-tenant configuration management

3. **n8n Workflow Orchestration** (`apps/n8n-workflows/`)
   - Tenant-specific sync workflows
   - Data routing based on tenant ID
   - Isolated automation per tenant

4. **Custom Entity Fields**
   - `tenantId` field on entities
   - Tenant context in GraphQL operations
   - Row-level security via custom middleware

### Tenant Isolation Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    vendure-master                            │
│  Tenant A Catalog │ Tenant B Catalog │ Tenant C Catalog      │
│                   postgres-master                            │
└───────────────────────────────────────────────────────────────┘
                          │
                    n8n tenant routing
                          │
        ┌─────────────────┼─────────────────┐
        ↓                 ↓                 ↓
┌───────────────┐ ┌───────────────┐ ┌───────────────┐
│ Ecommerce A   │ │ Ecommerce B   │ │ Ecommerce C   │
│ postgres-a    │ │ postgres-b    │ │ postgres-c    │
└───────────────┘ └───────────────┘ └───────────────┘
```

### Scaling Strategy

- **Start**: Single vendure-master + single vendure-ecommerce
- **Growth**: Single master + multiple ecommerce instances (per tenant)
- **Enterprise**: Federated masters + dedicated ecommerce clusters

## Database Architecture

### Schema Organization

**vendure_master (postgres-master:5432)**
```sql
-- Product Information
Products, ProductVariants, ProductOptions
Assets, Facets, Collections

-- Supplier Management
Suppliers, PurchaseOrders, SupplierPricing

-- Tenant Metadata
Tenants, TenantConfigurations

-- Multi-tenant extensions
CustomEntities with tenantId field
```

**vendure_ecommerce (postgres-ecommerce:5433)**
```sql
-- Operational Data
Orders, OrderLines, Payments
Customers, Addresses, Sessions

-- Inventory
StockLevels, StockMovements, Allocations

-- Fulfillment
Shipments, FulfillmentTracking, Returns

-- Replicated from Master
Products (read-only replica via n8n sync)
```

### Connection Pooling

- **redis (port 6379)**: Shared cache layer for both instances
- **Connection limits**:
  - postgres-master: 100 connections
  - postgres-ecommerce: 200 connections (higher transactional load)

### Backup Strategy

- **Continuous**: WAL archiving to S3
- **Daily snapshots**: pg_dump to local storage
- **Retention**: 30 days local, 90 days S3
- **Point-in-time recovery**: Enabled via WAL

## Security & Monitoring

### SIEM/SOC Stack

Comprehensive security monitoring across all infrastructure:

**Components:**

1. **Wazuh** (DV05)
   - Security event monitoring
   - File integrity monitoring (FIM)
   - Rootkit detection
   - Incident response automation

2. **OpenSearch SIEM** (DV05/DV06)
   - SIGMA rules for threat detection
   - Security event correlation
   - Alert aggregation
   - Forensic investigation

3. **Suricata** (Network IDS/IPS)
   - Network intrusion detection
   - Traffic analysis
   - Protocol anomaly detection

4. **Falco** (Kubernetes Runtime Security)
   - Container runtime monitoring
   - Syscall auditing
   - Behavioral anomaly detection

**For detailed rules:** See `docs/security/DETECTION-RULES.md`
**For incident response:** See `docs/security/INCIDENT-RESPONSE-PLAYBOOKS.md`

### Observability Stack (HELK/OpenSearch)

```
┌─────────────────────────────────────────────────────────────┐
│                       Applications                           │
│  vendure-master │ vendure-ecommerce │ n8n │ storefronts      │
└───────────────────────────┬──────────────────────────────────┘
                            │ logs/metrics/traces
                            ↓
                    ┌───────────────┐
                    │    Vector     │ (DV06)
                    │ Log processing│
                    └───────┬───────┘
                            │
                    ┌───────┴────────┐
                    │   Redpanda     │ (DV06)
                    │ Streaming      │
                    └───────┬────────┘
                            │
        ┌───────────────────┼───────────────────┐
        ↓                   ↓                   ↓
┌───────────────┐  ┌────────────────┐  ┌───────────────┐
│ OpenSearch    │  │  Prometheus    │  │    Grafana    │
│ Hot Tier      │  │  Metrics       │  │  Dashboards   │
│ (DV05 SSD)    │  │  (DV05)        │  │  (DV05)       │
└───────┬───────┘  └────────────────┘  └───────────────┘
        │
        ↓
┌───────────────┐
│ OpenSearch    │
│ Warm Tier     │
│ (DV06 HDD)    │
└───────────────┘
```

### Monitoring Services

| Service              | Port | Purpose                              |
| -------------------- | ---- | ------------------------------------ |
| Prometheus           | 9090 | Metrics collection & alerting        |
| Grafana              | 3010 | Visualization & dashboards           |
| OpenSearch           | 9200 | Log aggregation & SIEM               |
| OpenSearch Dashboards| 5601 | Security dashboards                  |
| Wazuh                | 1514 | Security event monitoring            |
| Uptime Kuma          | 3001 | Service health monitoring            |

### Index Lifecycle Management

OpenSearch implements tiered storage for cost optimization:

| Tier | Storage | Retention | Location | Use Case |
| ---- | ------- | --------- | -------- | -------- |
| Hot  | SSD     | 7 days    | DV05     | Fast queries, active investigations |
| Warm | HDD     | 30 days   | DV06     | Historical analysis, compliance     |
| Cold | S3      | 90 days   | MinIO    | Long-term archival, audit           |
| Delete | -     | 180 days  | -        | Permanent deletion                  |

**Automated transitions:**
- Day 0-7: Hot tier (SSD, DV05)
- Day 8-30: Warm tier (HDD, DV06)
- Day 31-90: Cold tier (S3, MinIO)
- Day 90+: Deleted

## China Deployment

### Challenges

1. **Great Firewall (GFW)**: Blocks NPM, GitHub, Docker Hub
2. **DNS poisoning**: Unreliable resolution of foreign domains
3. **Network latency**: High latency to overseas servers
4. **Compliance**: Data sovereignty requirements

### Solutions

#### 1. Mirror Configuration

**NPM Registry:**
```bash
# .npmrc
registry=https://registry.npmmirror.com
```

**Docker Registry:**
```yaml
# /etc/docker/daemon.json
{
  "registry-mirrors": [
    "https://docker.mirrors.sjtug.sjtu.edu.cn",
    "https://hub-mirror.c.163.com"
  ]
}
```

**Ansible/APT Mirrors:**
```yaml
# infrastructure/ansible/playbooks/00-china-mirrors.yml
china_mirror_url: https://mirrors.tuna.tsinghua.edu.cn
```

#### 2. VPN/Proxy

**Tailscale** (preferred for GFW bypass):
```bash
# Setup Tailscale mesh network
ansible-playbook infrastructure/ansible/playbooks/03-tailscale-setup.yml
```

**Benefits:**
- Mesh VPN for node-to-node communication
- GFW bypass without centralized VPN
- Peer-to-peer encrypted tunnels

#### 3. Environment Variables

```bash
# .env for China deployment
USE_CHINA_MIRRORS=true
CHINA_MIRROR_URL=https://mirrors.tuna.tsinghua.edu.cn
NPM_REGISTRY=https://registry.npmmirror.com
NVM_NODEJS_ORG_MIRROR=https://npmmirror.com/mirrors/node
CYPRESS_INSTALL_BINARY=0  # Skip Cypress download
PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1  # Skip Playwright browsers
```

#### 4. Ansible Roles

**China-specific roles:**
- `infrastructure/ansible/roles/china-mirrors/`
- `infrastructure/ansible/roles/tailscale/`
- `infrastructure/ansible/roles/docker/` (with Aliyun registry)

### Recommended Architecture for China

```
Digital Ocean VPS (Singapore/HK)
    ↓ (Tailscale VPN)
China Nodes (DV01-DV06)
    │
    ├── DV02: vendure-master (China mirrors)
    ├── DV04: vendure-ecommerce (China mirrors)
    ├── DV05: OpenSearch + Monitoring
    └── DV06: Log processing
```

**Benefits:**
- VPS outside GFW for gateway/API access
- Nodes in China for low-latency data processing
- Tailscale mesh for secure communication
- China mirrors for all dependencies

### Testing China Deployment

```bash
# Set environment variables
export USE_CHINA_MIRRORS=true

# Run Ansible playbooks
ansible-playbook infrastructure/ansible/playbooks/00-china-mirrors.yml
ansible-playbook infrastructure/ansible/playbooks/03-tailscale-setup.yml

# Verify mirror usage
npm config get registry  # Should show npmmirror.com
docker info | grep -i mirror  # Should show China mirrors
```

## Additional Resources

- **Infrastructure Details**: [INFRASTRUCTURE.md](INFRASTRUCTURE.md)
- **Troubleshooting**: [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
- **Development Workflow**: [../CLAUDE.md](../CLAUDE.md)
- **Security Policies**: `docs/security/`
- **Ansible Playbooks**: `infrastructure/ansible/playbooks/`
