# Docker Volumes Layout

Complete inventory of all Docker volumes in the Entrepreneur-OS datacenter infrastructure.

## Table of Contents

- [Overview](#overview)
- [Naming Convention](#naming-convention)
- [Volume Inventory](#volume-inventory)
- [Backup Strategy](#backup-strategy)
- [Security Recommendations](#security-recommendations)
- [Volume Management](#volume-management)

---

## Overview

Docker volumes provide persistent storage for containerized services. This document catalogs all volumes in the Entrepreneur-OS platform, their purposes, locations, and backup requirements.

**Total Volumes:** 12+ volumes
**Total Estimated Size:** ~50-200GB (depends on usage)
**Naming Pattern:** `<service-name>-data` or `<service>-<type>-data`

---

## Naming Convention

All volumes in the Entrepreneur-OS platform follow a consistent naming pattern:

### Standard Pattern

```
<service-name>-data
```

**Examples:**
- `redis-data`
- `grafana-data`
- `n8n-data`

### Service-Specific Pattern

For services with multiple data types or instances:

```
<service>-<instance>-data
<service>-<type>-data
```

**Examples:**
- `postgres-master-data` (Vendure master instance)
- `postgres-ecommerce-data` (Vendure ecommerce instance)
- `gitea-postgres-data` (Gitea's dedicated PostgreSQL)

### Recommended Naming for New Services

When adding new services to the datacenter:

1. **Single data volume**: `<service>-data`
   - Example: `baserow-data`, `minio-data`

2. **Multiple instances**: `<service>-<instance>-data`
   - Example: `postgres-analytics-data`, `redis-cache-data`

3. **Different data types**: `<service>-<type>-data`
   - Example: `minio-storage-data`, `minio-config-data`

---

## Volume Inventory

### Database Volumes

| Volume Name | Service | Purpose | Mount Path | Backup Priority | Estimated Size |
|------------|---------|---------|------------|----------------|----------------|
| `postgres-master-data` | PostgreSQL (Vendure Master) | Product catalog, PIM data, master instance database | `/var/lib/postgresql/data` | **HIGH** | 5-20 GB |
| `postgres-ecommerce-data` | PostgreSQL (Vendure Ecommerce) | Orders, customers, inventory, retail operations | `/var/lib/postgresql/data` | **HIGH** | 10-50 GB |
| `gitea-postgres-data` | PostgreSQL (Gitea) | Git metadata, users, repositories database | `/var/lib/postgresql/data` | **HIGH** | 1-5 GB |

**Notes:**
- PostgreSQL databases contain critical business data
- Require daily automated backups
- Use `pg_dump` or volume snapshots
- Test restore procedures monthly

---

### Cache & Session Volumes

| Volume Name | Service | Purpose | Mount Path | Backup Priority | Estimated Size |
|------------|---------|---------|------------|----------------|----------------|
| `redis-data` | Redis | Shared cache layer for Vendure instances, session storage | `/data` | **MEDIUM** | 500 MB - 2 GB |

**Notes:**
- Redis contains ephemeral cache data
- Can be rebuilt from source systems
- Backup recommended but not critical
- Enable RDB/AOF persistence for session data

---

### Application Data Volumes

| Volume Name | Service | Purpose | Mount Path | Backup Priority | Estimated Size |
|------------|---------|---------|------------|----------------|----------------|
| `gitea-data` | Gitea | Git repositories, LFS objects, attachments, SSH keys, configurations | `/data` | **HIGH** | 5-100 GB |
| `n8n-data` | n8n | Automation workflows, credentials (encrypted), execution history | `/home/node/.n8n` | **HIGH** | 1-5 GB |
| `grafana-data` | Grafana | Dashboards, data sources, alerting rules, user preferences | `/var/lib/grafana` | **MEDIUM** | 500 MB - 2 GB |
| `prometheus-data` | Prometheus | Time-series metrics data, alerting rules, recording rules | `/prometheus` | **MEDIUM** | 10-50 GB |
| `uptime-kuma-data` | Uptime Kuma | Uptime monitors, notifications, status page configurations | `/app/data` | **MEDIUM** | 500 MB - 2 GB |

**Notes:**
- **Gitea**: Contains all source code repositories - critical backup
- **n8n**: Workflows are critical for business automation
- **Grafana**: Dashboards can be exported to JSON (Infrastructure as Code)
- **Prometheus**: Metrics are ephemeral but useful for historical analysis
- **Uptime Kuma**: Monitor configurations should be backed up

---

### Monitoring & Security Volumes

| Volume Name | Service | Purpose | Mount Path | Backup Priority | Estimated Size |
|------------|---------|---------|------------|----------------|----------------|
| `opensearch-data` | OpenSearch | SIEM logs, security events, application logs, HELK stack data | `/usr/share/opensearch/data` | **HIGH** | 50-500 GB |
| `opensearch-dashboards-data` | OpenSearch Dashboards | Saved searches, visualizations, security dashboards | `/usr/share/opensearch-dashboards/data` | **MEDIUM** | 1-5 GB |

**Notes:**
- **OpenSearch**: Critical for security monitoring (SOC/SIEM)
- Implements tiered storage (hot/warm/cold)
- Hot tier: 7 days (SSD)
- Warm tier: 30 days (HDD)
- Cold tier: 90 days (S3/MinIO)
- Retention: 180 days total
- See `docs/security/SOC-NOC-DLP-UEBA-ARCHITECTURE.md` for details

---

### Future Volumes (Planned)

| Volume Name | Service | Purpose | Mount Path | Backup Priority | Estimated Size |
|------------|---------|---------|------------|----------------|----------------|
| `baserow-data` | Baserow | No-code database, operational data tables | `/baserow/data` | **HIGH** | 5-20 GB |
| `minio-storage-data` | MinIO | S3-compatible object storage, cold tier for OpenSearch | `/data` | **MEDIUM** | 100-500 GB |
| `wazuh-data` | Wazuh | Security agent data, vulnerability scans, compliance reports | `/var/ossec/data` | **HIGH** | 10-50 GB |
| `vector-data` | Vector | Log buffering, transformation state | `/var/lib/vector` | **LOW** | 1-5 GB |
| `redpanda-data` | Redpanda | Streaming message buffer (Kafka alternative) | `/var/lib/redpanda/data` | **MEDIUM** | 10-50 GB |

---

## Backup Strategy

### Backup Priority Levels

**HIGH Priority (Daily Backups + Off-site)**
- All PostgreSQL databases
- Gitea repositories
- n8n workflows
- OpenSearch SIEM data (hot tier)
- Critical for business continuity
- Require tested restore procedures
- Store off-site or on separate storage

**MEDIUM Priority (Weekly Backups)**
- Grafana dashboards
- Prometheus metrics
- Uptime Kuma configurations
- OpenSearch Dashboards
- Redis (if using persistence)
- Can be rebuilt or reconfigured
- Keep last 4-8 weeks of backups

**LOW Priority (Monthly or On-Demand)**
- Vector buffering state
- Ephemeral caches
- Logs older than retention period
- Can be regenerated from source systems

### Backup Methods

**Method 1: Volume Snapshots (Recommended)**

```bash
# Backup a single volume
docker run --rm \
  -v <volume-name>:/data \
  -v ~/backups:/backup \
  alpine tar czf /backup/<volume-name>-$(date +%Y%m%d).tar.gz -C /data .

# Example: Backup gitea-data
docker run --rm \
  -v gitea-data:/data \
  -v ~/backups/gitea:/backup \
  alpine tar czf /backup/gitea-data-$(date +%Y%m%d).tar.gz -C /data .
```

**Method 2: Application-Specific Backups**

```bash
# PostgreSQL dump
docker exec <postgres-container> pg_dump -U <user> <database> > backup.sql

# Gitea built-in backup
docker exec -u git <gitea-container> gitea dump

# n8n export workflows
docker exec <n8n-container> n8n export:workflow --all --output=/backup/
```

**Method 3: Filesystem-Level Snapshots**

For LVM or ZFS storage:
```bash
# LVM snapshot
lvcreate -L 10G -s -n backup-snap /dev/vg/lv

# ZFS snapshot
zfs snapshot pool/volumes@backup-$(date +%Y%m%d)
```

### Automated Backup Schedule

Create backup scripts in `tools/scripts/`:

**Daily Backups (3 AM):**
- All PostgreSQL databases
- Gitea repositories
- n8n workflows
- OpenSearch hot tier

**Weekly Backups (Sunday 2 AM):**
- Grafana dashboards
- Prometheus metrics
- Uptime Kuma configs

**Monthly Backups (1st of month):**
- Full system snapshot
- Archive to cold storage

**Cron configuration:**

```bash
# Edit crontab
crontab -e

# Add backup jobs
0 3 * * * /home/user/thalemia/tools/scripts/backup-daily.sh
0 2 * * 0 /home/user/thalemia/tools/scripts/backup-weekly.sh
0 1 1 * * /home/user/thalemia/tools/scripts/backup-monthly.sh
```

### Backup Storage Locations

**Local Backups:**
- `/home/user/backups/` - Daily/weekly backups
- Retention: 30 days

**Off-site Backups:**
- MinIO S3 bucket (when deployed)
- External USB drive (for critical data)
- Remote datacenter sync (future phase)

**Backup Rotation:**
- Daily: Keep last 7 days
- Weekly: Keep last 4 weeks
- Monthly: Keep last 12 months
- Yearly: Keep indefinitely (annual snapshot)

---

## Security Recommendations

### Encryption

**Volumes Requiring Encryption:**

| Volume | Encryption Method | Reason |
|--------|------------------|---------|
| `postgres-master-data` | LUKS or dm-crypt | Contains customer data, pricing |
| `postgres-ecommerce-data` | LUKS or dm-crypt | Contains PII, payment info, orders |
| `gitea-data` | LUKS or dm-crypt | Contains source code, SSH keys |
| `n8n-data` | LUKS or dm-crypt | Contains API credentials (encrypted by n8n) |
| `opensearch-data` | LUKS or dm-crypt | Contains security logs, sensitive events |

**Encryption Setup (LUKS):**

```bash
# Create encrypted volume
cryptsetup luksFormat /dev/sdX
cryptsetup open /dev/sdX encrypted-volume
mkfs.ext4 /dev/mapper/encrypted-volume

# Mount encrypted volume
mount /dev/mapper/encrypted-volume /var/lib/docker/volumes/
```

**Alternative: Docker Volume Encryption Plugin**

```bash
# Install volume encryption plugin
docker plugin install docker-volume-encryption

# Create encrypted volume
docker volume create --driver docker-volume-encryption \
  --opt keyfile=/path/to/key \
  encrypted-postgres-data
```

### Access Control

**Volume Permissions:**

```bash
# Check volume ownership
docker volume inspect <volume-name> | grep Mountpoint

# Verify permissions
ls -la $(docker volume inspect <volume-name> --format '{{ .Mountpoint }}')

# Secure permissions (root only)
sudo chmod 700 /var/lib/docker/volumes/<volume-name>/_data
```

**Container User Mapping:**

Ensure containers run as non-root users:

```yaml
# docker-compose.yml
services:
  gitea:
    user: "1000:1000"  # Map to host user
    volumes:
      - gitea-data:/data
```

### Secrets Management

**Never store in volumes directly:**
- API keys
- Database passwords
- SSL private keys
- OAuth tokens

**Use Docker secrets or environment variables:**

```yaml
services:
  postgres:
    environment:
      POSTGRES_PASSWORD_FILE: /run/secrets/db_password
    secrets:
      - db_password

secrets:
  db_password:
    file: ./secrets/db_password.txt
```

### Security Monitoring

**Monitor volume access:**

```bash
# Install auditd rules for volume access
cat << EOF > /etc/audit/rules.d/docker-volumes.rules
-w /var/lib/docker/volumes/ -p wa -k docker_volumes
EOF

# Reload audit rules
auditctl -R /etc/audit/rules.d/docker-volumes.rules
```

**Send volume access events to OpenSearch:**

Configure Vector or Filebeat to ship audit logs to the SIEM stack.

---

## Volume Management

### Listing All Volumes

```bash
# List all Docker volumes
docker volume ls

# Show volume details
docker volume inspect <volume-name>

# Find unused volumes
docker volume ls -qf dangling=true
```

### Volume Disk Usage

```bash
# Check Docker disk usage
docker system df -v

# Check specific volume size
docker system df -v | grep <volume-name>

# Manual check
sudo du -sh /var/lib/docker/volumes/<volume-name>/_data
```

### Cleaning Up Volumes

**Remove unused volumes:**

```bash
# Remove all unused volumes (CAUTION!)
docker volume prune

# Remove specific volume (service must be stopped)
docker-compose -f docker-compose.yml down
docker volume rm <volume-name>
```

### Volume Migration

**Moving volumes to new storage:**

```bash
# Stop services
docker-compose down

# Backup volume
docker run --rm -v <old-volume>:/data -v /backup:/backup \
  alpine tar czf /backup/volume.tar.gz -C /data .

# Create new volume on new storage
docker volume create --driver local \
  --opt type=none \
  --opt o=bind \
  --opt device=/mnt/new-storage/<volume-name> \
  <volume-name>

# Restore data
docker run --rm -v <new-volume>:/data -v /backup:/backup \
  alpine tar xzf /backup/volume.tar.gz -C /data

# Start services
docker-compose up -d
```

### Volume Health Checks

**Check filesystem integrity:**

```bash
# For ext4
sudo e2fsck -f /dev/mapper/encrypted-volume

# For XFS
sudo xfs_repair /dev/mapper/encrypted-volume
```

**Monitor volume I/O:**

```bash
# Install iotop
sudo apt install iotop

# Monitor I/O
sudo iotop -o
```

---

## Directory Mapping

### Current Volume Storage Locations

**Default Docker volumes path:**
```
/var/lib/docker/volumes/
```

**Volume internal structure:**
```
/var/lib/docker/volumes/
├── gitea-data/
│   └── _data/                    # Actual data directory
│       ├── git/                  # Git repositories
│       ├── gitea/                # Gitea configs
│       └── ssh/                  # SSH keys
├── postgres-master-data/
│   └── _data/
│       └── pg_data/              # PostgreSQL data files
├── n8n-data/
│   └── _data/
│       ├── workflows/            # n8n workflows
│       └── credentials/          # Encrypted credentials
└── ...
```

### Recommended Datacenter Layout

For larger deployments, consider dedicated storage:

```
/mnt/datacenter/
├── databases/                    # High-performance SSD
│   ├── postgres-master/
│   ├── postgres-ecommerce/
│   └── gitea-postgres/
├── applications/                 # Standard SSD
│   ├── gitea-repos/
│   ├── n8n-workflows/
│   └── grafana-dashboards/
├── monitoring/                   # High-capacity HDD
│   ├── opensearch-hot/          # Recent logs (SSD)
│   ├── opensearch-warm/         # Older logs (HDD)
│   └── prometheus-metrics/
└── backups/                      # Backup storage
    ├── daily/
    ├── weekly/
    └── monthly/
```

**Bind mount volumes to custom paths:**

```yaml
volumes:
  postgres-master-data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /mnt/datacenter/databases/postgres-master
```

---

## Quick Reference

### Common Volume Operations

```bash
# List all volumes
docker volume ls

# Inspect volume
docker volume inspect <volume-name>

# Check volume size
docker system df -v | grep <volume-name>

# Backup volume
docker run --rm -v <volume>:/data -v ~/backups:/backup \
  alpine tar czf /backup/<volume>-$(date +%Y%m%d).tar.gz -C /data .

# Restore volume
docker run --rm -v <volume>:/data -v ~/backups:/backup \
  alpine tar xzf /backup/<volume>.tar.gz -C /data

# Remove volume (service must be stopped)
docker volume rm <volume-name>

# Clean up unused volumes
docker volume prune
```

---

## Related Documentation

- [Gitea Setup Guide](../dev-env/gitea-setup.md) - Gitea volume backup procedures
- [Infrastructure Index](./index.md) - Overall infrastructure overview
- [Security Architecture](../security/SOC-NOC-DLP-UEBA-ARCHITECTURE.md) - Security monitoring volumes
- [Database Management](../runbooks/) - PostgreSQL backup procedures

---

**Last Updated:** 2025-01-17
**Maintained By:** DevOps Team
**Review Cycle:** Quarterly
