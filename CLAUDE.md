# CLAUDE.md

This file provides guidance to Claude Code when working with code in this repository.

## Project Overview

**Entrepreneur-OS** is a multi-tenant e-commerce and business operations platform built on an Nx monorepo. The architecture features a dual-Vendure setup (master/ecommerce), n8n automation, and comprehensive observability.

**For detailed architecture:** See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)
**For infrastructure & deployment:** See [docs/INFRASTRUCTURE.md](docs/INFRASTRUCTURE.md)
**For troubleshooting:** See [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)

## Common Development Commands

### Development
```bash
pnpm run dev                  # Start all services
pnpm run dev:master           # vendure-master (ports 3000/3001)
pnpm run dev:ecommerce        # vendure-ecommerce (ports 3002/3003)
pnpm run dev:shops            # Both storefronts
```

### Building
```bash
pnpm run build                # Build all
pnpm run build:affected       # Build only affected (recommended)
nx build <project-name>       # Build specific project
```

### Testing
```bash
pnpm run test                 # Run all tests
pnpm run test:affected        # Test affected only (recommended)
pnpm run e2e                  # E2E tests
pnpm run e2e:ui               # Playwright UI mode
```

### Linting & Formatting
```bash
pnpm run lint                 # Lint all
pnpm run lint:fix             # Auto-fix issues
pnpm run format               # Format code
```

### Docker Operations
```bash
pnpm run docker:up            # Start containers
pnpm run docker:down          # Stop and remove
pnpm run docker:restart       # Restart all
pnpm run docker:logs          # View logs
pnpm run docker:rebuild       # Force rebuild
```

### Database Operations
```bash
pnpm run db:reset             # Reset databases
pnpm run db:seed              # Seed databases
pnpm run db:migrate           # Run migrations
```

### Nx Utilities
```bash
pnpm run graph                # Visualize dependencies
pnpm run affected:graph       # Show affected projects
pnpm run reset                # Clear Nx cache
```

## Architecture Overview

### Dual-Vendure Pattern

This project implements a **master/ecommerce separation** pattern:

- **vendure-master** (ports 3000/3001): Product Information Management (PIM) system. Single source of truth for catalogs, suppliers, pricing.
- **vendure-ecommerce** (ports 3002/3003): Retail operations handling orders, inventory, customer transactions.

**Data Flow:**
```
vendure-master (PIM)
    ↓ (n8n sync)
vendure-ecommerce (Orders/Inventory)
    ↓
Storefronts (Next.js/Vite)
```

**Benefits:**
- Independent scaling (catalog vs. retail)
- Tenant isolation at database level
- Clear separation of concerns

**For detailed architecture:** See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)

### Database Architecture

```
postgres-master (port 5432)     → vendure_master database
postgres-ecommerce (port 5433)  → vendure_ecommerce database
redis (port 6379)               → Shared cache
```

## Monorepo Structure

### Import Namespace

All libraries use the `@entrepreneur-os` namespace:

```typescript
// Shared utilities
import { Button } from '@entrepreneur-os/shared/ui-components';
import { useProducts } from '@entrepreneur-os/shared/data-access';
import { Product, Order } from '@entrepreneur-os/shared/types';

// Vendure extensions
import { MultiTenantPlugin } from '@entrepreneur-os/vendure/plugins';
import { TenantEntity } from '@entrepreneur-os/vendure/entities';

// Testing
import { createTestProduct } from '@entrepreneur-os/testing/fixtures';
```

### Library Organization

- **libs/config/**: Build configuration (ESLint, Jest, TypeScript)
- **libs/shared/**: Cross-application code
  - `data-access/`: GraphQL queries, API clients
  - `types/`: TypeScript interfaces
  - `ui-components/`: React components
  - `utils/`: Helper functions
- **libs/vendure/**: Vendure-specific extensions
  - `plugins/`: Custom plugins (multi-tenancy, payments)
  - `entities/`: Custom database entities
  - `graphql/`: Custom resolvers and schemas
- **libs/testing/**: Test infrastructure (fixtures, mocks, e2e-utils)

## Development Workflow

### Adding a New Feature

1. **Determine location:**
   - Reusable across apps → `libs/shared/`
   - Vendure-specific → `libs/vendure/`
   - App-specific → Directly in app

2. **Use Nx generators:**
   ```bash
   nx generate @nx/js:library libs/shared/new-feature
   nx generate @nx/react:component MyComponent --project=ui-components
   ```

3. **Update tsconfig paths** (if new library):
   ```json
   "@entrepreneur-os/shared/new-feature": ["libs/shared/new-feature/src/index.ts"]
   ```

4. **Run affected tests:**
   ```bash
   pnpm run test:affected
   pnpm run build:affected
   ```

### Working with Vendure

Vendure instances are in active development. When adding code:

1. **Custom plugins** → `libs/vendure/plugins/src/`
2. **Custom entities** → `libs/vendure/entities/src/`
3. **GraphQL extensions** → `libs/vendure/graphql/src/`
4. **Consider master vs. ecommerce** - which instance owns the functionality?
5. **Use n8n workflows** (`apps/n8n-workflows/`) for cross-instance sync

### Database Migrations

```bash
# Generate migration
nx run vendure-master:migration:generate --name=AddNewField
nx run vendure-ecommerce:migration:generate --name=AddNewField

# Review and run
pnpm run db:migrate
```

## Nx Best Practices

- **Always use affected commands** when possible: `pnpm run test:affected`, `pnpm run build:affected`
- **Check affected projects** before making changes: `nx affected:graph`
- **Use workspace boundaries** - never use relative imports across workspace boundaries
- **Leverage Nx cache** - builds are cached in `.nx/cache/`, clear with `pnpm run reset`
- **Parallel execution** - configured to 3 concurrent tasks (see `nx.json`)

## Important Files

| Path                         | Purpose                                    |
| ---------------------------- | ------------------------------------------ |
| `nx.json`                    | Nx workspace config, caching, plugins      |
| `package.json`               | Monorepo scripts and commands              |
| `tsconfig.base.json`         | TypeScript path mappings                   |
| `docker-compose.yml`         | All Docker services                        |
| `.env.example`               | Environment variable template              |
| `tools/scripts/`             | Utility scripts (DB, Docker)               |
| `docs/ARCHITECTURE.md`       | Detailed system architecture               |
| `docs/INFRASTRUCTURE.md`     | Infrastructure & deployment                |
| `docs/TROUBLESHOOTING.md`    | Common issues and solutions                |

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
- **Project Documentation**: See `docs/` directory
