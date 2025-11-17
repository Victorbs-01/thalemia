# Infrastructure Documentation

**Entrepreneur-OS Datacenter Infrastructure Overview**

Complete documentation hub for the Entrepreneur-OS multi-tenant e-commerce platform infrastructure.

---

## Table of Contents

- [System Overview](#system-overview)
- [Architecture Diagram](#architecture-diagram)
- [Infrastructure Components](#infrastructure-components)
- [Ports Map](#ports-map)
- [Docker Networks](#docker-networks)
- [Volume Storage](#volume-storage)
- [File Structure](#file-structure)
- [Deployment Phases](#deployment-phases)
- [Quick Start](#quick-start)
- [Related Documentation](#related-documentation)

---

## System Overview

Entrepreneur-OS is a **multi-tenant e-commerce and business operations platform** built on modern cloud-native technologies. The platform features:

- **Dual-Vendure Architecture**: Separation of Product Information Management (PIM) and retail operations
- **Comprehensive Observability**: HELK stack (OpenSearch) + Prometheus + Grafana
- **Enterprise Security**: SOC/SIEM with Wazuh, SIGMA rules, and automated threat detection
- **Business Automation**: n8n workflows for cross-system integration
- **Distributed Infrastructure**: Multi-node deployment across DV01-DV06 hardware nodes
- **GitOps Ready**: Complete Infrastructure as Code with Ansible + Kubernetes

**Technology Stack:**
- **Application Layer**: Vendure (Node.js), Next.js, Vite
- **Data Layer**: PostgreSQL, Redis, OpenSearch
- **Orchestration**: Docker Compose (dev), K3s (production)
- **Automation**: n8n, Ansible
- **Monitoring**: Prometheus, Grafana, OpenSearch, Uptime Kuma
- **Security**: Wazuh, Suricata, Falco, Vector (log aggregation)
- **Version Control**: Gitea (local), GitHub (cloud)

---

## Architecture Diagram

### Logical Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        ENTREPRENEUR-OS PLATFORM                          │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                           │
│  ┌────────────────────────┐         ┌────────────────────────┐          │
│  │   FRONTEND LAYER       │         │   APPLICATION LAYER     │          │
│  ├────────────────────────┤         ├────────────────────────┤          │
│  │                        │         │                        │          │
│  │  Nginx Reverse Proxy   │────────▶│  Vendure Master (PIM)  │          │
│  │  (port 80)             │         │  Ports: 3000/3001      │          │
│  │                        │         │                        │          │
│  │  Next.js Storefront    │────────▶│  Vendure Ecommerce     │          │
│  │  (master.local)        │         │  Ports: 3002/3003      │          │
│  │                        │         │                        │          │
│  │  Vite Storefront       │         │  n8n Automation        │          │
│  │  (shop1.local)         │         │  Port: 5678            │          │
│  │                        │         │                        │          │
│  └────────────────────────┘         └────────────┬───────────┘          │
│                                                   │                      │
│  ┌────────────────────────────────────────────────┼──────────────────┐  │
│  │              DATA LAYER                        │                  │  │
│  ├────────────────────────────────────────────────┼──────────────────┤  │
│  │                                                 │                  │  │
│  │  PostgreSQL Master      PostgreSQL Ecommerce   │   Redis Cache    │  │
│  │  (port 5432)            (port 5433)            │   (port 6379)    │  │
│  │                                                 │                  │  │
│  └─────────────────────────────────────────────────┴──────────────────┘  │
│                                                                           │
│  ┌─────────────────────────────────────────────────────────────────────┐ │
│  │              AUTOMATION & INTEGRATION                               │ │
│  ├─────────────────────────────────────────────────────────────────────┤ │
│  │                                                                     │ │
│  │  n8n Workflows:                                                     │ │
│  │  • Product sync: Master → Ecommerce                                │ │
│  │  • Order processing: Ecommerce → CRM/ERP                           │ │
│  │  • Inventory sync                                                   │ │
│  │                                                                     │ │
│  └─────────────────────────────────────────────────────────────────────┘ │
│                                                                           │
│  ┌─────────────────────────────────────────────────────────────────────┐ │
│  │              MONITORING & OBSERVABILITY (HELK STACK)                │ │
│  ├─────────────────────────────────────────────────────────────────────┤ │
│  │                                                                     │ │
│  │  OpenSearch (9200)      Grafana (3010)       Prometheus (9090)     │ │
│  │  • SIEM logs            • Dashboards         • Metrics collection  │ │
│  │  • Security events      • Alerting           • Service health      │ │
│  │  • Application logs     • Visualization      • Performance         │ │
│  │                                                                     │ │
│  │  Uptime Kuma (3011)                                                │ │
│  │  • Service monitoring                                               │ │
│  │  • Status pages                                                     │ │
│  │                                                                     │ │
│  └─────────────────────────────────────────────────────────────────────┘ │
│                                                                           │
│  ┌─────────────────────────────────────────────────────────────────────┐ │
│  │              DEVELOPMENT TOOLS                                      │ │
│  ├─────────────────────────────────────────────────────────────────────┤ │
│  │                                                                     │ │
│  │  Gitea (3080)           Adminer (8080)        Mailhog (8025)       │ │
│  │  • Git hosting          • Database UI         • Email testing      │ │
│  │  • Code review          • SQL client          • SMTP capture       │ │
│  │  • Mirror repos         • Multi-DB support    • Dev only           │ │
│  │                                                                     │ │
│  └─────────────────────────────────────────────────────────────────────┘ │
│                                                                           │
└───────────────────────────────────────────────────────────────────────────┘

                          All connected via:
                     entrepreneur-network (Docker bridge)
```

### Physical Infrastructure (Distributed Nodes)

```
┌──────────────────────────────────────────────────────────────────────────┐
│                    DISTRIBUTED DATACENTER TOPOLOGY                        │
├──────────────────────────────────────────────────────────────────────────┤
│                                                                            │
│  ┌─────────────┐   ┌─────────────┐   ┌─────────────┐   ┌─────────────┐  │
│  │    DV02     │   │    DV04     │   │    DV05     │   │    DV06     │  │
│  ├─────────────┤   ├─────────────┤   ├─────────────┤   ├─────────────┤  │
│  │             │   │             │   │             │   │             │  │
│  │ Vendure     │   │ Vendure     │   │ OpenSearch  │   │ OpenSearch  │  │
│  │ Master      │   │ Ecommerce   │   │ (Hot Tier)  │   │ (Warm Tier) │  │
│  │             │   │             │   │             │   │             │  │
│  │ PostgreSQL  │   │ PostgreSQL  │   │ Prometheus  │   │ Vector      │  │
│  │ Master      │   │ Ecommerce   │   │             │   │             │  │
│  │             │   │             │   │ Grafana     │   │ Redpanda    │  │
│  │ Redis       │   │ n8n         │   │             │   │             │  │
│  │             │   │             │   │ Wazuh       │   │ Uptime      │  │
│  │ K3s Master  │   │ Storefronts │   │             │   │ Kuma        │  │
│  │             │   │             │   │             │   │             │  │
│  └─────────────┘   └─────────────┘   └─────────────┘   └─────────────┘  │
│         │                  │                  │                  │        │
│         └──────────────────┴──────────────────┴──────────────────┘        │
│                              Tailscale VPN                                │
│                          (192.168.x.x network)                            │
│                                                                            │
│  ┌───────────────────────────────────────────────────────────────────┐   │
│  │                    Digital Ocean VPS (Gateway)                    │   │
│  ├───────────────────────────────────────────────────────────────────┤   │
│  │                                                                   │   │
│  │  Nginx (80/443)  │  WireGuard  │  SSL Termination  │  Firewall   │   │
│  │                                                                   │   │
│  └───────────────────────────────────────────────────────────────────┘   │
│                                 │                                         │
│                                 ▼                                         │
│                          Public Internet                                 │
│                                                                            │
└──────────────────────────────────────────────────────────────────────────┘
```

**Node Assignments:**
See `infrastructure/ansible/inventory/hosts.yml` for complete hardware specifications and service assignments.

---

## Infrastructure Components

### Core Services

| Service | Purpose | Technology | Ports | Status |
|---------|---------|------------|-------|--------|
| **Vendure Master** | Product Information Management (PIM) | Node.js, TypeScript | 3000, 3001 | Placeholder |
| **Vendure Ecommerce** | Retail operations, orders, customers | Node.js, TypeScript | 3002, 3003 | Placeholder |
| **PostgreSQL Master** | Database for Vendure Master | PostgreSQL 15 | 5432 | Active |
| **PostgreSQL Ecommerce** | Database for Vendure Ecommerce | PostgreSQL 15 | 5433 | Active |
| **Redis** | Shared cache layer | Redis 7 | 6379 | Active |

### Frontend Services

| Service | Purpose | Technology | Ports | Status |
|---------|---------|------------|-------|--------|
| **Nginx Reverse Proxy** | Routes traffic to storefronts | Nginx | 80 | Active |
| **Next.js Storefront** | React storefront (master.local) | Next.js 14 | Internal | Development |
| **Vite Storefront** | Lightweight storefront (shop1.local) | Vite, React | Internal | Development |

### Automation

| Service | Purpose | Technology | Ports | Status |
|---------|---------|------------|-------|--------|
| **n8n** | Business process automation | Node.js | 5678 | Active |

**Key Workflows:**
- Product sync: Master → Ecommerce
- Order processing automation
- Inventory synchronization
- Cross-system integrations

### Monitoring & Observability

| Service | Purpose | Technology | Ports | Status |
|---------|---------|------------|-------|--------|
| **OpenSearch** | SIEM, log aggregation, security analytics | OpenSearch 2.x | 9200, 9600 | Active |
| **OpenSearch Dashboards** | Security dashboards, log visualization | OpenSearch | 5601 | Active |
| **Prometheus** | Metrics collection, time-series database | Prometheus | 9090 | Active |
| **Grafana** | Monitoring dashboards, alerting | Grafana | 3010 | Active |
| **Uptime Kuma** | Service uptime monitoring | Node.js | 3011 | Active |

### Development Tools

| Service | Purpose | Technology | Ports | Status |
|---------|---------|------------|-------|--------|
| **Gitea** | Self-hosted Git service, LAN mirror | Go | 3080, 2222 | Active |
| **Adminer** | Database administration UI | PHP | 8080 | Active |
| **Mailhog** | Email testing (dev only) | Go | 1025, 8025 | Dev Only |

### Security (Future Deployment)

| Service | Purpose | Technology | Ports | Status |
|---------|---------|------------|-------|--------|
| **Wazuh** | Security monitoring, SIEM agent | Wazuh | 1514, 1515 | Planned |
| **Suricata** | Network IDS/IPS | Suricata | - | Planned |
| **Falco** | Kubernetes runtime security | Falco | - | Planned |
| **Vector** | Log processing and routing | Vector | 8686 | Planned |
| **Redpanda** | Streaming message buffer | Redpanda | 9092 | Planned |

---

## Ports Map

### Complete Port Allocation

**Database Layer:**
- `5432` - PostgreSQL Master
- `5433` - PostgreSQL Ecommerce
- `6379` - Redis

**Application Layer:**
- `3000` - Vendure Master API
- `3001` - Vendure Master Admin UI
- `3002` - Vendure Ecommerce API
- `3003` - Vendure Ecommerce Admin UI
- `5678` - n8n Automation

**Frontend Layer:**
- `80` - Nginx Reverse Proxy
- `3010` - Grafana (also Next.js storefront in .env)
- `3011` - Uptime Kuma (also Vite storefront in .env)

**Development Tools:**
- `3080` - Gitea HTTP
- `2222` - Gitea SSH
- `8080` - Adminer
- `8025` - Mailhog Web UI (dev)
- `1025` - Mailhog SMTP (dev)

**Monitoring & Logs:**
- `9090` - Prometheus
- `9200` - OpenSearch API
- `9600` - OpenSearch Metrics
- `5601` - OpenSearch Dashboards

**Available Ranges:**
- `3020-3079` - Reserved for future services
- `8000-8079` - Reserved for admin UIs
- `9000-9089` - Reserved for monitoring

---

## Docker Networks

### entrepreneur-network

**Type:** Bridge network
**Purpose:** Connects all Entrepreneur-OS services
**DNS Resolution:** Automatic (container names as hostnames)

**Connected Services:**
- All Vendure instances
- All PostgreSQL databases
- Redis
- OpenSearch cluster
- Prometheus, Grafana
- n8n
- Gitea
- Adminer
- Storefronts (via reverse proxy)

**Network Configuration:**

```yaml
networks:
  entrepreneur-network:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.0.0/16
```

**Service Communication Examples:**

```bash
# From any container, services are reachable by name:
curl http://vendure-master:3000
psql -h postgres-master -U vendure -d vendure_master
redis-cli -h redis
curl http://gitea:3000
```

**External Access:**
- Services expose specific ports to host (see [Ports Map](#ports-map))
- LAN devices access via host IP (e.g., `http://192.168.1.100:3080`)
- Domain names configured via `/etc/hosts` (e.g., `gitea.local`)

---

## Volume Storage

### Current Volumes (12 volumes)

Complete inventory and management guide: **[Volume Layout Documentation](./volumes-layout.md)**

**High-Priority Volumes (Daily Backups):**
- `postgres-master-data` - Product catalog
- `postgres-ecommerce-data` - Orders, customers
- `gitea-data` - Git repositories
- `gitea-postgres-data` - Git metadata
- `n8n-data` - Automation workflows
- `opensearch-data` - Security logs

**Medium-Priority Volumes (Weekly Backups):**
- `redis-data` - Cache
- `grafana-data` - Dashboards
- `prometheus-data` - Metrics
- `uptime-kuma-data` - Monitors
- `opensearch-dashboards-data` - Visualizations

**Naming Convention:**
```
<service-name>-data
<service>-<instance>-data
<service>-<type>-data
```

**Storage Locations:**
```
/var/lib/docker/volumes/
├── gitea-data/_data/
├── postgres-master-data/_data/
├── n8n-data/_data/
└── ...
```

---

## File Structure

### Repository Layout

```
thalemia/
├── apps/                           # Applications
│   ├── vendure-master/             # PIM instance (placeholder)
│   ├── vendure-ecommerce/          # Retail instance (placeholder)
│   ├── storefront-nextjs/          # Next.js storefront
│   ├── storefront-vite/            # Vite storefront
│   └── n8n-workflows/              # n8n workflow definitions
│
├── libs/                           # Shared libraries
│   ├── config/                     # Build configs (ESLint, Jest, TS)
│   ├── shared/                     # Cross-app utilities
│   │   ├── data-access/            # GraphQL queries, API clients
│   │   ├── types/                  # TypeScript interfaces
│   │   ├── ui-components/          # React component library
│   │   └── utils/                  # Helper functions
│   ├── vendure/                    # Vendure extensions
│   │   ├── plugins/                # Custom Vendure plugins
│   │   ├── entities/               # Custom database entities
│   │   └── graphql/                # GraphQL resolvers/schemas
│   └── testing/                    # Test utilities
│       ├── e2e-utils/              # Playwright helpers
│       ├── fixtures/               # Test data
│       └── mocks/                  # Mock services
│
├── infrastructure/                 # Infrastructure as Code
│   ├── ansible/                    # Node provisioning
│   │   ├── inventory/              # hosts.yml (DV01-DV06)
│   │   ├── playbooks/              # Setup playbooks
│   │   └── roles/                  # Reusable roles
│   ├── compose/                    # Docker Compose files
│   │   └── monitoring/             # OpenSearch stack
│   ├── docker/                     # Dockerfiles
│   │   ├── storefronts/
│   │   └── vendure/
│   ├── kubernetes/                 # K3s manifests
│   │   ├── base/
│   │   ├── charts/
│   │   └── overlays/
│   ├── monitoring/                 # Monitoring configs
│   │   ├── grafana/
│   │   ├── prometheus/
│   │   └── opensearch/
│   ├── nginx/                      # Reverse proxy configs
│   │   └── reverse-proxy.conf
│   └── security/                   # Security configs
│       ├── noc/
│       └── soc/
│
├── tools/                          # Utility scripts
│   └── scripts/                    # Automation scripts
│       ├── docker-start.sh
│       ├── reset-databases.sh
│       ├── seed-databases.sh
│       └── migrate-databases.sh
│
├── docs/                           # Documentation
│   ├── architecture/               # System architecture
│   ├── dev-env/                    # Development setup
│   │   ├── gitea-setup.md          # Gitea guide
│   │   ├── reverse-proxy-storefronts.md
│   │   └── front-hosting-local.md
│   ├── guides/                     # How-to guides
│   ├── infra/                      # Infrastructure docs
│   │   ├── index.md                # THIS FILE
│   │   └── volumes-layout.md       # Volume inventory
│   ├── runbooks/                   # Operational procedures
│   ├── security/                   # Security documentation
│   ├── setup/                      # Setup guides
│   └── workflows/                  # Business workflows
│
├── docker-compose.yml              # Main infrastructure
├── docker-compose.dev.yml          # Development extras
├── docker-compose.storefronts.yml  # Frontend stack
├── docker-compose.gitea.yml        # Git hosting
├── docker-compose.monitoring.yml   # Monitoring stack (placeholder)
│
├── nx.json                         # Nx workspace config
├── package.json                    # Monorepo scripts
├── tsconfig.base.json              # TypeScript paths
├── .env.example                    # Environment template
└── CLAUDE.md                       # Developer instructions
```

---

## Deployment Phases

### Current State (Development)

**Status:** Local development environment
**Infrastructure:** Docker Compose on single workstation
**Network:** localhost / LAN access via `/etc/hosts`

**Active Services:**
- PostgreSQL databases
- Redis cache
- OpenSearch + Dashboards (monitoring)
- Prometheus + Grafana
- n8n automation
- Gitea (Git hosting)
- Adminer (database UI)
- Nginx reverse proxy (for storefronts)

**Placeholder Services:**
- Vendure Master (implementation in progress)
- Vendure Ecommerce (implementation in progress)
- Storefronts (TanStack implementation in progress)

### Phase L1: LAN Optimization (Next)

**Goal:** Optimize for local datacenter deployment across DV01-DV06 nodes

**Key Objectives:**
1. **Distributed Deployment**
   - Deploy services across physical nodes (DV02, DV04, DV05, DV06)
   - Implement node-specific Docker Compose files
   - Configure Tailscale VPN for secure node communication

2. **Storage Optimization**
   - Dedicated storage per service type (SSD vs HDD)
   - Implement tiered storage for OpenSearch (hot/warm/cold)
   - Configure volume bind mounts to specific disks

3. **Network Configuration**
   - Static IP assignments per node
   - DNS configuration for `.local` domains
   - Firewall rules for inter-node communication

4. **High Availability**
   - PostgreSQL replication (master-standby)
   - Redis clustering
   - Load balancing for Vendure instances

5. **Backup Automation**
   - Automated daily backups of critical volumes
   - Off-site backup to secondary node
   - Backup verification and restore testing

**Tools:**
- Ansible playbooks for node provisioning
- Tailscale for VPN mesh network
- MinIO for S3-compatible storage
- Prometheus + Grafana for health monitoring

### Phase L2: Production Scaling (Future)

**Goal:** Scale to production workloads with multi-tenancy

**Key Objectives:**
1. **Kubernetes Migration**
   - Migrate from Docker Compose to K3s
   - Implement Helm charts for services
   - Configure Horizontal Pod Autoscaling (HPA)

2. **Multi-Tenancy**
   - Separate Vendure instances per tenant
   - Database-per-tenant isolation
   - Custom domain routing per tenant

3. **Advanced Security**
   - Deploy Wazuh agents on all nodes
   - Implement SIGMA detection rules in OpenSearch
   - Configure Suricata IDS/IPS
   - Enable Falco runtime security

4. **Observability Enhancement**
   - Vector for log aggregation and transformation
   - Redpanda for streaming log buffer
   - Distributed tracing with OpenTelemetry
   - Custom Grafana dashboards per tenant

5. **Disaster Recovery**
   - Geographic replication (if applicable)
   - Automated failover procedures
   - Regular DR testing and validation

6. **CI/CD Pipeline**
   - Gitea Actions or Drone CI
   - Automated testing and deployment
   - GitOps with ArgoCD or Flux

**Infrastructure:**
- K3s cluster (DV02 as master, DV04-DV06 as workers)
- MinIO for object storage (S3-compatible)
- Digital Ocean VPS for public gateway
- Cloudflare for CDN and DDoS protection (optional)

### China Deployment (Parallel Track)

**Goal:** Deploy infrastructure in China with GFW considerations

**Key Adaptations:**
1. **Mirror Configuration**
   - Use Tsinghua/Aliyun mirrors for npm, Docker, etc.
   - Configure `USE_CHINA_MIRRORS=true` in .env

2. **VPN Access**
   - Tailscale for bypassing GFW
   - WireGuard for site-to-site connections

3. **Local CDN**
   - Aliyun CDN for static assets
   - Local Docker registry mirrors

4. **Compliance**
   - ICP filing for public-facing services
   - Data residency compliance (PIPL)

**Ansible Playbooks:**
- `00-china-mirrors.yml` - Configure China-specific mirrors
- `03-tailscale-setup.yml` - VPN for GFW bypass

---

## Quick Start

### Development Environment

**Prerequisites:**
- Docker and Docker Compose installed
- pnpm (Node package manager)
- 8GB+ RAM recommended

**1. Clone repository:**
```bash
git clone https://github.com/Victorbs-01/thalemia.git
cd thalemia
```

**2. Install dependencies:**
```bash
pnpm install
```

**3. Configure environment:**
```bash
cp .env.example .env
# Edit .env with your settings
```

**4. Start infrastructure:**
```bash
# Start core services
docker-compose up -d

# Start Gitea (if needed)
docker-compose -f docker-compose.gitea.yml up -d

# Start storefronts (if needed)
docker-compose -f docker-compose.storefronts.yml up -d
```

**5. Verify services:**
```bash
docker-compose ps
docker-compose logs -f
```

**6. Access services:**
- Vendure Master Admin: http://localhost:3001
- Vendure Ecommerce Admin: http://localhost:3003
- Gitea: http://localhost:3080
- n8n: http://localhost:5678
- Grafana: http://localhost:3010
- OpenSearch Dashboards: http://localhost:5601
- Adminer: http://localhost:8080

### First-Time Setup

**Database initialization:**
```bash
pnpm run db:reset
```

**Vendure setup (sequential for low-RAM machines):**
```bash
# See docs/guides/VENDURE-SETUP.md for detailed guide
pnpm run setup:vendure:master
pnpm run setup:vendure:ecommerce
```

**Development mode:**
```bash
pnpm run dev  # Start all services
```

### Common Commands

```bash
# Start services
pnpm run docker:up

# Stop services
pnpm run docker:down

# View logs
pnpm run docker:logs

# Run tests
pnpm run test

# Build applications
pnpm run build

# Lint code
pnpm run lint
```

---

## Related Documentation

### Essential Reading

**Getting Started:**
- [CLAUDE.md](/CLAUDE.md) - Developer instructions and common commands
- [Vendure Setup Guide](../guides/VENDURE-SETUP.md) - Vendure installation procedures
- [Gitea Setup Guide](../dev-env/gitea-setup.md) - Git hosting configuration

**Infrastructure:**
- [Volumes Layout](./volumes-layout.md) - Volume inventory and backup procedures
- [Reverse Proxy Setup](../dev-env/reverse-proxy-storefronts.md) - Nginx configuration
- [Ansible Inventory](../../infrastructure/ansible/inventory/hosts.yml) - Node assignments

**Architecture:**
- [Architecture Documentation](../architecture/) - System design documents
- [Security Architecture](../security/SOC-NOC-DLP-UEBA-ARCHITECTURE.md) - Security stack
- [Detection Rules](../security/DETECTION-RULES.md) - SIEM threat detection

**Operations:**
- [Runbooks](../runbooks/) - Operational procedures
- [Incident Response Playbooks](../security/INCIDENT-RESPONSE-PLAYBOOKS.md) - Security incidents

**Development:**
- [Testing Strategy](../testing/) - Test documentation
- [MCP Documentation](../mcp/) - Model Context Protocol integrations

### External Resources

- **Nx Documentation**: https://nx.dev
- **Vendure Documentation**: https://docs.vendure.io
- **n8n Documentation**: https://docs.n8n.io
- **Gitea Documentation**: https://docs.gitea.io
- **OpenSearch Documentation**: https://opensearch.org/docs
- **Prometheus Documentation**: https://prometheus.io/docs
- **Ansible Documentation**: https://docs.ansible.com

---

## Maintenance & Support

**Documentation Maintenance:**
- Review cycle: Quarterly
- Last updated: 2025-01-17
- Maintained by: DevOps Team

**Getting Help:**
- Issues: GitHub Issues (https://github.com/Victorbs-01/thalemia/issues)
- Discussions: GitHub Discussions
- Internal: See `docs/runbooks/` for troubleshooting

**Contributing:**
- Follow documentation in `CLAUDE.md`
- Use Nx generators for code scaffolding
- Run tests before committing: `pnpm run test:affected`
- Update documentation when making infrastructure changes

---

**Infrastructure Documentation Index**
**Version:** 1.0
**Last Updated:** 2025-01-17
**Maintained By:** Entrepreneur-OS DevOps Team
