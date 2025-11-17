# Gitea Setup Guide

Complete setup guide for Gitea Git hosting in your local datacenter.

## Table of Contents

- [Architecture Overview](#architecture-overview)
- [Quick Start](#quick-start)
- [First-Time Configuration](#first-time-configuration)
- [LAN Access Configuration](#lan-access-configuration)
- [Developer Workflow](#developer-workflow)
- [Backup & Restore](#backup--restore)
- [Future Integration](#future-integration)
- [Troubleshooting](#troubleshooting)

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                     Entrepreneur-OS Network                      │
│                    (entrepreneur-network)                        │
│                                                                   │
│  ┌──────────────┐         ┌────────────────┐                    │
│  │              │         │                │                    │
│  │    Gitea     │────────▶│ gitea-postgres │                    │
│  │  Container   │         │   (port 5432)  │                    │
│  │              │         │                │                    │
│  └──────┬───────┘         └────────┬───────┘                    │
│         │                          │                             │
│    Port │3000                 Volume│gitea_postgres_data         │
│    Port │22                         │                             │
│         │                           │                             │
│  Volume │gitea_data                 │                             │
│         │                           │                             │
└─────────┼───────────────────────────┼─────────────────────────────┘
          │                           │
          │ Exposed Ports             │ PostgreSQL Data
          │                           │ (persistent storage)
          ▼                           ▼
    Host: 3080 → HTTP             /var/lib/postgresql/data
    Host: 2222 → SSH

┌─────────────────────────────────────────────────────────────────┐
│                         LAN Access                               │
│                                                                   │
│  Desktop/Laptop ────▶ http://gitea.local:3080                   │
│  (192.168.x.x)       git clone git@gitea.local:user/repo.git    │
│                                                                   │
│  Other LAN device ──▶ http://192.168.x.x:3080                   │
│                      git clone git@192.168.x.x:user/repo.git    │
└─────────────────────────────────────────────────────────────────┘
```

**Key Components:**

- **Gitea Container**: Git server with web UI
  - Internal HTTP: port 3000
  - Internal SSH: port 22
  - External HTTP: port 3080 (host)
  - External SSH: port 2222 (host)

- **PostgreSQL Database**: Dedicated database for Gitea
  - Internal port: 5432
  - Database: `gitea`
  - User: `gitea`
  - Password: `gitea123` (change in production)

- **Volumes**:
  - `gitea_data`: Git repositories, configurations, attachments
  - `gitea_postgres_data`: Database persistent storage

- **Network**: Uses existing `entrepreneur-network` (bridge mode)

---

## Quick Start

### Prerequisites

- Docker and Docker Compose installed
- Port 3080 available (Vendure uses 3000-3003)
- Port 2222 available for SSH
- `entrepreneur-network` already created (exists in main docker-compose.yml)

### Start Gitea

```bash
# Navigate to project root
cd /home/user/thalemia

# Start Gitea stack
docker-compose -f docker-compose.gitea.yml up -d

# Verify services are running
docker-compose -f docker-compose.gitea.yml ps

# Check logs
docker-compose -f docker-compose.gitea.yml logs -f gitea

# Wait for healthy status (may take 30-60 seconds on first start)
docker-compose -f docker-compose.gitea.yml ps | grep healthy
```

**Expected output:**
```
entrepreneur-gitea-postgres   running (healthy)
entrepreneur-gitea            running (healthy)
```

### Access Gitea

- **HTTP Web UI**: http://localhost:3080
- **LAN Access**: http://gitea.local:3080 (after configuring /etc/hosts)

---

## First-Time Configuration

When you access Gitea for the first time (http://localhost:3080), you'll see the installation wizard.

### Database Configuration

Most settings are **pre-configured** via environment variables. Verify:

**Database Settings:**
- Database Type: `PostgreSQL`
- Host: `gitea-postgres:5432`
- Username: `gitea`
- Password: `gitea123`
- Database Name: `gitea`

**Do NOT change these** - they match your docker-compose.gitea.yml configuration.

### Server Configuration

**General Settings:**
- Site Title: `Entrepreneur-OS Git`
- Repository Root Path: `/data/git/repositories` (pre-configured)
- Git LFS Root Path: `/data/git/lfs` (pre-configured)
- Run As Username: `git` (pre-configured)

**Server Domain:**
- SSH Server Domain: `gitea.local`
- Gitea Base URL: `http://gitea.local:3080/`
- SSH Port: `2222`
- HTTP Port: `3000` (internal)
- Gitea Listen Port: `3000` (internal)

### Administrator Account

**Create your admin user:**
- Admin Username: `admin` (or your preferred username)
- Password: (choose a strong password)
- Email: `admin@gitea.local`

**Important:** This is the only time you can create the admin account via the UI. Write down the credentials!

### Optional Settings

- **Email Settings**: Skip for LAN-only deployment (no SMTP needed)
- **Server and Third-Party Settings**: Use defaults
- **Enable OpenID signin**: Leave disabled for LAN use

Click **"Install Gitea"** to complete setup.

---

## LAN Access Configuration

To access Gitea from other devices on your LAN using `gitea.local` domain:

### Linux / macOS

Edit `/etc/hosts`:

```bash
sudo nano /etc/hosts
```

Add the following line (replace with your server's IP):

```
192.168.1.100  gitea.local
```

### Windows

Edit `C:\Windows\System32\drivers\etc\hosts` as Administrator:

```
192.168.1.100  gitea.local
```

### Verification

Test from any LAN device:

```bash
# Test HTTP access
curl http://gitea.local:3080

# Test SSH access
ssh -T -p 2222 git@gitea.local
```

Expected SSH response:
```
Hi there, You've successfully authenticated, but Gitea does not provide shell access.
```

---

## Developer Workflow

### Strategy: GitHub as Origin, Gitea as LAN Mirror

This setup keeps GitHub as your primary remote while using Gitea for fast LAN access during development.

### Initial Setup

**1. Clone from GitHub (as usual):**
```bash
git clone https://github.com/Victorbs-01/thalemia.git
cd thalemia
```

**2. Add Gitea as a remote:**
```bash
git remote add gitea git@gitea.local:Victorbs-01/thalemia.git
# Or using HTTP:
git remote add gitea http://gitea.local:3080/Victorbs-01/thalemia.git
```

**3. Verify remotes:**
```bash
git remote -v
```

Expected output:
```
origin  https://github.com/Victorbs-01/thalemia.git (fetch)
origin  https://github.com/Victorbs-01/thalemia.git (push)
gitea   git@gitea.local:Victorbs-01/thalemia.git (fetch)
gitea   git@gitea.local:Victorbs-01/thalemia.git (push)
```

### Creating a Mirror Repository in Gitea

**Option 1: Manual Repository Creation**

1. Log in to Gitea web UI: http://gitea.local:3080
2. Click **"+"** → **"New Repository"**
3. Fill in:
   - Owner: `Victorbs-01` (or your organization)
   - Repository Name: `thalemia`
   - Visibility: Private
4. Click **"Create Repository"**
5. Push your local repository:
   ```bash
   git push gitea main
   git push gitea --all     # Push all branches
   git push gitea --tags    # Push all tags
   ```

**Option 2: Pull Mirror (Automatic Sync from GitHub)**

1. Log in to Gitea web UI
2. Click **"+"** → **"New Migration"**
3. Select **"Git"** as migration type
4. Configure:
   - Clone Address: `https://github.com/Victorbs-01/thalemia.git`
   - Repository Name: `thalemia`
   - **Check "This repository will be a mirror"**
   - Mirror Interval: `8h` (or your preferred interval)
5. Click **"Migrate Repository"**

Gitea will automatically pull updates from GitHub every 8 hours.

### Daily Workflow

**Fetching updates:**
```bash
# Fetch from GitHub (slower, over internet)
git fetch origin

# Fetch from Gitea (faster, over LAN)
git fetch gitea
```

**Pushing changes:**
```bash
# Push to GitHub (primary)
git push origin main

# Also push to Gitea for LAN team members
git push gitea main

# Or push to both simultaneously
git push origin main && git push gitea main
```

**Pulling changes (from LAN):**
```bash
# Pull from Gitea (fast LAN access)
git pull gitea main
```

### SSH Key Configuration

For passwordless SSH access to Gitea:

**1. Generate SSH key (if you don't have one):**
```bash
ssh-keygen -t ed25519 -C "your.email@example.com"
```

**2. Copy public key:**
```bash
cat ~/.ssh/id_ed25519.pub
```

**3. Add to Gitea:**
- Go to http://gitea.local:3080
- User Settings → SSH / GPG Keys → Add Key
- Paste your public key
- Click "Add Key"

**4. Test connection:**
```bash
ssh -T -p 2222 git@gitea.local
```

### Team Collaboration (LAN)

Other developers on your LAN can clone directly from Gitea:

```bash
# Clone via SSH
git clone git@gitea.local:Victorbs-01/thalemia.git

# Clone via HTTP
git clone http://gitea.local:3080/Victorbs-01/thalemia.git

# Add GitHub as upstream
cd thalemia
git remote add upstream https://github.com/Victorbs-01/thalemia.git
```

---

## Backup & Restore

### What to Backup

**Critical volumes:**
- `gitea_data` - Git repositories, configurations, attachments, LFS objects
- `gitea_postgres_data` - Database (users, permissions, issues, PRs)

### Backup Procedures

**Option 1: Volume Backup (Recommended)**

```bash
# Stop Gitea services
docker-compose -f docker-compose.gitea.yml stop

# Create backup directory
mkdir -p ~/backups/gitea/$(date +%Y%m%d)

# Backup gitea_data volume
docker run --rm \
  -v gitea_data:/data \
  -v ~/backups/gitea/$(date +%Y%m%d):/backup \
  alpine tar czf /backup/gitea_data.tar.gz -C /data .

# Backup gitea_postgres_data volume
docker run --rm \
  -v gitea_postgres_data:/data \
  -v ~/backups/gitea/$(date +%Y%m%d):/backup \
  alpine tar czf /backup/gitea_postgres_data.tar.gz -C /data .

# Restart services
docker-compose -f docker-compose.gitea.yml start
```

**Option 2: PostgreSQL Dump (Database only)**

```bash
# Backup database to SQL dump
docker exec entrepreneur-gitea-postgres pg_dump -U gitea gitea > ~/backups/gitea/gitea_db_$(date +%Y%m%d).sql
```

**Option 3: Gitea Built-in Backup**

```bash
# Create complete Gitea backup (repositories + database)
docker exec -u git entrepreneur-gitea gitea dump -c /data/gitea/conf/app.ini

# Copy backup file from container
docker cp entrepreneur-gitea:/app/gitea-dump-*.zip ~/backups/gitea/
```

### Restore Procedures

**Restoring from Volume Backup:**

```bash
# Stop services
docker-compose -f docker-compose.gitea.yml down

# Remove old volumes
docker volume rm gitea_data gitea_postgres_data

# Recreate volumes
docker volume create gitea_data
docker volume create gitea_postgres_data

# Restore gitea_data
docker run --rm \
  -v gitea_data:/data \
  -v ~/backups/gitea/20250117:/backup \
  alpine tar xzf /backup/gitea_data.tar.gz -C /data

# Restore gitea_postgres_data
docker run --rm \
  -v gitea_postgres_data:/data \
  -v ~/backups/gitea/20250117:/backup \
  alpine tar xzf /backup/gitea_postgres_data.tar.gz -C /data

# Restart services
docker-compose -f docker-compose.gitea.yml up -d
```

**Restoring from PostgreSQL Dump:**

```bash
# Start only PostgreSQL
docker-compose -f docker-compose.gitea.yml up -d gitea-postgres

# Wait for PostgreSQL to be ready
sleep 10

# Restore database
docker exec -i entrepreneur-gitea-postgres psql -U gitea -d gitea < ~/backups/gitea/gitea_db_20250117.sql

# Start Gitea
docker-compose -f docker-compose.gitea.yml up -d gitea
```

### Automated Backup Script

Create a cron job to backup daily:

```bash
# Edit crontab
crontab -e

# Add daily backup at 3 AM
0 3 * * * /home/user/thalemia/tools/scripts/backup-gitea.sh
```

**Backup script** (create at `tools/scripts/backup-gitea.sh`):

```bash
#!/bin/bash
BACKUP_DIR=~/backups/gitea/$(date +%Y%m%d)
mkdir -p $BACKUP_DIR

# Volume backups
docker run --rm -v gitea_data:/data -v $BACKUP_DIR:/backup alpine tar czf /backup/gitea_data.tar.gz -C /data .
docker run --rm -v gitea_postgres_data:/data -v $BACKUP_DIR:/backup alpine tar czf /backup/gitea_postgres_data.tar.gz -C /data .

# Keep only last 30 days
find ~/backups/gitea -type d -mtime +30 -exec rm -rf {} \;
```

### SSH Keys Backup

Important SSH keys and credentials are stored in:
- `gitea_data:/data/git/.ssh/` - Gitea's SSH keys
- `gitea_data:/data/gitea/conf/app.ini` - Gitea configuration (includes SECRET_KEY and INTERNAL_TOKEN)

These are included in the `gitea_data` volume backup.

### Recovery Testing

**Test your backups regularly:**

```bash
# 1. Create test environment
docker-compose -f docker-compose.gitea.yml -p gitea-test up -d

# 2. Restore backup to test environment
# (follow restore procedures above with -p gitea-test flag)

# 3. Verify data integrity
docker exec gitea-test-gitea gitea doctor check --all

# 4. Cleanup test environment
docker-compose -f docker-compose.gitea.yml -p gitea-test down -v
```

---

## Future Integration

### Reverse Proxy (Nginx/Caddy)

When you're ready to add Gitea behind a reverse proxy:

**Add to `infrastructure/nginx/reverse-proxy.conf`:**

```nginx
upstream gitea {
    server gitea:3000;  # Internal container port
}

server {
    listen 80;
    server_name git.local;

    client_max_body_size 50M;  # Allow large pushes

    location / {
        proxy_pass http://gitea;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # WebSocket support (for notifications)
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
```

**Update docker-compose.gitea.yml:**

```yaml
services:
  gitea:
    # Remove port 3080 mapping (nginx will handle it)
    ports:
      - '2222:22'  # Keep SSH direct
    environment:
      - GITEA__server__ROOT_URL=http://git.local/
```

Access via: `http://git.local` (port 80, standard HTTP)

### CI/CD Integration (Future Phase)

Gitea supports:
- **Gitea Actions** (GitHub Actions compatible)
- **Drone CI** (mentioned in TODO.md)
- **Jenkins** webhooks
- **Custom webhooks** for n8n automation

This will be configured in a future phase (not part of current setup).

### MCP Git Integration

When setting up MCP (Model Context Protocol) Git server:

```bash
# MCP server can connect directly to Gitea
MCP_GIT_URL=http://gitea:3000  # Internal network access
```

Reference: `TODO.md` line 21 mentions "montar el mcp-git con gitea+drone"

---

## Troubleshooting

### Services Not Starting

**Check logs:**
```bash
docker-compose -f docker-compose.gitea.yml logs gitea
docker-compose -f docker-compose.gitea.yml logs gitea-postgres
```

**Common issues:**

1. **Port 3080 already in use:**
   ```bash
   # Check what's using port 3080
   sudo lsof -i :3080

   # Change host port in docker-compose.gitea.yml
   ports:
     - '3090:3000'  # Use different host port
   ```

2. **Port 2222 already in use:**
   ```bash
   # Check what's using port 2222
   sudo lsof -i :2222

   # Change SSH port
   ports:
     - '2223:22'
   ```

3. **Database connection failed:**
   ```bash
   # Check PostgreSQL is healthy
   docker exec entrepreneur-gitea-postgres pg_isready -U gitea

   # Restart PostgreSQL
   docker-compose -f docker-compose.gitea.yml restart gitea-postgres
   ```

### Cannot Access Web UI

**Check Gitea is running:**
```bash
docker ps | grep gitea
```

**Check health status:**
```bash
docker inspect entrepreneur-gitea | grep -A 10 Health
```

**Test from inside container:**
```bash
docker exec entrepreneur-gitea wget -O- http://localhost:3000
```

**Check firewall:**
```bash
sudo ufw status
sudo ufw allow 3080/tcp
sudo ufw allow 2222/tcp
```

### SSH Authentication Failed

**Check SSH key is added:**
- Go to http://gitea.local:3080/user/settings/keys
- Verify your public key is listed

**Test SSH connection:**
```bash
ssh -vT -p 2222 git@gitea.local
```

**Check SSH server in container:**
```bash
docker exec entrepreneur-gitea ps aux | grep sshd
```

**Verify SSH port mapping:**
```bash
docker port entrepreneur-gitea
```

Expected output:
```
22/tcp -> 0.0.0.0:2222
3000/tcp -> 0.0.0.0:3080
```

### Git Push/Pull Fails

**Large repository push fails:**

Edit `docker-compose.gitea.yml`:
```yaml
environment:
  - GITEA__server__LFS_MAX_FILE_SIZE=100  # MB
  - GITEA__repository__UPLOAD_MAX_SIZE=50  # MB
```

Restart:
```bash
docker-compose -f docker-compose.gitea.yml restart gitea
```

**Clone fails with "repository not found":**

Check repository visibility:
- Make sure repository is not private, or
- Use authenticated clone URL: `http://username@gitea.local:3080/org/repo.git`

### Performance Issues

**Check container resources:**
```bash
docker stats entrepreneur-gitea entrepreneur-gitea-postgres
```

**Increase container limits** (if needed):

Edit `docker-compose.gitea.yml`:
```yaml
services:
  gitea:
    deploy:
      resources:
        limits:
          memory: 2G
          cpus: '2'
```

### Database Issues

**Reset database (CAUTION: destroys all data):**
```bash
docker-compose -f docker-compose.gitea.yml down
docker volume rm gitea_postgres_data
docker-compose -f docker-compose.gitea.yml up -d
```

**Check database size:**
```bash
docker exec entrepreneur-gitea-postgres psql -U gitea -d gitea -c "SELECT pg_size_pretty(pg_database_size('gitea'));"
```

### Disk Space

**Check volume sizes:**
```bash
docker system df -v | grep gitea
```

**Clean up unused data:**
```bash
# Cleanup in Gitea (garbage collection)
docker exec -u git entrepreneur-gitea gitea admin regenerate hooks
docker exec -u git entrepreneur-gitea gitea admin regenerate keys
```

---

## Additional Resources

- **Gitea Documentation**: https://docs.gitea.io
- **Gitea Configuration Cheat Sheet**: https://docs.gitea.io/en-us/config-cheat-sheet/
- **Gitea Database Preparation**: https://docs.gitea.io/en-us/database-prep/
- **Gitea Backup and Restore**: https://docs.gitea.io/en-us/backup-and-restore/

---

## Quick Command Reference

```bash
# Start Gitea
docker-compose -f docker-compose.gitea.yml up -d

# Stop Gitea
docker-compose -f docker-compose.gitea.yml down

# View logs
docker-compose -f docker-compose.gitea.yml logs -f

# Restart Gitea
docker-compose -f docker-compose.gitea.yml restart gitea

# Backup volumes
docker run --rm -v gitea_data:/data -v ~/backups:/backup alpine tar czf /backup/gitea_data.tar.gz -C /data .

# Access Gitea CLI
docker exec -it -u git entrepreneur-gitea gitea --help

# Database access
docker exec -it entrepreneur-gitea-postgres psql -U gitea -d gitea

# Check service health
docker-compose -f docker-compose.gitea.yml ps
```
