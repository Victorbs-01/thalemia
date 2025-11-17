# Vendure Ecommerce Installation Runbook

This runbook provides step-by-step instructions for installing and configuring the **Vendure Ecommerce** instance in the Entrepreneur-OS platform.

## Overview

**Vendure Ecommerce** serves as the retail operations system in the dual-Vendure architecture. It handles:
- Order processing and fulfillment
- Inventory management
- Customer transactions
- Storefront API endpoints
- Payment processing

Product data is synced from **Vendure Master** via n8n workflows.

**Ports:**
- API: `3002`
- Admin UI: `3003`

**Database:**
- Name: `vendure_ecommerce`
- PostgreSQL Port: `5433` (external), `5432` (internal container)
- Container: `entrepreneur-postgres-ecommerce`

---

## Prerequisites

### 1. System Requirements

- **Node.js**: v18.x or higher
- **pnpm**: v9.x (installed globally)
- **Docker Desktop**: Running and accessible
- **Git**: For repository access
- **Minimum RAM**: 4GB available
- **Disk Space**: 2GB free

### 2. Vendure Master (Optional but Recommended)

For the complete dual-Vendure setup, install Vendure Master first:
- See [Vendure Master Installation](./vendure-master-install.md)
- Master acts as the Product Information Management (PIM) system
- Ecommerce syncs product data from Master

**Note:** You can install Ecommerce standalone for testing, but production requires Master.

### 3. Docker/PostgreSQL Setup

Ensure Docker containers are running:

```bash
# Check Docker is running
docker ps

# If containers are not running, start them
pnpm docker:up

# Or use the docker-start script
./tools/scripts/docker-start.sh

# Verify PostgreSQL ecommerce is ready
docker exec entrepreneur-postgres-ecommerce pg_isready -U vendure
# Should output: /var/run/postgresql:5432 - accepting connections
```

### 4. Environment Configuration

Create `.env` file from template (if not already done):

```bash
# Copy template
cp .env.example .env

# Edit with your configuration (use your preferred editor)
nano .env
# or
code .env
```

**Verify these variables in `.env`:**

```bash
# Database - Vendure Ecommerce
POSTGRES_ECOMMERCE_HOST=postgres-ecommerce
POSTGRES_ECOMMERCE_PORT=5432  # Internal container port
POSTGRES_ECOMMERCE_DB=vendure_ecommerce
POSTGRES_ECOMMERCE_USER=vendure
POSTGRES_ECOMMERCE_PASSWORD=vendure_ecommerce_pass

# Vendure Ecommerce
VENDURE_ECOMMERCE_PORT=3002
VENDURE_ECOMMERCE_ADMIN_PORT=3003
VENDURE_ECOMMERCE_SUPERADMIN_USERNAME=superadmin
VENDURE_ECOMMERCE_SUPERADMIN_PASSWORD=changeme_superadmin_pass
VENDURE_ECOMMERCE_COOKIE_SECRET=changeme_cookie_secret_ecommerce
```

**Important:** External port is `5433` (mapped from container port 5432)

**Security Note:** Change default passwords in production!

### 5. Initialize Database

Run the database initialization script:

```bash
# From project root
./tools/scripts/init-databases.sh
```

This creates the `vendure_ecommerce` database if it doesn't exist.

---

## Installation Steps

### Linux / macOS

#### Step 1: Run Setup Script

```bash
# From project root
./tools/scripts/setup-vendure.sh
```

**What this does:**
- Creates `apps/vendure-ecommerce/` directory structure
- Generates Vendure configuration files
- Installs dependencies via pnpm
- Creates app-level `.env` file with database credentials

**Duration:** 3-5 minutes (depending on network speed)

#### Step 2: Verify Installation

Check that files were created:

```bash
ls -la apps/vendure-ecommerce/
# Should show:
# - src/
# - package.json
# - tsconfig.json
# - project.json
# - .env
# - migrations/
# - static-assets/
# - static-email-templates/
```

