# Vendure Master Installation Runbook

This runbook provides step-by-step instructions for installing and configuring the **Vendure Master** instance in the Entrepreneur-OS platform.

## Overview

**Vendure Master** serves as the central Product Information Management (PIM) system in the dual-Vendure architecture. It is the single source of truth for:
- Product catalogs
- Supplier information
- Pricing data
- Product attributes and variants

**Ports:**
- API: `3000`
- Admin UI: `3001`

**Database:**
- Name: `vendure_master`
- PostgreSQL Port: `5432` (external), `5432` (internal container)
- Container: `entrepreneur-postgres-master`

---

## Prerequisites

### 1. System Requirements

- **Node.js**: v18.x or higher
- **pnpm**: v9.x (installed globally)
- **Docker Desktop**: Running and accessible
- **Git**: For repository access
- **Minimum RAM**: 4GB available
- **Disk Space**: 2GB free

### 2. Docker/PostgreSQL Setup

Ensure Docker containers are running:

```bash
# Check Docker is running
docker ps

# If containers are not running, start them
pnpm docker:up

# Or use the docker-start script
./tools/scripts/docker-start.sh

# Verify PostgreSQL master is ready
docker exec entrepreneur-postgres-master pg_isready -U vendure
# Should output: /var/run/postgresql:5432 - accepting connections
```

### 3. Environment Configuration

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
# Database - Vendure Master
POSTGRES_MASTER_HOST=postgres-master
POSTGRES_MASTER_PORT=5432
POSTGRES_MASTER_DB=vendure_master
POSTGRES_MASTER_USER=vendure
POSTGRES_MASTER_PASSWORD=vendure_master_pass

# Vendure Master
VENDURE_MASTER_PORT=3000
VENDURE_MASTER_ADMIN_PORT=3001
VENDURE_MASTER_SUPERADMIN_USERNAME=superadmin
VENDURE_MASTER_SUPERADMIN_PASSWORD=changeme_superadmin_pass
VENDURE_MASTER_COOKIE_SECRET=changeme_cookie_secret_master
```

**Security Note:** Change default passwords in production!

### 4. Initialize Database

Run the database initialization script:

```bash
# From project root
./tools/scripts/init-databases.sh
```

This creates the `vendure_master` database if it doesn't exist.

---

## Installation Steps

### Linux / macOS

#### Step 1: Run Setup Script

```bash
# From project root
./tools/scripts/setup-vendure.sh
```

**What this does:**
- Creates `apps/vendure-master/` directory structure
- Generates Vendure configuration files
- Installs dependencies via pnpm
- Creates app-level `.env` file with database credentials

**Duration:** 3-5 minutes (depending on network speed)

#### Step 2: Verify Installation

Check that files were created:

```bash
ls -la apps/vendure-master/
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
cd apps/vendure-master
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
- Creates `apps\vendure-master\` directory structure
- Generates Vendure configuration files
- Installs dependencies via pnpm
- Creates app-level `.env` file with database credentials

**Duration:** 3-5 minutes (depending on network speed)

#### Step 2: Verify Installation

Check that files were created:

```powershell
dir apps\vendure-master\
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
cd apps\vendure-master
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
| **Database port?** | `5432` | External mapped port for master DB |
| **Database name?** | `vendure_master` | From .env: POSTGRES_MASTER_DB |
| **Database user?** | `vendure` | From .env: POSTGRES_MASTER_USER |
| **Database password?** | `vendure_master_pass` | From .env: POSTGRES_MASTER_PASSWORD |
| **Use example data?** | `yes` (development)<br>`no` (production) | Example data helpful for testing |
| **API port?** | `3000` | From .env: VENDURE_MASTER_PORT |
| **Admin UI port?** | `3001` | From .env: VENDURE_MASTER_ADMIN_PORT |
| **Super admin username?** | `superadmin` | From .env: VENDURE_MASTER_SUPERADMIN_USERNAME |
| **Super admin password?** | `changeme_superadmin_pass` | From .env: VENDURE_MASTER_SUPERADMIN_PASSWORD |

### Why These Answers?

1. **localhost for host**: Vendure runs on the host machine and connects to Dockerized PostgreSQL via localhost
2. **Port 5432**: External port mapping from docker-compose.yml
3. **Example data (development)**: Provides sample products, customers, and orders for testing
4. **No example data (production)**: Clean slate for production data

