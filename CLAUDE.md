# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Entrepreneur-OS** is a multi-tenant e-commerce and business operations platform built on an Nx monorepo. The architecture features a dual-Vendure setup (master/ecommerce), n8n automation, comprehensive observability (HELK/OpenSearch stack), and enterprise security (SOC/SIEM).

## Common Development Commands

### Development

```bash
# Start all services in development mode
pnpm run dev

# Start specific Vendure instances
pnpm run dev:vendure          # Both vendure-master and vendure-ecommerce
pnpm run dev:master           # vendure-master only (port 3000/3001)
pnpm run dev:ecommerce        # vendure-ecommerce only (port 3002/3003)

# Start storefronts
pnpm run dev:shops            # Both Next.js and Vite storefronts
pnpm run dev:next             # Next.js storefront only
pnpm run dev:vite             # Vite storefront only
```

### Building

```bash
# Build all applications
pnpm run build

# Build only affected applications (based on git changes)
pnpm run build:affected

# Build specific project
nx build vendure-master
```

### Testing

```bash
# Run all tests
pnpm run test

# Run tests for affected projects only
pnpm run test:affected

# Run tests in watch mode
pnpm run test:watch

# Run a single test file
nx test <project-name> --testFile=<path-to-test>

# E2E tests
pnpm run e2e
pnpm run e2e:ui               # Playwright UI mode
```

### Linting & Formatting

```bash
# Lint all projects
pnpm run lint

# Auto-fix lint issues
pnpm run lint:fix

# Format code
pnpm run format

# Check formatting
pnpm run format:check
```

### Docker Operations

```bash
# Start Docker infrastructure
pnpm run docker:start         # Uses tools/scripts/docker-start.sh
pnpm run docker:up            # Start all containers

# Container management
pnpm run docker:down          # Stop and remove containers
pnpm run docker:stop          # Stop containers (preserve state)
pnpm run docker:restart       # Restart all containers
pnpm run docker:logs          # Follow logs
pnpm run docker:ps            # List running containers

# Maintenance
pnpm run docker:clean         # Remove containers and volumes
pnpm run docker:rebuild       # Force rebuild all containers
pnpm run docker:db:reset      # Reset PostgreSQL databases
```

### Database Operations

```bash
# Database management scripts (in tools/scripts/)
pnpm run db:reset             # Reset databases (uses reset-databases.sh)
pnpm run db:seed              # Seed databases (uses seed-databases.sh)
pnpm run db:migrate           # Run migrations (uses migrate-databases.sh)
bash tools/scripts/init-databases.sh   # Initialize databases
```

### Nx Utilities

```bash
# Visualize project dependencies
pnpm run graph
pnpm run affected:graph

# Clear Nx cache
pnpm run reset

# Clean everything (Nx + Docker)
pnpm run clean
```

### Generators

```bash
# Generate new code
pnpm run generate             # Interactive generator menu

# Specific generators
pnpm run g:lib                # Create new library
pnpm run g:app                # Create new application
pnpm run g:component          # Create new React component

# Direct Nx generators
nx generate @nx/js:library <name>
nx generate @nx/node:application <name>
nx generate @nx/react:component <name>
```

## Architecture Overview

### Dual-Vendure Pattern

This project implements a **master/ecommerce separation** pattern:

- **vendure-master** (ports 3000/3001): Central product information management (PIM) system. Single source of truth for product catalogs, suppliers, and pricing.
- **vendure-ecommerce** (ports 3002/3003): Retail operations instance handling orders, inventory, and customer transactions. Can be horizontally scaled.

**Data Flow:**

```
Product Master (vendure-master)
    ↓ (n8n sync workflows)
Ecommerce Instance (vendure-ecommerce)
    ↓
Storefronts (Next.js / Vite)
```

This separation enables:

- Independent scaling of catalog vs. retail operations
- Tenant isolation at the database level
- Clear separation of concerns (PIM vs. order fulfillment)

### Multi-Tenancy Strategy

Multi-tenancy is implemented via:

- Separate PostgreSQL databases per Vendure instance
- Custom Vendure plugins in `libs/vendure/plugins/`
- n8n workflows for cross-instance data synchronization
- Custom entity fields and GraphQL context middleware

### Database Architecture

```
postgres-master (port 5432)
├── vendure_master database
└── Product catalog, PIM data

postgres-ecommerce (port 5433)
├── vendure_ecommerce database
└── Orders, inventory, customers

redis (port 6379)
└── Shared cache layer
```

### Infrastructure Components

The platform runs on distributed infrastructure (DV01-DV06 nodes):

- **DV02**: vendure-master, postgres-master, redis, K3s master
- **DV04**: vendure-ecommerce, postgres-ecommerce, n8n, storefronts
- **DV05**: OpenSearch cluster (hot tier), Prometheus, Grafana, Wazuh
- **DV06**: OpenSearch (warm tier), Vector, Redpanda, Uptime Kuma
- **Digital Ocean VPS**: Public gateway (Nginx, WireGuard, SSL)