Check dependencies installed:

```bash
cd apps/vendure-ecommerce
pnpm list @vendure/core
# Should show: @vendure/core 3.1.x
```

---

### Windows (PowerShell)

#### Step 1: Run Setup Script

```powershell
# From project root
.\tools\scripts\setup-vendure.ps1
```

**What this does:**
- Creates `apps\vendure-ecommerce\` directory structure
- Generates Vendure configuration files
- Installs dependencies via pnpm
- Creates app-level `.env` file with database credentials

**Duration:** 3-5 minutes (depending on network speed)

#### Step 2: Verify Installation

Check that files were created:

```powershell
dir apps\vendure-ecommerce\
# Should show:
# - src\
# - package.json
# - tsconfig.json
# - project.json
# - .env
# - migrations\
# - static-assets\
# - static-email-templates\
```

Check dependencies installed:

```powershell
cd apps\vendure-ecommerce
pnpm list @vendure/core
# Should show: @vendure/core 3.1.x
```

---

## Vendure Interactive Installer: Questions and Answers

**Note:** The `setup-vendure.sh` and `setup-vendure.ps1` scripts create the Vendure configuration automatically, so you **do NOT** need to run the interactive installer manually.

However, if you're setting up manually or using `@vendure/create`, answer as follows:

### Interactive Questions

| Question | Recommended Answer | Notes |
|----------|-------------------|-------|
| **Database type?** | `postgres` | PostgreSQL 16 |
| **Database host?** | `localhost` | Connecting from host to Docker container |
| **Database port?** | `5433` | **External mapped port for ecommerce DB** |
| **Database name?** | `vendure_ecommerce` | From .env: POSTGRES_ECOMMERCE_DB |
| **Database user?** | `vendure` | From .env: POSTGRES_ECOMMERCE_USER |
| **Database password?** | `vendure_ecommerce_pass` | From .env: POSTGRES_ECOMMERCE_PASSWORD |
| **Use example data?** | `yes` (development)<br>`no` (production) | Example data helpful for testing |
| **API port?** | `3002` | From .env: VENDURE_ECOMMERCE_PORT |
| **Admin UI port?** | `3003` | From .env: VENDURE_ECOMMERCE_ADMIN_PORT |
| **Super admin username?** | `superadmin` | From .env: VENDURE_ECOMMERCE_SUPERADMIN_USERNAME |
| **Super admin password?** | `changeme_superadmin_pass` | From .env: VENDURE_ECOMMERCE_SUPERADMIN_PASSWORD |

### Critical Differences from Vendure Master

1. **Database Port: 5433** (NOT 5432)
   - Ecommerce PostgreSQL maps to external port 5433
   - This is hardcoded in docker-compose.yml
   - Allows both databases to run simultaneously

2. **API Port: 3002** (NOT 3000)
   - Avoids conflict with Vendure Master on 3000

3. **Admin Port: 3003** (NOT 3001)
   - Avoids conflict with Vendure Master on 3001

### Why These Answers?

1. **localhost for host**: Vendure runs on the host machine and connects to Dockerized PostgreSQL via localhost
2. **Port 5433**: External port mapping from docker-compose.yml (internal is still 5432)
3. **Example data (development)**: Provides sample orders, customers for testing
4. **No example data (production)**: Products come from Master via n8n sync

---

## Starting Vendure Ecommerce

### Option 1: Direct (from app directory)

```bash
cd apps/vendure-ecommerce
pnpm run dev
```

### Option 2: Using Nx (from project root)

```bash
nx serve vendure-ecommerce
```

### Option 3: Using pnpm scripts (from project root)

```bash
pnpm run dev:ecommerce
```

**Expected Output:**

```
Vendure server (v3.1.x) now running on port 3002
Vendure worker (v3.1.x) now running
Admin UI available at http://localhost:3003/admin
```

**First Start Duration:** 30-60 seconds (schema creation)

---

## Verification Steps

### 1. Check Server is Running

```bash
# Test API health
curl http://localhost:3002/health
# Should return: {"status":"ok"}