---

## Starting Vendure Master

### Option 1: Direct (from app directory)

```bash
cd apps/vendure-master
pnpm run dev
```

### Option 2: Using Nx (from project root)

```bash
nx serve vendure-master
```

### Option 3: Using pnpm scripts (from project root)

```bash
pnpm run dev:master
```

**Expected Output:**

```
Vendure server (v3.1.x) now running on port 3000
Vendure worker (v3.1.x) now running
Admin UI available at http://localhost:3001/admin
```

**First Start Duration:** 30-60 seconds (schema creation)

---

## Verification Steps

### 1. Check Server is Running

```bash
# Test API health
curl http://localhost:3000/health
# Should return: {"status":"ok"}

# Test Admin UI access
curl -I http://localhost:3001/admin
# Should return: HTTP/1.1 200 OK
```

### 2. Access Admin UI

Open browser and navigate to:

```
http://localhost:3001/admin
```

**Login Credentials:**
- Username: `superadmin`
- Password: `changeme_superadmin_pass` (or what you set in .env)

### 3. Verify Database Schema

```bash
# Connect to database
docker exec -it entrepreneur-postgres-master psql -U vendure -d vendure_master

# List tables
\dt

# Should show many tables including:
# - product
# - product_variant
# - channel
# - customer
# - order
# etc.

# Exit psql
\q
```

### 4. Test GraphQL API

```bash
# GraphQL playground
open http://localhost:3000/shop-api

# Or test a simple query
curl -X POST http://localhost:3000/shop-api \
  -H "Content-Type: application/json" \
  -d '{"query": "{ products { items { id name } } }"}'
```

---

## Post-Installation Configuration

### 1. Complete Setup Wizard (Admin UI)

1. Navigate to http://localhost:3001/admin
2. Login with superadmin credentials
3. Follow the setup wizard:
   - **Create Channel**: Name it appropriately (e.g., "Default Channel")
   - **Configure Shipping Methods**: Set up basic shipping
   - **Add Payment Methods**: Configure payment providers
   - **Create Initial Admin User**: Optional, for team members

### 2. Configure Email (Optional)

The development setup uses file-based email (stored in `static-email-output/`).

For production SMTP, edit `apps/vendure-master/.env`:

```bash
EMAIL_FROM=noreply@entrepreneur-os.com
EMAIL_TRANSPORT=smtp
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASS=your-app-password
```

### 3. Review Security Settings

**Development defaults (apps/vendure-master/.env):**
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
Error: connect ECONNREFUSED localhost:5432
```

**Solutions:**

1. **Check PostgreSQL container is running:**
   ```bash
   docker ps | grep postgres-master
   ```
   If not running: `pnpm docker:up`

2. **Verify database exists:**
   ```bash
   docker exec entrepreneur-postgres-master psql -U postgres -l
   # Should list vendure_master
   ```
   If missing: `./tools/scripts/init-databases.sh`

3. **Check credentials in `.env`:**
   Ensure `POSTGRES_MASTER_*` values match docker-compose.yml

4. **Test connection manually:**
   ```bash
   docker exec -it entrepreneur-postgres-master psql -U vendure -d vendure_master
   # Should connect successfully
   ```

---

### Issue: "Port 3000 already in use"

**Symptoms:**
```
Error: listen EADDRINUSE: address already in use :::3000
```

**Solutions:**

1. **Find process using port 3000:**
   ```bash
   # Linux/macOS
   lsof -i :3000

   # Windows PowerShell
   netstat -ano | findstr :3000
   ```

2. **Kill the process:**
   ```bash
   # Linux/macOS
   kill -9 <PID>

   # Windows PowerShell
   Stop-Process -Id <PID> -Force
   ```

3. **Or change Vendure port:**
   Edit `apps/vendure-master/.env`:
   ```bash
   PORT=3010  # Use different port
   ```

---

### Issue: "Cannot find module '@vendure/core'"

**Symptoms:**
```
Error: Cannot find module '@vendure/core'
```

**Solutions:**

1. **Reinstall dependencies:**
   ```bash
   cd apps/vendure-master
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
   cat apps/vendure-master/package.json | grep "@vendure/core"
   # Should show: "@vendure/core": "^3.1.0"
   ```

---

### Issue: "Admin UI shows blank page"

**Symptoms:**
- http://localhost:3001/admin loads but shows white/blank page
- Console errors about OSW or webpack

**Solutions:**

1. **Verify OSW version is pinned:**
   ```bash
   cat apps/vendure-master/package.json
   # Should show in pnpm.overrides:
   # "osw": "1.3.5"
   ```

2. **Clear cache and rebuild:**
   ```bash
   cd apps/vendure-master
   rm -rf node_modules/.cache
   pnpm run build
   pnpm run dev
   ```

3. **Check console for errors:**
   Open browser DevTools (F12) and check Console tab

---

### Issue: "Tables not created in database"

**Symptoms:**
- Database exists but has no tables
- Error: `relation "product" does not exist`

**Solutions:**

1. **Verify synchronize is enabled:**
   Edit `apps/vendure-master/src/vendure-config.ts`:
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
   cd apps/vendure-master
   pnpm run dev
   ```