See `infrastructure/ansible/inventory/hosts.yml` for complete node assignments.

## Monorepo Structure

### Shared Libraries (libs/)

Import paths use the `@entrepreneur-os` namespace:

```typescript
// Shared UI components (React)
import { Button, Form } from '@entrepreneur-os/shared/ui-components';

// API client and GraphQL queries
import { useProducts } from '@entrepreneur-os/shared/data-access';

// TypeScript types and interfaces
import { Product, Order } from '@entrepreneur-os/shared/types';

// Utility functions
import { formatPrice, validateEmail } from '@entrepreneur-os/shared/utils';

// Vendure-specific extensions
import { MultiTenantPlugin } from '@entrepreneur-os/vendure/plugins';
import { TenantEntity } from '@entrepreneur-os/vendure/entities';
import { customResolvers } from '@entrepreneur-os/vendure/graphql';

// Testing utilities
import { createTestProduct } from '@entrepreneur-os/testing/fixtures';
import { mockVendureClient } from '@entrepreneur-os/testing/mocks';
import { setupE2E } from '@entrepreneur-os/testing/e2e-utils';
```

### Library Organization

- **libs/config/**: Shared build and tooling configuration (ESLint, Jest, TypeScript)
- **libs/shared/**: Cross-application utilities and components
  - `data-access/`: GraphQL queries, mutations, API clients
  - `types/`: TypeScript interfaces and enums
  - `ui-components/`: Shared React component library
  - `utils/`: Helper functions (formatting, validation, dates)
- **libs/vendure/**: Vendure-specific extensions
  - `plugins/`: Custom Vendure plugins (multi-tenancy, payments, fulfillment)
  - `entities/`: Custom database entities
  - `graphql/`: Custom GraphQL resolvers and schemas
- **libs/testing/**: Testing infrastructure
  - `e2e-utils/`: Playwright helpers
  - `fixtures/`: Test data and seeding
  - `mocks/`: Mock services

## Development Workflow

### Adding a New Feature

1. **Check if code belongs in a shared library:**
   - If reusable across apps → create/update in `libs/shared/`
   - If Vendure-specific → add to `libs/vendure/`
   - If app-specific → implement directly in app

2. **Use Nx generators for consistency:**

   ```bash
   nx generate @nx/js:library libs/shared/new-feature
   nx generate @nx/react:component MyComponent --project=ui-components
   ```

3. **Update tsconfig.base.json paths if creating new library:**

   ```json
   "@entrepreneur-os/shared/new-feature": [
     "libs/shared/new-feature/src/index.ts"
   ]
   ```

4. **Run affected tests:**
   ```bash
   pnpm run test:affected
   pnpm run build:affected
   ```

### Working with Vendure

The Vendure instances are **placeholders** - implementations are in development. When adding Vendure code:

1. **Custom plugins** go in `libs/vendure/plugins/src/`
2. **Custom entities** go in `libs/vendure/entities/src/`
3. **GraphQL extensions** go in `libs/vendure/graphql/src/`
4. Reference the master/ecommerce separation - consider which instance owns the functionality
5. Use n8n workflows (in `apps/n8n-workflows/`) for cross-instance data sync

### Database Migrations

When making schema changes:

1. Update entity definitions in `libs/vendure/entities/`
2. Generate migration:

   ```bash
   # For master instance
   nx run vendure-master:migration:generate --name=AddNewField

   # For ecommerce instance
   nx run vendure-ecommerce:migration:generate --name=AddNewField
   ```

3. Review generated migration files
4. Run migrations: `pnpm run db:migrate`

### Working with Docker

The `docker-compose.yml` defines all services. Key services:

- **postgres-master/postgres-ecommerce**: Vendure databases
- **redis**: Shared cache
- **adminer**: Database UI (http://localhost:8080)
- **n8n**: Automation workflows (http://localhost:5678)

To modify infrastructure:

1. Update `docker-compose.yml`
2. Rebuild: `pnpm run docker:rebuild`
3. For persistent changes, also update `infrastructure/compose/` YAML files

### n8n Workflow Development

Workflows are stored in `apps/n8n-workflows/workflows/`:

1. Create workflows via n8n UI (http://localhost:5678)
2. Export workflows to JSON
3. Save in `apps/n8n-workflows/workflows/`
4. Credentials go in `apps/n8n-workflows/credentials/` (encrypted)
5. Key workflows to implement:
   - Product sync: master → ecommerce
   - Order processing: ecommerce → ERPNext/CRM
   - Inventory updates

## China Deployment

The platform includes special support for China deployment:

### Environment Variables

```bash
# Enable China mirrors
USE_CHINA_MIRRORS=true
CHINA_MIRROR_URL=https://mirrors.tuna.tsinghua.edu.cn
NPM_REGISTRY=https://registry.npmmirror.com
```

### Ansible Playbooks

```bash
# Infrastructure setup for China (in infrastructure/ansible/playbooks/)
ansible-playbook 00-china-mirrors.yml
ansible-playbook 03-tailscale-setup.yml  # VPN for GFW bypass
```

### Docker Registry Mirrors

Configured in `infrastructure/ansible/roles/docker/` for Aliyun registry access.

## Security & Monitoring

### SIEM/SOC Stack

The platform includes comprehensive security monitoring:

- **Wazuh**: Security event monitoring and incident detection
- **OpenSearch**: SIEM data lake with SIGMA rules
- **Suricata**: Network IDS/IPS
- **Falco**: Kubernetes runtime security
- **Wazuh agents**: Deployed on all compute nodes

See `docs/security/` for:

- `SOC-NOC-DLP-UEBA-ARCHITECTURE.md`: Security automation
- `DETECTION-RULES.md`: Threat detection rules
- `INCIDENT-RESPONSE-PLAYBOOKS.md`: Response procedures

### Observability Stack

Monitoring architecture (HELK/OpenSearch):

- **Prometheus** (port 9090): Metrics collection
- **Grafana** (port 3010): Visualization and alerting
- **OpenSearch** (port 9200): Log aggregation and search
- **OpenSearch Dashboards** (port 5601): Security dashboards
- **Vector**: Log processing and routing
- **Redpanda**: Streaming buffer (Kafka alternative)

### Index Lifecycle Management

OpenSearch implements tiered storage:

- **Hot tier** (SSD, 7 days): DV05 - fast queries
- **Warm tier** (HDD, 30 days): DV06 - cost-effective
- **Cold tier** (S3, 90 days): MinIO archival
- **Delete**: After 180 days

## Important Files & Directories

| Path                         | Purpose                                               |
| ---------------------------- | ----------------------------------------------------- |
| `nx.json`                    | Nx workspace configuration, caching, plugins          |
| `package.json`               | Monorepo scripts and development commands             |
| `tsconfig.base.json`         | TypeScript path mappings for @entrepreneur-os imports |
| `docker-compose.yml`         | All Docker services definitions                       |
| `.env.example`               | Complete environment variable template                |
| `tools/scripts/`             | Utility scripts (setup, database, Docker)             |
| `infrastructure/ansible/`    | Infrastructure as Code, node provisioning             |
| `infrastructure/compose/`    | Service-specific Docker Compose files                 |
| `infrastructure/kubernetes/` | K3s manifests for production deployment               |
| `docs/architecture/`         | System architecture documentation                     |
| `docs/security/`             | Security policies and procedures                      |
| `apps/n8n-workflows/`        | Business process automation definitions               |

## Nx Cache & Performance

- Nx caches build outputs in `.nx/cache/`
- Only affected projects rebuild when dependencies change
- Use `pnpm run affected:graph` to visualize affected projects
- Clear cache with `pnpm run reset` if encountering stale build issues
- Parallel execution configured to 3 concurrent tasks (see `nx.json`)

## Testing Strategy

- **Unit tests**: Jest with Vitest for React libraries
- **E2E tests**: Playwright (run with `pnpm run e2e:ui`)
- **Test utilities**: Shared fixtures and mocks in `libs/testing/`
- **Coverage**: Nx tracks test coverage per project

## Troubleshooting

### Port Conflicts

If services fail to start due to port conflicts:

- Vendure Master: 3000 (API), 3001 (Admin)
- Vendure Ecommerce: 3002 (API), 3003 (Admin)
- PostgreSQL Master: 5432
- PostgreSQL Ecommerce: 5433
- Redis: 6379
- n8n: 5678
- Adminer: 8080

### Database Issues

```bash
# Reset databases
pnpm run db:reset

# Reset Docker volumes
pnpm run docker:db:reset

# Check database connectivity
docker exec -it postgres-master psql -U vendure -d vendure_master
docker exec -it postgres-ecommerce psql -U vendure -d vendure_ecommerce
```

### Docker Issues

```bash
# Clean rebuild
pnpm run docker:clean
pnpm run docker:rebuild

# Check container logs
pnpm run docker:logs

# Check container status
pnpm run docker:ps
```

### Nx Cache Issues

```bash
# Clear Nx cache
pnpm run reset

# Run without cache
nx run-many -t build --all --skip-nx-cache
```

## Environment Setup

1. **Initial setup:**

   ```bash
   pnpm install
   cp .env.example .env
   # Edit .env with your configuration
   ```

2. **Start infrastructure:**

   ```bash
   pnpm run docker:up
   pnpm run db:reset
   ```

3. **Start development:**

   ```bash
   pnpm run dev
   ```

4. **Access services:**
   - Vendure Master Admin: http://localhost:3001
   - Vendure Ecommerce Admin: http://localhost:3003
   - n8n: http://localhost:5678
   - Adminer (DB UI): http://localhost:8080

## Additional Resources

- **Nx Documentation**: https://nx.dev
- **Vendure Documentation**: https://docs.vendure.io
- **n8n Documentation**: https://docs.n8n.io
- **Project Documentation**: See `docs/` directory for architecture, runbooks, and guides
- **Infrastructure Inventory**: `infrastructure/ansible/inventory/hosts.yml`