# Test Admin UI access
curl -I http://localhost:3003/admin
# Should return: HTTP/1.1 200 OK
```

### 2. Access Admin UI

Open browser and navigate to:

```
http://localhost:3003/admin
```

**Login Credentials:**
- Username: `superadmin`
- Password: `changeme_superadmin_pass` (or what you set in .env)

### 3. Verify Database Schema

```bash
# Connect to database
docker exec -it entrepreneur-postgres-ecommerce psql -U vendure -d vendure_ecommerce

# List tables
\dt

# Should show many tables including:
# - product
# - product_variant
# - channel
# - customer
# - order
# - order_line
# etc.

# Exit psql
\q
```

### 4. Test GraphQL API

```bash
# GraphQL playground
open http://localhost:3002/shop-api

# Or test a simple query
curl -X POST http://localhost:3002/shop-api \
  -H "Content-Type: application/json" \
  -d '{"query": "{ products { items { id name } } }"}'
```

---

## Post-Installation Configuration

### 1. Complete Setup Wizard (Admin UI)

1. Navigate to http://localhost:3003/admin
2. Login with superadmin credentials
3. Follow the setup wizard:
   - **Create Channel**: Name it (e.g., "Ecommerce Channel")
   - **Configure Shipping Methods**: Set up shipping zones and rates
   - **Add Payment Methods**: Configure Stripe, PayPal, etc.
   - **Create Initial Admin User**: Optional, for team members

### 2. Configure Product Sync (from Master)

In production, products are synced from Vendure Master via n8n workflows.

**For development/testing:**

Option A: Manually create products in Ecommerce Admin UI

Option B: Import from Master:
1. Export products from Master (http://localhost:3001/admin)
2. Import into Ecommerce (http://localhost:3003/admin)
3. Or use n8n workflow (see `apps/n8n-workflows/`)

### 3. Configure Storefront API

The ecommerce instance provides the API for storefronts:

**Next.js Storefront:**
```bash
# In .env
NEXT_PUBLIC_API_URL=http://localhost:3002/shop-api
```

**Vite Storefront:**
```bash
# In .env
VITE_API_URL=http://localhost:3002/shop-api
```

### 4. Review Security Settings

**Development defaults (apps/vendure-ecommerce/.env):**
```bash
COOKIE_SECRET=<randomly-generated>
SUPERADMIN_PASSWORD=superadmin
```

**For production:**
```bash
# Use strong, unique values
COOKIE_SECRET=<strong-random-string-min-32-chars>
SUPERADMIN_PASSWORD=<strong-password>
```

Generate strong secrets:
```bash
openssl rand -base64 32
```

---

## Troubleshooting

### Issue: "Database connection failed"

**Symptoms:**
```
Error: connect ECONNREFUSED localhost:5433
```

**Solutions:**

1. **Check PostgreSQL container is running:**
   ```bash
   docker ps | grep postgres-ecommerce
   ```
   If not running: `pnpm docker:up`

2. **Verify database exists:**
   ```bash
   docker exec entrepreneur-postgres-ecommerce psql -U postgres -l
   # Should list vendure_ecommerce
   ```
   If missing: `./tools/scripts/init-databases.sh`

3. **Check port mapping:**
   ```bash
   docker ps | grep postgres-ecommerce
   # Should show: 0.0.0.0:5433->5432/tcp
   ```

4. **Verify credentials in apps/vendure-ecommerce/.env:**
   ```bash
   cat apps/vendure-ecommerce/.env | grep DB_
   # DB_HOST=localhost
   # DB_PORT=5433  # Important: External port!
   # DB_NAME=vendure_ecommerce
   ```

5. **Test connection manually:**
   ```bash
   docker exec -it entrepreneur-postgres-ecommerce psql -U vendure -d vendure_ecommerce
   # Should connect successfully
   ```

---

### Issue: "Port 3002 or 3003 already in use"

**Symptoms:**
```
Error: listen EADDRINUSE: address already in use :::3002
```

**Solutions:**

1. **Check if Vendure Master is using the port:**
   ```bash
   ps aux | grep vendure
   # Or
   lsof -i :3002
   ```

2. **Kill conflicting process:**
   ```bash
   # Linux/macOS
   kill -9 <PID>

   # Windows PowerShell
   Stop-Process -Id <PID> -Force
   ```

3. **Or change Vendure port:**
   Edit `apps/vendure-ecommerce/.env`:
   ```bash
   PORT=3012  # Use different port
   ADMIN_PORT=3013
   ```

---

### Issue: "Wrong database port in connection"

**Symptoms:**
```
Error: Database "vendure_ecommerce" does not exist
# OR
Connection refused on port 5432
```

**Cause:** Using internal port (5432) instead of external port (5433)

**Solution:**

Check `apps/vendure-ecommerce/.env`:
```bash
DB_PORT=5433  # MUST be 5433 for ecommerce!
```

**Why this happens:**
- Ecommerce PostgreSQL container: Internal port 5432 → External port 5433
- Master PostgreSQL container: Internal port 5432 → External port 5432
- Both containers use 5432 internally, but external mappings differ

---

### Issue: "Cannot find module '@vendure/core'"

**Symptoms:**
```
Error: Cannot find module '@vendure/core'
```

**Solutions:**

1. **Reinstall dependencies:**
   ```bash
   cd apps/vendure-ecommerce
   rm -rf node_modules
   pnpm install
   ```

2. **Check pnpm workspace:**
   ```bash
   # From project root
   pnpm install
   ```

3. **Verify package.json:**
   ```bash
   cat apps/vendure-ecommerce/package.json | grep "@vendure/core"
   # Should show: "@vendure/core": "^3.1.0"
   ```

---

### Issue: "Admin UI shows blank page"

**Symptoms:**
- http://localhost:3003/admin loads but shows white/blank page
- Console errors about OSW or webpack

**Solutions:**

1. **Verify OSW version is pinned:**
   ```bash
   cat apps/vendure-ecommerce/package.json
   # Should show in pnpm.overrides:
   # "osw": "1.3.5"
   ```

2. **Clear cache and rebuild:**
   ```bash
   cd apps/vendure-ecommerce
   rm -rf node_modules/.cache
   pnpm run build
   pnpm run dev
   ```

3. **Check console for errors:**
   Open browser DevTools (F12) and check Console tab

---

### Issue: "No products showing in ecommerce"

**Symptoms:**
- Ecommerce Admin UI shows empty product list
- Storefront has no products

**Cause:** Products not synced from Master

**Solutions:**

1. **Check if Vendure Master has products:**
   - Open http://localhost:3001/admin
   - Navigate to Catalog → Products
   - Create sample products if empty

2. **Manual product creation:**
   - Open http://localhost:3003/admin
   - Create products directly in Ecommerce
   - Useful for standalone testing

3. **Set up n8n sync workflow:**
   - See `apps/n8n-workflows/workflows/`
   - Configure product sync from Master → Ecommerce
   - Run workflow to sync products

4. **Export/Import:**
   - Export products from Master as CSV/JSON
   - Import into Ecommerce via Admin UI

---

### Issue: "Tables not created in database"

**Symptoms:**
- Database exists but has no tables
- Error: `relation "order" does not exist`

**Solutions:**

1. **Verify synchronize is enabled:**
   Edit `apps/vendure-ecommerce/src/vendure-config.ts`:
   ```typescript
   dbConnectionOptions: {
     // ...
     synchronize: true,  // Should be true for development
   }
   ```

2. **Restart Vendure:**
   ```bash
   # Stop (Ctrl+C)
   # Start again
   cd apps/vendure-ecommerce
   pnpm run dev
   ```

3. **Check logs for schema creation:**
   Should see:
   ```
   query: CREATE TABLE "order" ...
   query: CREATE TABLE "order_line" ...
   ```

4. **Manual migration (if needed):**
   ```bash
   cd apps/vendure-ecommerce
   pnpm run migration:run
   ```

---

## Dual-Vendure Architecture Notes

### Data Flow

```
Vendure Master (PIM)
    ↓
