# Entrepreneur-OS

> **A Self-Hosted E-Commerce & Business Operations Platform for Entrepreneurs**

[![Implementation Status](https://img.shields.io/badge/Implementation-30%25-yellow)](docs/IMPLEMENTATION_STATUS.md)
[![Infrastructure](https://img.shields.io/badge/Infrastructure-Ready-green)](docker-compose.yml)
[![Applications](https://img.shields.io/badge/Applications-In%20Development-orange)](apps/)
[![Documentation](https://img.shields.io/badge/Documentation-Comprehensive-blue)](docs/)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

---

## =� Table of Contents

**For Everyone:**

- [What is Entrepreneur-OS?](#-what-is-entrepreneur-os)
- [Current Status](#-current-status)

**For Founders & Business Users:**

- [What Can You Do With It?](#-what-can-you-do-with-it)
- [Self-Hosted vs. SaaS](#-self-hosted-vs-saas)
- [Is This Right for You?](#-is-this-right-for-you)

**For Developers:**

- [Quick Start](#-quick-start)
- [Architecture Overview](#-architecture-overview)
- [Project Structure](#-project-structure)
- [Development Workflow](#-development-workflow)

**For Operations/DevOps:**

- [Infrastructure & Deployment](#-infrastructure--deployment)
- [Security & Monitoring](#-security--monitoring)
- [Troubleshooting](#-troubleshooting)

**For Contributors:**

- [Roadmap](#-roadmap)
- [Contributing](#-contributing)
- [Documentation](#-documentation)

---

## <� What is Entrepreneur-OS?

Entrepreneur-OS is a complete, self-hosted business operations platform designed for entrepreneurs running e-commerce businesses, particularly those working with international suppliers and selling globally.

### The Problem We Solve

If you're an entrepreneur who needs to:

- Manage product catalogs from multiple suppliers (especially China-based)
- Run one or more online stores selling to different markets
- Automate repetitive business processes (product syncing, order processing, notifications)
- Have professional security monitoring (not typical for small businesses)
- Keep costs low while scaling operations

...you're probably juggling 10+ different SaaS subscriptions (Shopify, Zapier, inventory management, analytics, CRM, etc.), paying $500-2000/month, with data scattered across platforms that don't talk to each other.

### Our Solution

A unified, self-hosted platform that combines:

- **Product Information Management (PIM)** - Central system for all product data
- **Multi-Store E-Commerce** - Run multiple storefronts from one backend
- **Business Automation** - Visual workflow builder (n8n) for process automation
- **Enterprise Security** - SOC/SIEM monitoring normally found in Fortune 500 companies
- **Complete Ownership** - Your hardware, your data, your control

### Real-World Use Case

You're sourcing products from Alibaba/1688, managing inventory across warehouses, selling through your own website plus marketplaces, processing orders, and tracking everything with business intelligence - all from **one integrated platform** instead of paying for 10+ separate SaaS tools.

---

## =� Current Status

**� IMPORTANT: This project is in active development (30% complete)**

### What's Working 

- **Infrastructure**: Docker Compose with all services configured (PostgreSQL, Redis, n8n, OpenSearch, Grafana, Prometheus)
- **Development Environment**: Full monorepo setup with Nx, TypeScript, ESLint, Prettier
- **Quality Gates**: Pre-commit hooks, CI/CD pipeline, automated testing framework
- **Documentation**: Comprehensive architecture, security, and setup guides
- **Project Structure**: Complete monorepo organization with proper import paths

### What's In Development =�

- **Core Applications**: Directory structure exists, but no application code yet
  - vendure-master (PIM)
  - vendure-ecommerce
  - Storefronts (Next.js, Vite)
- **Shared Libraries**: Framework ready, but libraries are empty
- **Tests**: Jest and Playwright configured, but no test files exist
- **n8n Workflows**: Infrastructure ready, no workflows created

### What You Can Do Today

1.  Clone the repository and explore the architecture
2.  Start all Docker services (databases, monitoring, automation tools)
3.  Review comprehensive documentation
4.  Set up your development environment
5.  Contribute to building the applications

### What You Cannot Do Yet

- L Run actual e-commerce operations (applications not implemented)
- L Process real orders (no order management code)
- L Use automated workflows (no n8n workflows created)
- L Deploy to production (apps not ready)

**See [docs/IMPLEMENTATION_STATUS.md](docs/IMPLEMENTATION_STATUS.md) for detailed tracking.**

---

## =� What Can You Do With It?

Once fully implemented, Entrepreneur-OS will enable you to:

### 1. Centralized Product Management

- Maintain a single source of truth for all product information
- Manage suppliers, pricing, specifications, and inventory
- Update product data once, sync to multiple stores automatically
- Handle complex product variants and bundling

### 2. Multi-Store Operations

- Run multiple branded storefronts from one backend
- Serve different markets (regions, languages, currencies)
- Manage separate inventory pools per store
- Scale independently (PIM vs. retail operations)

### 3. Business Process Automation

- Visual workflow builder (n8n) - no coding required for many tasks
- Examples:
  - Product sync: Master � Ecommerce stores (scheduled or triggered)
  - Order processing: Order placed � ERP � Email � Warehouse notification
  - Inventory alerts: Low stock � Purchase order � Supplier notification
  - Customer service: Question � CRM � Auto-response or escalation

### 4. Enterprise-Grade Security Monitoring

- Real-time threat detection (intrusion attempts, unusual behavior)
- Security event logging and analysis (SIEM)
- User behavior analytics (detect compromised accounts)
- Data loss prevention (protect sensitive information)
- Compliance reporting (GDPR, PCI-DSS ready)

### 5. Business Intelligence

- Unified dashboards (Grafana) for all metrics
- Custom reports and visualizations
- Real-time monitoring of sales, inventory, systems
- Historical data analysis

---

## =� Self-Hosted vs. SaaS

### Typical SaaS Stack Costs

For a growing e-commerce business, you might be paying:

| Service                  | Monthly Cost     |
| ------------------------ | ---------------- |
| Shopify Plus             | $2,000           |
| Inventory Management     | $300             |
| Zapier Professional      | $250             |
| CRM (HubSpot/Salesforce) | $500             |
| Analytics (Mixpanel)     | $200             |
| Email Marketing          | $150             |
| Customer Support         | $100             |
| **Total**                | **$3,500/month** |
| **Annual**               | **$42,000/year** |

### Entrepreneur-OS Approach

**Initial Investment:**

- Hardware: $2,000-5,000 (one-time, you own it)
- Time: 2-4 weeks setup (decreases as project matures)

**Monthly Costs:**

- Electricity: ~$50
- Domain & SSL: ~$20
- Backup storage: ~$10
- **Total: ~$80/month**

**Payback Period:** 2-4 months vs. SaaS costs

**Trade-offs:**

-  Own your data
-  No per-user fees
-  Customize everything
-  No vendor lock-in
- L Requires technical knowledge or team
- L You manage updates and security
- L Initial time investment

---

## > Is This Right for You?

###  Use Entrepreneur-OS If:

- You're comfortable with technology or have technical team members
- You value data ownership and privacy
- You're growing beyond basic e-commerce ($50k+/month revenue)
- You need extensive automation and integrations
- You want enterprise features without enterprise costs
- You're dealing with suppliers in China or complex international operations
- You're building a marketplace or multi-vendor platform

### L Use Shopify/BigCommerce Instead If:

- You're just starting (< $10k/month revenue)
- You need to launch ASAP (this week)
- You have zero technical knowledge and no budget for help
- You don't want to manage infrastructure
- You need extensive app marketplace (Shopify has 8,000+ apps)

### =� Consider Both If:

- Start with Shopify to validate your business model
- Once you hit $50-100k/month, evaluate migration to Entrepreneur-OS
- Use this as a learning project while keeping Shopify for revenue

---

## =� Quick Start

### Prerequisites

**Required Software:**

- [Node.js](https://nodejs.org/) v20 or higher
- [pnpm](https://pnpm.io/) v8 or higher (`npm install -g pnpm`)
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (latest version)
- [Git](https://git-scm.com/)

**Recommended:**

- [VS Code](https://code.visualstudio.com/) with recommended extensions (defined in `.vscode/extensions.json`)

**System Requirements:**

- **CPU**: 4+ cores
- **RAM**: 16GB minimum (32GB recommended)
- **Disk**: 100GB SSD available

### Installation Steps

#### 1. Clone the Repository

```bash
git clone https://github.com/Victorbs-01/thalemia.git entrepreneur-os
cd entrepreneur-os
```

#### 2. Install Dependencies

```bash
pnpm install
```

This installs all Node.js packages and sets up the monorepo.

#### 3. Configure Environment Variables

```bash
cp .env.example .env
```

Edit `.env` and configure:

- Database passwords (secure values, not defaults!)
- Redis password
- Time zone
- Node environment

**� Security Note:** Change all default passwords before deployment!

#### 4. Start Docker Infrastructure

```bash
pnpm run docker:up
```

This starts all services:

- PostgreSQL (master & ecommerce instances)
- Redis (caching)
- OpenSearch (logs & security)
- OpenSearch Dashboards (visualization)
- Prometheus (metrics)
- Grafana (dashboards)
- n8n (workflow automation)
- Uptime Kuma (monitoring)
- Adminer (database UI)

Wait 2-3 minutes for all services to initialize.

#### 5. Verify Services Are Running

```bash
pnpm run docker:ps
```

All services should show "Up" status.

#### 6. Access Services

Open your browser and visit:

| Service               | URL                   | Credentials                |
| --------------------- | --------------------- | -------------------------- |
| n8n (Workflows)       | http://localhost:5678 | admin / admin              |
| Grafana (Dashboards)  | http://localhost:3010 | admin / admin              |
| OpenSearch Dashboards | http://localhost:5601 | -                          |
| Adminer (Database)    | http://localhost:8080 | postgres / [your password] |
| Prometheus            | http://localhost:9090 | -                          |
| Uptime Kuma           | http://localhost:3011 | (setup on first access)    |

### Current Limitations

**Applications are not yet implemented:**

- Vendure Master: Not accessible (no code)
- Vendure Ecommerce: Not accessible (no code)
- Storefronts: Not accessible (no code)

**What works:**

- All infrastructure services
- Development tooling
- Documentation

**Next steps for contributors:**
See [Roadmap](#-roadmap) for development priorities.

---

## <� Architecture Overview

### Technology Stack

#### Frontend

- **Frameworks**: Next.js (SEO-optimized), Vite (fast development)
- **UI Library**: React 18+
- **Language**: TypeScript (strict mode)
- **Styling**: TBD (Tailwind CSS likely)
- **State Management**: TBD (Zustand/Redux Toolkit likely)

#### Backend

- **E-Commerce Engine**: [Vendure](https://vendure.io) (headless, GraphQL-first)
- **Runtime**: Node.js 20+
- **Language**: TypeScript (strict mode)
- **API**: GraphQL (Vendure built-in) + REST where needed
- **Authentication**: Vendure Auth + JWT

#### Databases

- **Primary**: PostgreSQL 16 (dual instances)
  - `postgres-master` (port 5432): Product catalog, PIM data
  - `postgres-ecommerce` (port 5433): Orders, customers, inventory
- **Cache**: Redis 7 (port 6379)
- **Search**: OpenSearch 2.x (full-text search + security logs)

#### Automation

- **Workflow Engine**: [n8n](https://n8n.io) (self-hosted automation)
- **Use Cases**:
  - Product sync (master � ecommerce)
  - Order processing automation
  - Inventory management
  - Customer notifications
  - Supplier communications

#### Monitoring & Security (Enterprise-Grade)

- **SIEM**: OpenSearch + Wazuh (security event management)
- **IDS/IPS**: Suricata (network intrusion detection)
- **Metrics**: Prometheus + Grafana (system & business metrics)
- **Logs**: Vector (log processing and routing)
- **Uptime**: Uptime Kuma (service monitoring)
- **UEBA**: OpenUBA (user behavior analytics)
- **Container Security**: Falco (Kubernetes runtime security)

#### Infrastructure

- **Development**: Docker Compose
- **Production**: K3s (lightweight Kubernetes)
- **IaC**: Ansible (server provisioning)
- **Networking**: Tailscale VPN (mesh networking, China-friendly)
- **Gateway**: Nginx (reverse proxy, SSL termination)
- **Secret Management**: Bitwarden (planned)

#### Development Tools

- **Monorepo**: [Nx](https://nx.dev) (build system, dev tools)
- **Package Manager**: pnpm (fast, disk-efficient)
- **Linting**: ESLint (strict rules, error-level)
- **Formatting**: Prettier (automatic)
- **Testing**: Jest (unit), Playwright (E2E)
- **Git Hooks**: Husky + lint-staged (pre-commit quality gates)
- **Commits**: Commitlint (conventional commits)
- **CI/CD**: GitHub Actions (automated testing, builds)

### Dual-Vendure Architecture Pattern

**Why Two Vendure Instances?**

Most e-commerce platforms combine product catalog and order management in one system. We separate them for scalability and operational efficiency.

#### vendure-master (Product Information Management)

- **Port**: 3000 (API), 3001 (Admin UI)
- **Purpose**: Single source of truth for ALL product data
- **Responsibilities**:
  - Product catalog management
  - Supplier relationships
  - Pricing and cost management
  - Product specifications and variants
  - Media assets (images, videos)
- **Update Frequency**: Infrequent (products don't change often)
- **Scaling**: Vertical (bigger database, more storage)

#### vendure-ecommerce (Retail Operations)

- **Port**: 3002 (API), 3003 (Admin UI)
- **Purpose**: Customer-facing operations
- **Responsibilities**:
  - Order processing
  - Inventory management (real-time)
  - Customer accounts
  - Shopping cart and checkout
  - Payment processing
- **Update Frequency**: High (orders/inventory change constantly)
- **Scaling**: Horizontal (add more instances for more traffic)

#### Data Flow

```
1. Admin updates product in vendure-master (Admin UI)
      �
2. n8n detects change (webhook or scheduled sync)
      �
3. n8n workflow syncs product � vendure-ecommerce
      �
4. Product appears in storefronts (Next.js/Vite query ecommerce API)
      �
5. Customer places order in storefront
      �
6. Order created in vendure-ecommerce only
      �
7. n8n processes order � ERP, emails, warehouse, etc.
```

**Benefits:**

- **Independent Scaling**: Scale order processing without affecting product catalog
- **Multi-Tenancy**: Multiple ecommerce instances can share one master catalog
- **Performance**: Product catalog (heavy) separate from order processing (fast)
- **Data Isolation**: Tenant A's orders never touch Tenant B's database

### Monorepo Architecture (Nx)

**What is a Monorepo?**

All code (apps, libraries, tools) lives in one Git repository instead of many separate repos.

**Why Monorepo?**

 **Code Sharing**: Create shared UI components, use them in all storefronts
 **Atomic Changes**: Update API and frontend in single commit, deploy together
 **Affected Detection**: Nx knows which projects changed, only rebuilds/tests those
 **Consistent Tooling**: Same ESLint, TypeScript, test configs everywhere
 **Dependency Management**: One package.json, no version conflicts

**How It Works:**

```
apps/
  vendure-master/      � Deployable application
  vendure-ecommerce/   � Deployable application
  storefront-nextjs/   � Deployable application

libs/
  shared/ui-components/  � Shared library (imported by storefronts)
  shared/data-access/    � Shared library (API queries)
  vendure/plugins/       � Shared library (Vendure extensions)
```

**TypeScript Import Example:**

```typescript
// In storefront-nextjs/src/components/ProductCard.tsx
import { Button, Card } from '@entrepreneur-os/shared/ui-components';
import { useProduct } from '@entrepreneur-os/shared/data-access';
import { Product } from '@entrepreneur-os/shared/types';
```

### n8n Workflow Automation

**What is n8n?**

Visual workflow builder (like Zapier or Make.com) but self-hosted. No coding required for most tasks.

**Example Workflows:**

**Product Sync (Master � Ecommerce):**

```
Trigger: Scheduled (every hour) or Webhook (on product save)
  �
Query: Get all products updated in last hour (vendure-master GraphQL)
  �
Loop: For each product
  �
Check: Does product exist in vendure-ecommerce?
    Yes � Update product
    No � Create new product
  �
Notify: Send Slack message "Synced 47 products"
```

**Order Processing:**

```
Trigger: Webhook (new order in vendure-ecommerce)
  �
Branch:
    Send email confirmation to customer
    Create task in CRM (Twenty)
    Add to fulfillment queue (ERP)
    Post to warehouse management system
  �
Update: Mark order as "processing"
```

**Inventory Alert:**

```
Trigger: Scheduled (every 4 hours)
  �
Query: Get all products with inventory < reorder point
  �
Loop: For each low-stock product
  �
Check: Is supplier available?
    Yes � Create purchase order draft
    No � Alert purchasing team
  �
Notify: Email report of low-stock items
```

### HELK/OpenSearch Security Stack

**What is HELK?**

**H**unting **E**LK (**L**asticsearch, **L**ogstash, **K**ibana) adapted with OpenSearch for security monitoring. Enterprise-grade threat detection for small businesses.

**Why Do Small Businesses Need This?**

Most small businesses get hacked and don't know it for months. This gives you Fortune 500 security:

**Components:**

1. **OpenSearch** (replaces Elasticsearch)
   - Stores all logs (application, system, security, network)
   - Fast full-text search across millions of events
   - Security event correlation

2. **Wazuh** (Security Event Manager)
   - Monitors all servers for suspicious activity
   - File integrity monitoring (detects unauthorized changes)
   - Vulnerability detection (finds unpatched software)
   - Compliance auditing (PCI-DSS, GDPR, HIPAA)

3. **Suricata** (Network IDS/IPS)
   - Inspects all network traffic for attack signatures
   - Detects SQL injection, XSS, brute force, malware
   - Can block attacks in real-time (IPS mode)

4. **Falco** (Kubernetes Runtime Security)
   - Detects unexpected behavior in containers
   - Alerts on privilege escalation, unexpected network connections
   - Protects against container breakout attacks

5. **UEBA (User Behavior Analytics)**
   - Learns normal user patterns
   - Detects anomalies (compromised accounts, insider threats)
   - Example: "User X normally logs in from US, now logging in from Russia at 3 AM"

6. **DLP (Data Loss Prevention)**
   - Prevents sensitive data from leaving your systems
   - Detects credit cards, SSNs, API keys in logs/emails/uploads
   - Blocks or alerts on policy violations

**Real-World Scenarios:**

-  Hacker brute-forcing SSH � Wazuh alerts + auto-blocks IP
-  Employee account compromised � UEBA detects unusual behavior
-  SQL injection attempt � Suricata blocks + alerts
-  Unauthorized file changes � Wazuh file integrity alert
-  API key leaked in GitHub � DLP detects + removes + notifies

### Multi-Tenancy Strategy

**What is Multi-Tenancy?**

One platform, multiple separate "tenants" (customers/stores), each with isolated data.

**Implementation:**

- **Database Isolation**: Each tenant gets their own PostgreSQL database
- **Data Separation**: Tenant A cannot see Tenant B's data (enforced at database level)
- **Shared Codebase**: All tenants run the same application code
- **Custom Vendure Plugins**: Handle tenant routing, data filtering

**Use Case:**

You're building a marketplace:

- **Master Catalog**: Shared product database (all vendors)
- **Vendor Stores**: Each vendor has their own ecommerce instance (isolated orders, customers)
- **Customer Experience**: Customers shop across vendors, unified checkout

### Network Architecture & China Support

**Challenge:**

Operating from China behind the Great Firewall blocks many services (GitHub, Google, npm, Docker Hub).

**Solutions Implemented:**

 **Tailscale VPN**: Mesh networking that works reliably in China
 **Gateway VPS**: Digital Ocean server outside China (relay point)
 **China Mirrors**: npm, Docker, apt configured for Chinese CDNs
 **Zero Trust**: All connections authenticated, even internal

**Network Topology:**

```
DV01 (Developer Workstation in China)
  � Tailscale VPN
Gateway VPS (Digital Ocean, outside China)
  � WireGuard VPN
DV02-DV06 (Production Servers in China)
  � Internal Network
Services (Vendure, n8n, OpenSearch, etc.)
```

**Note:** China deployment details are available in separate documentation. The platform works globally without special configuration.

---

## =� Project Structure

```
entrepreneur-os/
   apps/                           # Deployable applications
      vendure-master/            # PIM system (EMPTY - in development)
      vendure-ecommerce/         # Ecommerce engine (EMPTY - in development)
      storefront-nextjs/         # Next.js storefront (EMPTY - in development)
      storefront-vite/           # Vite storefront (EMPTY - in development)
      admin-vendure-master/      # Custom admin UI for master
      admin-vendure-ecommerce/   # Custom admin UI for ecommerce
      n8n-workflows/             # Workflow definitions (EMPTY - workflows not created)

   libs/                          # Shared libraries (reusable code)
      shared/                    # Cross-application code
         ui-components/         # React components (EMPTY - in development)
         data-access/           # GraphQL queries, API clients (EMPTY)
         types/                 # TypeScript interfaces (EMPTY)
         utils/                 # Helper functions (EMPTY)
      vendure/                   # Vendure-specific extensions
         plugins/               # Custom Vendure plugins (EMPTY)
         entities/              # Database entities (EMPTY)
         graphql/               # GraphQL extensions (EMPTY)
      testing/                   # Testing infrastructure
         e2e-utils/             # Playwright helpers (EMPTY)
         fixtures/              # Test data (EMPTY)
         mocks/                 # Mock services (EMPTY)
      config/                    # Shared build configs

   infrastructure/                # Infrastructure as Code
      ansible/                   # Server provisioning & automation
         inventory/             # Server definitions (DV01-DV06)
         playbooks/             # Automation playbooks
         roles/                 # Reusable Ansible roles
      kubernetes/                # K3s manifests for production
      compose/                   # Docker Compose service templates
      monitoring/                # Prometheus, Grafana configs
      terraform/                 # Cloud infrastructure (planned)

   docs/                          # Project documentation
      architecture/              # System design documents
      security/                  # Security policies, SOC/SIEM docs
      setup/                     # Installation & setup guides
      testing/                   # Testing guides
      workflows/                 # n8n workflow documentation
      Plans/                     # Project roadmaps
      IMPLEMENTATION_STATUS.md   # Current implementation tracking
      TODO.md                    # Feature roadmap (54+ items)

   tools/                         # Development utilities
      scripts/                   # Bash scripts (setup, database init, Docker)

   .github/                       # GitHub configuration
      workflows/                 # CI/CD pipelines (GitHub Actions)
         ci.yml                # Main CI pipeline (lint, test, build)
      dependabot.yml            # Automated dependency updates

   .claude/                       # Claude Code (AI assistant) config
      agents/                    # Specialized AI agents
      commands/                  # Slash commands for common tasks
      settings.json              # AI assistant project configuration

   .vscode/                       # VS Code workspace settings
      settings.json              # Editor configuration
      extensions.json            # Recommended extensions

   .husky/                        # Git hooks (pre-commit automation)
      pre-commit                # Runs lint-staged
      commit-msg                # Validates commit messages

   CLAUDE.md                      # Comprehensive guide for AI assistants
   README.md                      # This file (project overview)
   package.json                   # Node.js scripts and dependencies
   nx.json                        # Nx workspace configuration
   tsconfig.base.json             # TypeScript path mappings
   docker-compose.yml             # Docker infrastructure definition
   .env.example                   # Environment variable template
   .gitignore                     # Git ignore rules
   .prettierrc                    # Code formatting rules
   .eslintrc.json                 # Linting rules (strict mode)
   .editorconfig                  # Editor consistency
   .commitlintrc.js               # Commit message format rules
```

### TypeScript Import Paths

All shared libraries use the `@entrepreneur-os/*` namespace for clean imports:

```typescript
// Shared UI Components
import { Button, ProductCard, Layout } from '@entrepreneur-os/shared/ui-components';

// Data Access (GraphQL queries, API clients)
import { useProducts, useOrders } from '@entrepreneur-os/shared/data-access';

// TypeScript Types
import { Product, Order, Customer } from '@entrepreneur-os/shared/types';

// Utility Functions
import { formatPrice, formatDate, validateEmail } from '@entrepreneur-os/shared/utils';

// Vendure Plugins
import { MultiTenantPlugin, RewardsPlugin } from '@entrepreneur-os/vendure/plugins';

// Custom Entities
import { TenantEntity, SupplierEntity } from '@entrepreneur-os/vendure/entities';

// GraphQL Resolvers
import { customProductResolver } from '@entrepreneur-os/vendure/graphql';

// Testing Utilities
import { createTestProduct, mockVendureClient } from '@entrepreneur-os/testing/fixtures';
import { setupE2E } from '@entrepreneur-os/testing/e2e-utils';
```

**Path Configuration**: Defined in `tsconfig.base.json`

---

## =' Development Workflow

### Available Commands

#### Development

```bash
# Start all services in parallel
pnpm run dev

# Start specific Vendure instances
pnpm run dev:vendure       # Both master and ecommerce
pnpm run dev:master        # vendure-master only (ports 3000/3001)
pnpm run dev:ecommerce     # vendure-ecommerce only (ports 3002/3003)

# Start storefronts
pnpm run dev:shops         # Both Next.js and Vite
pnpm run dev:next          # Next.js storefront only
pnpm run dev:vite          # Vite storefront only
```

#### Building

```bash
# Build all applications
pnpm run build

# Build only changed projects (Nx affected)
pnpm run build:affected

# Build specific project
nx build vendure-master
```

#### Testing

```bash
# Run all unit tests
pnpm run test

# Run tests for affected projects only
pnpm run test:affected

# Run tests in watch mode (auto-rerun on changes)
pnpm run test:watch

# End-to-end tests (Playwright)
pnpm run e2e
pnpm run e2e:ui            # Interactive UI mode
```

#### Code Quality

```bash
# Lint all projects
pnpm run lint

# Auto-fix lint issues
pnpm run lint:fix

# Format all code (Prettier)
pnpm run format

# Check formatting without changing files
pnpm run format:check
```

#### Docker Operations

```bash
# Start Docker infrastructure (smart startup script)
pnpm run docker:start

# Start all containers
pnpm run docker:up

# Stop and remove containers
pnpm run docker:down

# Stop containers (preserve state)
pnpm run docker:stop

# Restart all containers
pnpm run docker:restart

# Follow container logs
pnpm run docker:logs

# List running containers
pnpm run docker:ps

# Remove containers and volumes (clean slate)
pnpm run docker:clean

# Force rebuild all containers
pnpm run docker:rebuild

# Reset databases only
pnpm run docker:db:reset
```

#### Database Operations

```bash
# Reset databases (drop and recreate)
pnpm run db:reset

# Seed databases with test data
pnpm run db:seed

# Run database migrations
pnpm run db:migrate

# Initialize databases (first time setup)
bash tools/scripts/init-databases.sh
```

#### Nx Utilities

```bash
# Visualize project dependency graph
pnpm run graph

# Visualize affected projects graph
pnpm run affected:graph

# Clear Nx cache
pnpm run reset

# Clean Nx cache + Docker
pnpm run clean
```

#### Code Generation

```bash
# Interactive generator menu
pnpm run generate

# Generate new library
pnpm run g:lib

# Generate new application
pnpm run g:app

# Generate React component
pnpm run g:component

# Direct Nx generators
nx generate @nx/js:library my-lib
nx generate @nx/node:application my-app
nx generate @nx/react:component MyComponent --project=ui-components
```

### Quality Gates (Automated)

Entrepreneur-OS has multiple layers of automated quality checks to prevent broken code from reaching production.

#### Pre-Commit Hooks (Husky + lint-staged)

**Runs automatically when you commit:**

1. **ESLint**: Lints TypeScript files, auto-fixes issues
2. **Prettier**: Formats code automatically
3. **Type Checking**: Validates TypeScript types
4. **Blocks Commit**: If errors found (must fix before committing)

**Example:**

```bash
git add .
git commit -m "feat: add product search"

# Output:
#  Preparing lint-staged...
# � Running tasks for staged files...
#    Running tasks for *.{ts,tsx}
#      eslint --fix --max-warnings=0
#      prettier --write
#  Applying modifications...
#  Cleaning up temporary files...
# [main abc123f] feat: add product search
```

#### Commit Message Validation (Commitlint)

**Enforces conventional commit format:**

```bash
#  Valid commits
git commit -m "feat: add product search functionality"
git commit -m "fix: resolve cart total calculation bug"
git commit -m "docs: update installation guide"
git commit -m "chore: upgrade dependencies"

# L Invalid commits
git commit -m "updated stuff"           # No type prefix
git commit -m "feat add search"         # Missing colon
git commit -m "FIX: bug"                # Wrong case (must be lowercase)
```

**Allowed types:**

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style (formatting, not CSS)
- `refactor`: Code refactoring
- `perf`: Performance improvements
- `test`: Adding or updating tests
- `build`: Build system changes
- `ci`: CI/CD configuration
- `chore`: Other changes (deps, configs)
- `revert`: Revert previous commit

#### CI/CD Pipeline (GitHub Actions)

**Runs on every push and pull request:**

1. **Lint**: Check code quality (ESLint)
2. **Format Check**: Verify code formatting (Prettier)
3. **Type Check**: Validate TypeScript types
4. **Tests**: Run unit tests (when tests exist)
5. **Build**: Build all applications
6. **E2E Tests**: Run end-to-end tests (when tests exist)
7. **Dependency Review**: Check for vulnerable dependencies (PRs only)

**Pipeline must pass before merging pull requests.**

View pipeline: `.github/workflows/ci.yml`

#### Dependency Security (Dependabot)

**Automated dependency scanning:**

- Checks for vulnerable packages (weekly)
- Creates pull requests for security updates
- Groups updates by package ecosystem (npm, Docker, GitHub Actions)

Configuration: `.github/dependabot.yml`

### Commit Workflow Example

```bash
# 1. Make your changes
vim apps/vendure-master/src/product/product.service.ts

# 2. Stage changes
git add apps/vendure-master/src/product/

# 3. Commit (triggers pre-commit hooks)
git commit -m "feat: implement product search service"

# 4. Pre-commit hooks run automatically:
#    - Lints your TypeScript
#    - Formats with Prettier
#    - Validates commit message

# 5. If hooks pass, commit succeeds
# 6. Push to GitHub
git push origin feat/product-search

# 7. Create pull request
gh pr create --title "feat: implement product search service"

# 8. CI/CD runs automatically
# 9. All checks must pass before merge
# 10. Merge to main
```

---

## =� Infrastructure & Deployment

### Hardware Requirements

#### Development (Minimum)

- **CPU**: 4 cores (Intel i5 / AMD Ryzen 5)
- **RAM**: 16GB
- **Disk**: 100GB SSD
- **OS**: Windows 10+, macOS 11+, Linux (Ubuntu 20.04+)

#### Production (Recommended)

- **CPU**: 8+ cores (Intel i7/i9, AMD Ryzen 7/9, Xeon)
- **RAM**: 32GB+ (64GB for HELK stack)
- **Disk**: 500GB SSD (OS + apps) + 2TB HDD (logs, backups)
- **Network**: Gigabit Ethernet, static IP
- **Optional**: GPU (NVIDIA RTX 3060+) for ML workloads

### Development Environment (Docker Compose)

**For local development, all services run in Docker:**

```bash
# Start all services
pnpm run docker:up

# Services started:
# - PostgreSQL Master (port 5432)
# - PostgreSQL Ecommerce (port 5433)
# - Redis (port 6379)
# - OpenSearch (port 9200)
# - OpenSearch Dashboards (port 5601)
# - Prometheus (port 9090)
# - Grafana (port 3010)
# - n8n (port 5678)
# - Uptime Kuma (port 3011)
# - Adminer (port 8080)
```

**Configuration**: `docker-compose.yml`

### Production Deployment (K3s)

**For production, services run on Kubernetes (K3s - lightweight):**

**Node Topology (DV01-DV06):**

| Node        | Role                    | Services                                                | Hardware                        |
| ----------- | ----------------------- | ------------------------------------------------------- | ------------------------------- |
| **DV01**    | Development Workstation | IDE, Git, Testing                                       | Win11, i9, 64GB RAM             |
| **DV02**    | Master Services         | vendure-master, postgres-master, redis, K3s master      | Debian 13, i9, 32GB             |
| **DV04**    | Ecommerce Services      | vendure-ecommerce, postgres-ecommerce, n8n, storefronts | Debian 13, i7, 32GB             |
| **DV05**    | Monitoring (Hot)        | OpenSearch (hot tier), Wazuh, Prometheus, Grafana       | Debian 13, Ryzen 7, 32GB, SSD   |
| **DV06**    | Monitoring (Warm)       | OpenSearch (warm tier), Vector, Redpanda, Uptime Kuma   | Debian 13, i5, 16GB, HDD        |
| **Gateway** | Public Gateway          | Nginx, WireGuard, SSL, Tailscale                        | Ubuntu 24.04, Digital Ocean VPS |

**Deployment Guide**: See `infrastructure/README.md`

**Infrastructure as Code:**

- **Ansible**: Server provisioning (`infrastructure/ansible/`)
- **K3s Manifests**: Kubernetes configs (`infrastructure/kubernetes/`)
- **Terraform**: Cloud resources (planned)

### Network Architecture

**Zero Trust Principles:**

- All connections require authentication (mTLS)
- VPN required for all access (Tailscale + WireGuard)
- Internal services not exposed to internet
- Gateway VPS acts as single entry point

**Ports (Development):**

| Port | Service                 | Access                   |
| ---- | ----------------------- | ------------------------ |
| 3000 | Vendure Master API      | Private                  |
| 3001 | Vendure Master Admin    | Private                  |
| 3002 | Vendure Ecommerce API   | Public (via gateway)     |
| 3003 | Vendure Ecommerce Admin | Private                  |
| 3010 | Grafana                 | Private                  |
| 5432 | PostgreSQL Master       | Private (localhost only) |
| 5433 | PostgreSQL Ecommerce    | Private (localhost only) |
| 5601 | OpenSearch Dashboards   | Private                  |
| 5678 | n8n                     | Private                  |
| 6379 | Redis                   | Private (localhost only) |
| 8080 | Adminer                 | Private                  |
| 9090 | Prometheus              | Private                  |
| 9200 | OpenSearch              | Private                  |

**Production**: All private ports accessible only via VPN.

### China Deployment (Optional)

**Special Considerations:**

- Tailscale VPN for reliable connectivity through Great Firewall
- China mirror support for npm, Docker, apt packages
- Gateway VPS outside China (Digital Ocean, Singapore region)
- Network optimization for high-latency connections

**Setup Guide**: See `docs/setup/china-deployment.md`

---

## = Security & Monitoring

### Security Stack (SOC/SIEM)

Entrepreneur-OS includes enterprise-grade security monitoring normally found in Fortune 500 companies.

#### Components

**1. Wazuh (Security Event Manager)**

- File integrity monitoring (detects unauthorized changes)
- Vulnerability detection (finds unpatched software)
- Log analysis (correlates events across all systems)
- Compliance auditing (PCI-DSS, GDPR, HIPAA)
- Active response (auto-block attackers)

**2. OpenSearch (SIEM Data Lake)**

- Centralized log storage (all systems, all services)
- Full-text search across millions of events
- Security dashboards and visualizations
- Alert correlation and threat hunting
- Long-term storage (tiered: hot, warm, cold)

**3. Suricata (Network IDS/IPS)**

- Deep packet inspection
- Attack signature detection (SQL injection, XSS, malware)
- Network flow monitoring
- Real-time blocking (IPS mode)

**4. Falco (Kubernetes Runtime Security)**

- Container behavior monitoring
- Privilege escalation detection
- Unexpected network connections
- Container breakout prevention

**5. UEBA (User Behavior Analytics)**

- Learns normal user patterns
- Detects anomalies (compromised accounts, insider threats)
- Risk scoring and alerting

**6. DLP (Data Loss Prevention)**

- Sensitive data detection (credit cards, SSNs, API keys)
- Policy enforcement (prevent data exfiltration)
- Compliance reporting

#### Security Monitoring Dashboard

Access Grafana (http://localhost:3010) for real-time monitoring:

- **Security Events**: Failed logins, unauthorized access attempts
- **System Health**: CPU, memory, disk, network metrics
- **Application Performance**: Request rates, error rates, response times
- **Business Metrics**: Orders, revenue, inventory levels

**Detailed Documentation**: `docs/security/SOC-NOC-DLP-UEBA-ARCHITECTURE.md`

### Zero Trust Implementation

**Principles:**

1. **Never Trust, Always Verify**: All requests authenticated
2. **Least Privilege**: Minimal permissions for each service
3. **Micro-Segmentation**: Network isolation between services
4. **Continuous Monitoring**: All activities logged and analyzed

**Implementation:**

- mTLS (mutual TLS) for all service-to-service communication
- VPN required for all administrative access (Tailscale)
- API keys rotated regularly
- Multi-factor authentication (MFA) for admin accounts
- Secrets managed via Bitwarden (planned)

### Backup & Disaster Recovery

**Backup Strategy:**

- **Databases**: Daily automated backups (pg_dump)
- **Media Assets**: Rsync to separate storage
- **Configuration**: Git-based (Infrastructure as Code)
- **Secrets**: Encrypted backups (Bitwarden)

**Recovery Time Objectives:**

- **RTO** (Recovery Time): < 4 hours
- **RPO** (Recovery Point): < 24 hours

**Disaster Recovery Plan**: `docs/security/disaster-recovery.md` (planned)

---

## =� Troubleshooting

### Common Issues

#### Port Conflicts

**Problem**: Services fail to start due to ports already in use.

**Ports Used:**

- 3000-3003: Vendure instances
- 5432-5433: PostgreSQL
- 5601: OpenSearch Dashboards
- 5678: n8n
- 6379: Redis
- 8080: Adminer
- 9090: Prometheus
- 9200: OpenSearch
- 3010-3011: Grafana, Uptime Kuma

**Solution:**

```bash
# Check what's using a port (example: 5432)
# Windows
netstat -ano | findstr :5432

# Linux/macOS
lsof -i :5432

# Stop conflicting service or change port in docker-compose.yml
```

#### Docker Issues

**Problem**: Containers won't start or crash immediately.

**Solutions:**

```bash
# Check container logs
pnpm run docker:logs

# Check specific container
docker logs postgres-master

# Restart all containers
pnpm run docker:restart

# Clean rebuild
pnpm run docker:clean
pnpm run docker:rebuild

# Check Docker Desktop is running (Windows/macOS)
```

#### Database Connection Issues

**Problem**: Cannot connect to PostgreSQL.

**Solutions:**

```bash
# Check databases are running
pnpm run docker:ps

# Reset databases
pnpm run docker:db:reset

# Connect manually to verify
docker exec -it postgres-master psql -U vendure -d vendure_master

# Check credentials in .env match docker-compose.yml
```

#### Nx Cache Issues

**Problem**: Builds fail with stale cache errors.

**Solution:**

```bash
# Clear Nx cache
pnpm run reset

# Run without cache
nx run-many -t build --all --skip-nx-cache
```

#### Pre-commit Hook Failures

**Problem**: Commits blocked by lint-staged errors.

**Solutions:**

```bash
# Run linter manually to see errors
pnpm run lint

# Auto-fix lint issues
pnpm run lint:fix

# Format code
pnpm run format

# If hooks are broken, skip (emergency only!)
git commit --no-verify -m "message"
```

### Where to Find Logs

**Application Logs:**

- Docker containers: `docker logs <container-name>`
- n8n: Check n8n UI (http://localhost:5678)
- Vendure: Console output when running `pnpm run dev:master`

**System Logs:**

- OpenSearch: http://localhost:5601 (OpenSearch Dashboards)
- Grafana: http://localhost:3010 (all metrics and logs)
- Vector: `/var/log/vector/` (when deployed)

**CI/CD Logs:**

- GitHub Actions: Repository � Actions tab
- Failed pipeline details

### Getting Help

1. **Check Documentation**: `docs/` directory
2. **Search Issues**: GitHub Issues (if repository is public)
3. **Community**: (Add Discord/Slack link when available)
4. **Create Issue**: Provide:
   - OS and version
   - Docker version
   - Node.js version
   - Error messages (full output)
   - Steps to reproduce

---

## =� Roadmap

### Current Phase: Foundation (90% Complete)

**What Works:**

-  Nx monorepo fully configured
-  Docker infrastructure running
-  Quality gates (pre-commit hooks, CI/CD)
-  TypeScript, ESLint, Prettier configured
-  Comprehensive documentation

**What's Missing:**

- L Application code (apps are empty directories)
- L Shared libraries (empty)
- L Tests (framework ready, no tests)

### Next Steps (Priority Order)

#### Phase 1: Core Applications (Weeks 1-4)

1. **Implement vendure-master**
   - Basic Vendure setup with PostgreSQL
   - Product entity and admin UI
   - GraphQL API
   - Authentication

2. **Create Shared Library Examples**
   - At least one UI component (Button)
   - At least one TypeScript type (Product interface)
   - At least one utility function (formatPrice)
   - Demonstrate import paths

3. **Write First Tests**
   - Unit tests for shared utilities
   - E2E test for vendure-master admin UI
   - Establish testing patterns

4. **Implement vendure-ecommerce**
   - Duplicate vendure-master structure
   - Add order management
   - Customer accounts
   - Shopping cart

#### Phase 2: Automation & Storefronts (Weeks 5-8)

5. **Create n8n Workflows**
   - Product sync (master � ecommerce)
   - Order processing automation
   - Inventory alerts

6. **Build Basic Storefront**
   - Next.js storefront with product listing
   - Product detail pages
   - Shopping cart
   - Checkout flow

7. **Implement Shared UI Library**
   - ProductCard component
   - Layout components
   - Form components

#### Phase 3: Production Readiness (Weeks 9-12)

8. **Deploy to Production**
   - Ansible playbooks for server setup
   - K3s cluster deployment
   - SSL certificates
   - Domain configuration

9. **Implement Monitoring**
   - Wazuh agent deployment
   - OpenSearch index configuration
   - Grafana dashboards
   - Alert rules

10. **Security Hardening**
    - Vulnerability scanning
    - Penetration testing
    - Compliance auditing
    - Backup automation

#### Phase 4: Advanced Features (Weeks 13+)

11. **Multi-Tenancy**
    - Tenant database isolation
    - Custom Vendure plugins
    - Tenant routing

12. **ERP Integration**
    - ERPNext connection
    - Inventory sync
    - Accounting sync

13. **CRM Integration**
    - Twenty CRM setup
    - Customer data sync
    - Support ticket integration

14. **Advanced Automation**
    - AI-powered product descriptions
    - Automated pricing optimization
    - Demand forecasting

**Full Roadmap**: See [docs/TODO.md](docs/TODO.md) (54+ features planned)

---

## > Contributing

We welcome contributions! Entrepreneur-OS is in active development and needs help in many areas.

### How to Contribute

1. **Fork the Repository**

```bash
gh repo fork Victorbs-01/thalemia
```

2. **Create a Feature Branch**

```bash
git checkout -b feat/your-feature-name
```

3. **Make Your Changes**

- Follow the code style (ESLint + Prettier will auto-format)
- Write tests for new functionality
- Update documentation as needed

4. **Test Your Changes**

```bash
pnpm run lint
pnpm run test
pnpm run build:affected
```

5. **Commit Using Conventional Commits**

```bash
git commit -m "feat: add product search functionality"
```

6. **Push and Create Pull Request**

```bash
git push origin feat/your-feature-name
gh pr create
```

### Contribution Areas

**High Priority (Core Applications):**

- Implement vendure-master application
- Implement vendure-ecommerce application
- Create shared UI components
- Write unit and E2E tests

**Medium Priority (Features):**

- Build Next.js storefront
- Create n8n workflows
- Implement authentication
- Add payment processing

**Documentation:**

- Improve setup guides
- Add code examples
- Create video tutorials
- Translate documentation

**Infrastructure:**

- Test Ansible playbooks
- Improve Docker configurations
- Kubernetes deployment guides
- Performance optimization

### Code Standards

**TypeScript:**

- Strict mode enabled (no `any` types)
- Explicit return types on functions
- Proper interface definitions

**Testing:**

- Unit tests for all business logic
- E2E tests for critical user flows
- Minimum 70% code coverage (when enforced)

**Git:**

- Conventional commits required
- One feature per pull request
- Descriptive commit messages
- Link to related issues

**Documentation:**

- Update README.md if architecture changes
- Add JSDoc comments for public APIs
- Update IMPLEMENTATION_STATUS.md

### Pull Request Process

1. **PR must pass CI/CD checks** (lint, test, build)
2. **PR requires 1 approval** (from maintainer)
3. **All conversations must be resolved**
4. **Squash merge** to keep clean history

### Code Review Guidelines

**For Reviewers:**

- Be constructive and respectful
- Ask questions rather than demanding changes
- Approve if code works, even if you'd write it differently
- Suggest, don't mandate (unless security/correctness issue)

**For Contributors:**

- Respond to all feedback
- Don't take criticism personally
- Ask for clarification if feedback is unclear
- Update code or explain why you disagree

### First-Time Contributors

**Good First Issues:**

Look for issues labeled `good first issue` or `help wanted` on GitHub.

**Quick Wins:**

- Add TypeScript types to existing code
- Write tests for untested functions
- Improve error messages
- Fix typos in documentation
- Add code examples

**Get Help:**

- Ask questions in issue comments
- Request mentorship for complex tasks
- Pair program with maintainers

### Community Guidelines

- Be respectful and inclusive
- Help others learn
- Assume good intentions
- No harassment, discrimination, or toxic behavior
- Follow the [Code of Conduct](CODE_OF_CONDUCT.md) (to be created)

---

## =� Documentation

### Project Documentation

- **[CLAUDE.md](CLAUDE.md)** - Comprehensive guide for AI assistants (very detailed developer guide)
- **[IMPLEMENTATION_STATUS.md](docs/IMPLEMENTATION_STATUS.md)** - Current state tracking (what's built vs. planned)
- **[TODO.md](docs/TODO.md)** - Feature roadmap (54+ items, prioritized)

### Architecture Documentation

- **[Architecture Overview](docs/architecture/)** - System design, data flows, technology choices
- **[Dual-Vendure Pattern](docs/architecture/)** - Why we separate master/ecommerce
- **[Multi-Tenancy Strategy](docs/architecture/)** - Database isolation, tenant management
- **[Network Topology](docs/architecture/)** - Infrastructure layout, node assignments

### Security Documentation

- **[SOC/NOC/DLP/UEBA Architecture](docs/security/SOC-NOC-DLP-UEBA-ARCHITECTURE.md)** - Enterprise security stack
- **[Detection Rules](docs/security/DETECTION-RULES.md)** - Threat detection signatures
- **[Incident Response Playbooks](docs/security/INCIDENT-RESPONSE-PLAYBOOKS.md)** - Security incident procedures
- **Zero Trust Implementation** (planned)

### Setup Guides

- **[China Deployment Guide](docs/setup/)** - Special considerations for China operations
- **[Production Deployment](docs/setup/)** - K3s cluster setup, Ansible playbooks
- **[Database Setup](docs/setup/)** - PostgreSQL configuration, migrations
- **[VPN Configuration](docs/setup/)** - Tailscale + WireGuard setup

### Development Guides

- **[Contributing Guide](CONTRIBUTING.md)** - How to contribute (to be created)
- **[Testing Guide](docs/testing/)** - Unit, integration, E2E testing patterns
- **[n8n Workflows](docs/workflows/)** - Workflow documentation and examples
- **[API Documentation](docs/api/)** - GraphQL schemas, REST endpoints (planned)

### Infrastructure Documentation

- **[Infrastructure README](infrastructure/README.md)** - Node inventory, Ansible playbooks
- **[Monitoring Setup](infrastructure/monitoring/)** - Prometheus, Grafana, OpenSearch configs
- **[Kubernetes Manifests](infrastructure/kubernetes/)** - K3s deployment configs

### External Documentation Links

- **[Nx Documentation](https://nx.dev)** - Monorepo build system
- **[Vendure Documentation](https://docs.vendure.io)** - E-commerce framework
- **[n8n Documentation](https://docs.n8n.io)** - Workflow automation
- **[OpenSearch Documentation](https://opensearch.org/docs)** - Search and analytics
- **[Wazuh Documentation](https://documentation.wazuh.com)** - Security monitoring

---

## =� License

[Specify License - typically MIT for open-source]

---

## =O Acknowledgments

Built with:

- [Nx](https://nx.dev) - Monorepo build system
- [Vendure](https://vendure.io) - Headless e-commerce framework
- [n8n](https://n8n.io) - Workflow automation
- [OpenSearch](https://opensearch.org) - Search and security analytics
- [Wazuh](https://wazuh.com) - Security monitoring
- [Prometheus](https://prometheus.io) + [Grafana](https://grafana.com) - Monitoring and visualization

Inspired by the need for affordable, self-hosted, enterprise-grade e-commerce solutions for entrepreneurs worldwide.

---

## =� Support & Community

### Get Help

- **GitHub Issues**: Report bugs, request features
- **Documentation**: Check `docs/` for guides
- **Community** (planned): Discord server for discussions

### Stay Updated

- **Star this repository** to follow development
- **Watch releases** for new versions
- **Follow roadmap** in [docs/TODO.md](docs/TODO.md)

### Contact

- **Project Maintainer**: (Add contact info)
- **Email**: (Add email)
- **Twitter**: (Add Twitter handle)

---

**Built with d for entrepreneurs, by entrepreneurs.**

**Status**: =� Active Development | **Version**: 0.1.0 (Pre-Alpha) | **Last Updated**: 2025-11-16
