# Vendure Setup Guide for Low-RAM Machines

This guide explains how to set up the dual-Vendure architecture (Master + Ecommerce) on machines with limited RAM by installing instances sequentially instead of simultaneously.

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Step 1: Start PostgreSQL Databases](#step-1-start-postgresql-databases)
- [Step 2: Setup Vendure Master](#step-2-setup-vendure-master)
- [Step 3: Setup Vendure Ecommerce](#step-3-setup-vendure-ecommerce)
- [Step 4: First Run](#step-4-first-run)
- [Troubleshooting](#troubleshooting)
- [Reference](#reference)

---

## Overview

Entrepreneur-OS uses a **dual-Vendure pattern** with two separate instances:

- **vendure-master** (port 3000/3001): Product Information Management (PIM) system
- **vendure-ecommerce** (port 3002/3003): Retail operations and order processing

**Why split the setup?**

Installing both Vendure instances simultaneously requires significant RAM (~4-8GB) during the pnpm install process. This sequential approach reduces peak memory usage by installing one instance at a time.

**Architecture:**

```
┌─────────────────────┐         ┌─────────────────────┐
│  Vendure Master     │         │ Vendure Ecommerce   │
│  (PIM)              │         │ (Orders)            │
│                     │         │                     │
│  API: :3000         │  sync   │  API: :3002         │
│  Admin: :3001       │ ──────> │  Admin: :3003       │
└──────────┬──────────┘         └──────────┬──────────┘
           │                               │
           │                               │
    ┌──────▼────────┐             ┌────────▼──────┐
    │  PostgreSQL   │             │  PostgreSQL   │
    │  Master       │             │  Ecommerce    │
    │  :5432        │             │  :5433        │
    └───────────────┘             └───────────────┘
```

---

## Prerequisites

### System Requirements

- **Docker Desktop** installed and running
- **Node.js** 20.x or higher
- **pnpm** 9.x (managed via Corepack)
- **Available RAM**: Minimum 4GB, recommended 8GB+
- **Disk Space**: ~2GB free for dependencies

### Verify Prerequisites

```bash
# Check Docker
docker --version
docker ps

# Check Node
node --version

# Check pnpm
pnpm --version

# If pnpm not available, enable Corepack
corepack enable
```

### Project Setup

Ensure you're in the project root and have dependencies installed:

```bash
cd /path/to/entrepreneur-os
pnpm install
```

---

## Step 1: Start PostgreSQL Databases

Before setting up Vendure instances, you need to start **only the PostgreSQL containers** from Docker Compose.

### Start Both Databases

```bash
docker-compose up -d postgres-master postgres-ecommerce
```

### Verify Databases are Running

```bash
# Check container status
docker ps

# Expected output should show:
# - entrepreneur-postgres-master (port 5432)
# - entrepreneur-postgres-ecommerce (port 5433)
```

### Verify Database Connectivity

```bash
# Test Master database
docker exec entrepreneur-postgres-master pg_isready -U vendure

# Test Ecommerce database
docker exec entrepreneur-postgres-ecommerce pg_isready -U vendure

# Both should output: "accepting connections"
```

**Troubleshooting:** If databases aren't ready, wait 10-15 seconds and try again. PostgreSQL needs time to initialize.

---

## Step 2: Setup Vendure Master

With the Master database running, install the Vendure Master instance.

### Run Setup Script

```bash
# From project root
pnpm run setup:vendure:master

# Or directly:
bash tools/scripts/setup-vendure-master.sh
```

### What This Does

1. Creates `apps/vendure-master/` directory structure
2. Generates configuration files:
   - `package.json` with Vendure 3.1.x dependencies
   - `tsconfig.json` for TypeScript compilation
   - `.env` with database credentials (port 5432)
   - `src/vendure-config.ts` with Vendure configuration
   - `src/index.ts` and `src/index-worker.ts`
   - `project.json` for Nx integration
3. Installs dependencies (~5-10 minutes, ~600MB)

### Expected Output

```
🚀 Entrepreneur OS - Vendure Master Setup
================================================
✓ Docker está corriendo
✓ Base de datos Master lista
📦 Configurando vendure-master...
ℹ Creando estructura de directorios...
ℹ Creando package.json...
ℹ Instalando dependencias (esto puede tardar 5-10 minutos)...
✓ vendure-master configurado exitosamente!

🎉 ¡Vendure Master configurado exitosamente!
```

### Verify Installation

```bash
# Check directory was created
ls apps/vendure-master/

# Should contain: src/, package.json, tsconfig.json, .env, project.json
```

---

## Step 3: Setup Vendure Ecommerce

After Master is successfully installed, set up the Ecommerce instance.

### Run Setup Script

```bash
# From project root
pnpm run setup:vendure:ecommerce

# Or directly:
bash tools/scripts/setup-vendure-ecommerce.sh
```

### What This Does

1. Creates `apps/vendure-ecommerce/` directory structure
2. Generates configuration files (same structure as Master)
3. Configures for different ports and database:
   - Database: port 5433
   - API: port 3002
   - Admin UI: port 3003
4. Installs dependencies (~5-10 minutes, ~600MB)

### Expected Output

```
🚀 Entrepreneur OS - Vendure Ecommerce Setup
================================================
✓ Docker está corriendo
✓ Base de datos Ecommerce lista
📦 Configurando vendure-ecommerce...
ℹ Instalando dependencias (esto puede tardar 5-10 minutos)...
✓ vendure-ecommerce configurado exitosamente!

🎉 ¡Vendure Ecommerce configurado exitosamente!
```

---

## Step 4: First Run

After both instances are installed, you can start them.

### Option A: Start Both Instances (If You Have RAM)

```bash
# From project root, using Nx
pnpm run dev:vendure

# This starts both master and ecommerce concurrently
```

### Option B: Start Sequentially (Recommended for Low RAM)

#### Start Master First

```bash
# Terminal 1
cd apps/vendure-master
pnpm run dev

# Or from root:
nx serve vendure-master
```

**Wait for Master to fully start** (look for these messages):

```
Vendure server listening on port 3000
Admin UI available at http://localhost:3001
```

#### Verify Master is Running

```bash
# In a new terminal
curl http://localhost:3000/shop-api
# Should return GraphQL playground HTML

# Open in browser:
http://localhost:3001/admin
```

#### Start Ecommerce

```bash
# Terminal 2 (after Master is confirmed running)
cd apps/vendure-ecommerce
pnpm run dev

# Or from root:
nx serve vendure-ecommerce
```

**Wait for Ecommerce to fully start:**

```
Vendure server listening on port 3002
Admin UI available at http://localhost:3003
```

### First-Time Database Initialization

**Important:** The first time each Vendure instance starts:

1. It will create all database tables automatically (`synchronize: true` in config)
2. This takes **30-60 seconds** - be patient
3. You'll see many SQL queries in the logs (this is normal)
4. Once completed, you'll see: "Vendure server listening on port..."

### Complete Setup Wizard

After each instance starts for the first time:

1. Open Admin UI in browser:
   - Master: http://localhost:3001/admin
   - Ecommerce: http://localhost:3003/admin
2. Login with default credentials:
   - Username: `superadmin`
   - Password: `superadmin`
3. Follow the setup wizard to:
   - Set shop name
   - Configure default channel
   - Create initial admin user (recommended)
   - Set up shipping methods
   - Configure payment methods

---

## Troubleshooting

### Problem: "Database is not ready"

**Symptoms:**

```
✗ La base de datos Master no está lista.
```

**Solution:**

```bash
# Check if container is running
docker ps | grep postgres

# If not running, start it
docker-compose up -d postgres-master postgres-ecommerce

# Wait 10-15 seconds, then retry
pnpm run setup:vendure:master
```

### Problem: "pnpm install" Hangs or Runs Out of Memory

**Symptoms:**

- Script freezes during dependency installation
- System becomes unresponsive
- Error: `FATAL ERROR: Reached heap limit`

**Solution:**

1. Close unnecessary applications
2. Ensure you're running installations sequentially (not both at once)
3. If still fails, increase Node.js heap size:

```bash
# Windows
$env:NODE_OPTIONS="--max-old-space-size=4096"

# macOS/Linux
export NODE_OPTIONS="--max-old-space-size=4096"

# Then retry
pnpm run setup:vendure:master
```

### Problem: "Port Already in Use"

**Symptoms:**

```
Error: listen EADDRINUSE: address already in use :::3000
```

**Solution:**

```bash
# Check what's using the port (example for port 3000)
# Windows:
netstat -ano | findstr :3000

# macOS/Linux:
lsof -i :3000

# Kill the process or change Vendure port in .env file
```

### Problem: "Docker Not Running"

**Symptoms:**

```
✗ Docker no está corriendo. Inicia Docker Desktop primero.
```

**Solution:**

1. Start Docker Desktop
2. Wait for it to fully initialize (check system tray icon)
3. Verify: `docker ps`
4. Retry setup script

### Problem: "Cannot Find Module '@vendure/core'"

**Symptoms:**

```
Error: Cannot find module '@vendure/core'
```

**Solution:**

This means dependencies weren't installed. Run:

```bash
cd apps/vendure-master
pnpm install --shamefully-hoist

# Or for ecommerce:
cd apps/vendure-ecommerce
pnpm install --shamefully-hoist
```

### Problem: Database Connection Refused

**Symptoms:**

```
Error: connect ECONNREFUSED 127.0.0.1:5432
```

**Solution:**

```bash
# Verify database container is running
docker exec entrepreneur-postgres-master pg_isready -U vendure

# If not ready, restart container
docker-compose restart postgres-master

# Check logs
docker logs entrepreneur-postgres-master
```

---

## Reference

### URLs and Ports

| Service                     | URL                            | Port |
| --------------------------- | ------------------------------ | ---- |
| **Vendure Master API**      | http://localhost:3000/shop-api | 3000 |
| **Vendure Master Admin**    | http://localhost:3001/admin    | 3001 |
| **Vendure Ecommerce API**   | http://localhost:3002/shop-api | 3002 |
| **Vendure Ecommerce Admin** | http://localhost:3003/admin    | 3003 |
| **PostgreSQL Master**       | localhost:5432                 | 5432 |
| **PostgreSQL Ecommerce**    | localhost:5433                 | 5433 |

### Default Credentials

#### Vendure Admin UI (Both Instances)

- **Username:** `superadmin`
- **Password:** `superadmin`

⚠️ **Important:** Change these credentials in production!

#### PostgreSQL (Both Databases)

- **Username:** `vendure`
- **Password (Master):** `vendure_master_pass`
- **Password (Ecommerce):** `vendure_ecommerce_pass`
- **Database (Master):** `vendure_master`
- **Database (Ecommerce):** `vendure_ecommerce`

### File Locations

#### Vendure Master

```
apps/vendure-master/
├── src/
│   ├── index.ts                    # Server entry point
│   ├── index-worker.ts             # Worker entry point
│   └── vendure-config.ts           # Configuration
├── static-assets/                  # Uploaded assets
├── static-email-templates/         # Email templates
├── static-email-output/            # Dev email output
├── migrations/                     # Database migrations
├── .env                            # Environment variables
├── package.json                    # Dependencies
├── tsconfig.json                   # TypeScript config
└── project.json                    # Nx config
```

#### Vendure Ecommerce

Same structure as Master, located in `apps/vendure-ecommerce/`

### Environment Variables

Located in `apps/vendure-{instance}/.env`:

```bash
# Database
DB_HOST=localhost
DB_PORT=5432              # or 5433 for ecommerce
DB_USERNAME=vendure
DB_PASSWORD=vendure_master_pass  # or vendure_ecommerce_pass
DB_NAME=vendure_master           # or vendure_ecommerce

# Server
PORT=3000                 # or 3002 for ecommerce
ADMIN_PORT=3001           # or 3003 for ecommerce

# Security
COOKIE_SECRET=<auto-generated>
SUPERADMIN_USERNAME=superadmin
SUPERADMIN_PASSWORD=superadmin

# Email
EMAIL_FROM=noreply@vendure-master.local
EMAIL_TRANSPORT=file

# Environment
NODE_ENV=development
```

### Useful Commands

```bash
# Start only PostgreSQL
docker-compose up -d postgres-master postgres-ecommerce

# Stop PostgreSQL
docker-compose stop postgres-master postgres-ecommerce

# View database logs
docker logs entrepreneur-postgres-master
docker logs entrepreneur-postgres-ecommerce

# Connect to database
docker exec -it entrepreneur-postgres-master psql -U vendure -d vendure_master
docker exec -it entrepreneur-postgres-ecommerce psql -U vendure -d vendure_ecommerce

# Reset database (CAUTION: Deletes all data)
docker-compose down postgres-master
docker volume rm entrepreneur-os_postgres-master-data
docker-compose up -d postgres-master

# Check Vendure logs
cd apps/vendure-master && pnpm run dev  # logs appear here
cd apps/vendure-ecommerce && pnpm run dev

# Run migrations
cd apps/vendure-master
pnpm run migration:generate
pnpm run migration:run
```

### Next Steps

After completing this setup:

1. **Explore the Admin UI** - Familiarize yourself with Vendure's interface
2. **Create test products** in Master instance (PIM)
3. **Set up n8n workflows** for data sync from Master to Ecommerce
4. **Configure storefronts** to connect to Ecommerce API
5. **Review security settings** - Change default passwords
6. **Plan custom plugins** - See `libs/vendure/plugins/`

### Additional Resources

- [Vendure Documentation](https://docs.vendure.io)
- [CLAUDE.md](../../CLAUDE.md) - Complete project documentation
- [README.md](../../README.md) - Project overview
- [Architecture Documentation](../architecture/ARCHITECTURE.md)
- [n8n Workflow Examples](../../apps/n8n-workflows/)

---

## Support

If you encounter issues not covered in this guide:

1. Check [CLAUDE.md](../../CLAUDE.md) for project-specific details
2. Review Vendure logs in the terminal
3. Check Docker container logs: `docker logs <container-name>`
4. Consult [Vendure Discord](https://vendure.io/community) community
5. Review GitHub issues in [Vendure repository](https://github.com/vendure-ecommerce/vendure)

---

**Last Updated:** 2025-11-16
**Vendure Version:** 3.1.x
**Target Audience:** Developers with limited RAM (<8GB)