n8n Workflows (Product Sync)
    ↓
Vendure Ecommerce (Orders)
    ↓
Storefronts (Next.js / Vite)
```

### Separation of Concerns

**Vendure Master:**
- Product catalog management
- Supplier relationships
- Pricing and variants
- Product attributes

**Vendure Ecommerce:**
- Order processing
- Inventory management
- Customer accounts
- Payment transactions
- Fulfillment workflows

### Synchronization

Use n8n workflows to sync:
- Products: Master → Ecommerce (one-way)
- Inventory: Ecommerce → Master (feedback loop)
- Orders: Stay in Ecommerce (not synced to Master)

---

## Maintenance Tasks

### Update Vendure Version

```bash
cd apps/vendure-ecommerce
pnpm update @vendure/core @vendure/admin-ui @vendure/asset-server-plugin @vendure/email-plugin
pnpm install
```

### Backup Database

```bash
# Export database
docker exec entrepreneur-postgres-ecommerce pg_dump -U vendure vendure_ecommerce > vendure_ecommerce_backup.sql

# Restore database
cat vendure_ecommerce_backup.sql | docker exec -i entrepreneur-postgres-ecommerce psql -U vendure -d vendure_ecommerce
```

### View Logs

```bash
# Application logs (if running in background)
cd apps/vendure-ecommerce
pnpm run dev 2>&1 | tee vendure.log