3. **Check logs for schema creation:**
   Should see:
   ```
   query: CREATE TABLE "product" ...
   query: CREATE TABLE "product_variant" ...
   ```

4. **Manual migration (if needed):**
   ```bash
   cd apps/vendure-master
   pnpm run migration:run
   ```

---

### Issue: "Cannot login to Admin UI"

**Symptoms:**
- Credentials rejected
- "Invalid username or password" error

**Solutions:**

1. **Verify credentials:**
   Check `apps/vendure-master/.env`:
   ```bash
   SUPERADMIN_USERNAME=superadmin
   SUPERADMIN_PASSWORD=changeme_superadmin_pass
   ```

2. **Check database for admin:**
   ```bash
   docker exec entrepreneur-postgres-master psql -U vendure -d vendure_master \
     -c "SELECT identifier FROM administrator;"
   ```

3. **Reset database and restart:**
   ```bash
   ./tools/scripts/reset-databases.sh
   cd apps/vendure-master
   pnpm run dev
   # Re-run setup wizard
   ```

---

## Maintenance Tasks

### Update Vendure Version

```bash
cd apps/vendure-master
pnpm update @vendure/core @vendure/admin-ui @vendure/asset-server-plugin @vendure/email-plugin
pnpm install
```

### Backup Database

```bash
# Export database
docker exec entrepreneur-postgres-master pg_dump -U vendure vendure_master > vendure_master_backup.sql

# Restore database
cat vendure_master_backup.sql | docker exec -i entrepreneur-postgres-master psql -U vendure -d vendure_master
```

### View Logs

```bash
# Application logs (if running in background)
cd apps/vendure-master
pnpm run dev 2>&1 | tee vendure.log

# Database logs
docker logs entrepreneur-postgres-master
```

---

## Related Documentation

- [Vendure Ecommerce Installation](./vendure-ecommerce-install.md)
- [CLAUDE.md](../../CLAUDE.md) - Project development guide
- [Docker Setup](../setup/DOCKER_SETUP.md)
- [Vendure Official Docs](https://docs.vendure.io/)

---

## Quick Reference

### Commands Summary

| Task | Linux/macOS | Windows PowerShell |
|------|-------------|-------------------|
| **Install** | `./tools/scripts/setup-vendure.sh` | `.\tools\scripts\setup-vendure.ps1` |
| **Start** | `cd apps/vendure-master && pnpm run dev` | `cd apps\vendure-master; pnpm run dev` |
| **Stop** | `Ctrl+C` | `Ctrl+C` |
| **Reset DB** | `./tools/scripts/reset-databases.sh` | N/A (use Docker/psql manually) |
| **Access Admin** | `http://localhost:3001/admin` | `http://localhost:3001/admin` |

### Connection Details

| Parameter | Value |
|-----------|-------|
| **Database Host** | localhost (from host), postgres-master (from Docker) |
| **Database Port** | 5432 |
| **Database Name** | vendure_master |
| **Database User** | vendure |
| **API URL** | http://localhost:3000/shop-api |
| **Admin URL** | http://localhost:3001/admin |
| **GraphQL Playground** | http://localhost:3000/shop-api |

---

**Last Updated:** 2025-01-17
**Vendure Version:** 3.1.x
**Maintainer:** Entrepreneur-OS Team