# Database logs
docker logs entrepreneur-postgres-ecommerce
```

---

## Related Documentation

- [Vendure Master Installation](./vendure-master-install.md)
- [CLAUDE.md](../../CLAUDE.md) - Project development guide
- [Docker Setup](../setup/DOCKER_SETUP.md)
- [n8n Workflows](../workflows/N8N_FLOWS.md)
- [Vendure Official Docs](https://docs.vendure.io/)

---

## Quick Reference

### Commands Summary

| Task | Linux/macOS | Windows PowerShell |
|------|-------------|-------------------|
| **Install** | `./tools/scripts/setup-vendure.sh` | `.\tools\scripts\setup-vendure.ps1` |
| **Start** | `cd apps/vendure-ecommerce && pnpm run dev` | `cd apps\vendure-ecommerce; pnpm run dev` |
| **Stop** | `Ctrl+C` | `Ctrl+C` |
| **Reset DB** | `./tools/scripts/reset-databases.sh` | N/A (use Docker/psql manually) |
| **Access Admin** | `http://localhost:3003/admin` | `http://localhost:3003/admin` |

### Connection Details

| Parameter | Value |
|-----------|-------|
| **Database Host** | localhost (from host), postgres-ecommerce (from Docker) |
| **Database Port** | **5433** (external), 5432 (internal) |
| **Database Name** | vendure_ecommerce |
| **Database User** | vendure |
| **API URL** | http://localhost:3002/shop-api |
| **Admin URL** | http://localhost:3003/admin |
| **GraphQL Playground** | http://localhost:3002/shop-api |

### Port Comparison

| Instance | API Port | Admin Port | DB Port (External) |
|----------|----------|------------|-------------------|
| **Master** | 3000 | 3001 | 5432 |
| **Ecommerce** | 3002 | 3003 | **5433** |

---

**Last Updated:** 2025-01-17
**Vendure Version:** 3.1.x
**Maintainer:** Entrepreneur-OS Team
