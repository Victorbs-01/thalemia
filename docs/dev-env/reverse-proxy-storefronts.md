# Reverse Proxy Setup for Storefronts

This document explains the reverse proxy architecture for Entrepreneur-OS storefronts and how to set up and troubleshoot the local development environment.

## Architecture Overview

The reverse proxy setup routes traffic from local domain names to the appropriate storefront containers, providing a production-like environment for local development.

```
┌──────────────────────────────────────────────────────────────────┐
│                        Your LAN Clients                           │
│                    (Browser, API Clients)                         │
└───────────────────────┬──────────────────────────────────────────┘
                        │
                        │ HTTP Requests
                        │
        ┌───────────────┼───────────────┬───────────────┐
        │               │               │               │
        │ master.local  │ shop1.local   │ api.local     │
        │               │               │               │
        └───────────────┼───────────────┴───────────────┘
                        │
                        ▼
        ┌───────────────────────────────────────────────┐
        │      Nginx Reverse Proxy (port 80)            │
        │      Container: entrepreneur-reverse-proxy     │
        └───────┬───────────────┬───────────────┬───────┘
                │               │               │
    ┌───────────▼────────┐ ┌───▼──────────┐ ┌──▼────────────────┐
    │  front-master:80   │ │front-shop-01 │ │vendure-ecommerce  │
    │  Container:        │ │   :80        │ │   :3002/shop-api  │
    │  entrepreneur-     │ │Container:    │ │ (future)          │
    │  front-master      │ │entrepreneur- │ │                   │
    │                    │ │front-shop-01 │ │                   │
    └────────────────────┘ └──────────────┘ └───────────────────┘
                        │
                        │ All on entrepreneur-network
                        │
        ┌───────────────┴───────────────────────────────┐
        │         Docker Network Bridge                 │
        │         entrepreneur-network                  │
        └───────────────────────────────────────────────┘
```

### Routing Rules

| Domain          | Target Container      | Purpose                           |
|-----------------|----------------------|-----------------------------------|
| `master.local`  | `front-master:80`    | Product Master / PIM Storefront   |
| `shop1.local`   | `front-shop-01:80`   | E-commerce Shop Storefront        |
| `api.local/shop-api` | `vendure-ecommerce:3002/shop-api` | Vendure Shop API (GraphQL) |

### Components

1. **Nginx Reverse Proxy** (`entrepreneur-reverse-proxy`)
   - Listens on host port 80
   - Routes requests based on domain name (virtual hosts)
   - Handles CORS headers for API access
   - Provides health check endpoints

2. **Front Master** (`entrepreneur-front-master`)
   - Vite-built React application
   - Served by internal nginx (multi-stage Dockerfile)
   - PIM/Product catalog interface

3. **Front Shop 01** (`entrepreneur-front-shop-01`)
   - Vite-built React application
   - Served by internal nginx (multi-stage Dockerfile)
   - E-commerce storefront interface

4. **Docker Network** (`entrepreneur-network`)
   - Shared bridge network for all services
   - Enables container-to-container communication
   - Defined in base `docker-compose.yml`

## Prerequisites

- Docker and Docker Compose installed
- pnpm installed (for building storefronts)
- At least 4GB RAM available
- Port 80 available on your host machine

## Setup Instructions

### 1. Configure Hosts File

Add the following entries to your hosts file to resolve the local domains:

**Linux/Mac** (`/etc/hosts`):
```bash
sudo nano /etc/hosts
```

**Windows** (`C:\Windows\System32\drivers\etc\hosts`):
```powershell
# Run as Administrator
notepad C:\Windows\System32\drivers\etc\hosts
```

Add these lines:
```
127.0.0.1  master.local
127.0.0.1  shop1.local
127.0.0.1  api.local
```

Save and close the file.

#### LAN Access (Optional)

To access the storefronts from other devices on your LAN, add entries pointing to your development machine's IP address:

```
192.168.1.100  master.local   # Replace with your dev machine's IP
192.168.1.100  shop1.local
192.168.1.100  api.local
```

**Note**: You'll need to configure your firewall to allow port 80 traffic.

### 2. Build the Storefront Images

From the repository root, build both storefront images:

```bash
# Build front-master
docker-compose -f docker-compose.storefronts.yml build front-master

# Build front-shop-01
docker-compose -f docker-compose.storefronts.yml build front-shop-01

# Or build both at once
docker-compose -f docker-compose.storefronts.yml build
```

**Note**: The initial build may take 5-10 minutes as it installs dependencies and builds the Vite applications.

### 3. Start the Infrastructure

First, ensure the base infrastructure is running (databases, redis, etc.):

```bash
docker-compose up -d
```

### 4. Start the Storefronts and Reverse Proxy

```bash
docker-compose -f docker-compose.yml -f docker-compose.storefronts.yml up -d
```

This command:
- Uses both compose files together
- Starts the reverse proxy
- Starts both storefront containers
- Connects everything to the `entrepreneur-network`

### 5. Verify the Setup

Check that all containers are running:

```bash
docker-compose -f docker-compose.yml -f docker-compose.storefronts.yml ps
```

You should see:
- `entrepreneur-reverse-proxy` - Up and healthy
- `entrepreneur-front-master` - Up and healthy
- `entrepreneur-front-shop-01` - Up and healthy

### 6. Access the Storefronts

Open your browser and navigate to:

- **Master Storefront**: http://master.local
- **Shop 01 Storefront**: http://shop1.local
- **API Endpoint** (when Vendure is running): http://api.local/shop-api

## Docker Compose Commands

### Start the Stack

```bash
# Start everything (infrastructure + storefronts + reverse proxy)
docker-compose -f docker-compose.yml -f docker-compose.storefronts.yml up -d

# Start only storefronts (assumes infrastructure is already running)
docker-compose -f docker-compose.storefronts.yml up -d
```

### Stop the Stack

```bash
# Stop storefronts and reverse proxy
docker-compose -f docker-compose.storefronts.yml down

# Stop everything including infrastructure
docker-compose -f docker-compose.yml -f docker-compose.storefronts.yml down
```

### Rebuild After Code Changes

```bash
# Rebuild specific storefront
docker-compose -f docker-compose.storefronts.yml build front-master
docker-compose -f docker-compose.storefronts.yml build front-shop-01

# Rebuild and restart
docker-compose -f docker-compose.storefronts.yml up -d --build
```

### View Logs

```bash
# All storefront services
docker-compose -f docker-compose.storefronts.yml logs -f

# Specific service
docker-compose -f docker-compose.storefronts.yml logs -f reverse-proxy
docker-compose -f docker-compose.storefronts.yml logs -f front-master
docker-compose -f docker-compose.storefronts.yml logs -f front-shop-01
```

### Check Container Status

```bash
# View running containers
docker-compose -f docker-compose.storefronts.yml ps

# Check health status
docker inspect entrepreneur-reverse-proxy --format='{{.State.Health.Status}}'
docker inspect entrepreneur-front-master --format='{{.State.Health.Status}}'
docker inspect entrepreneur-front-shop-01 --format='{{.State.Health.Status}}'
```

## Troubleshooting

### Port 80 Already in Use

**Symptoms**:
```
Error starting userland proxy: listen tcp4 0.0.0.0:80: bind: address already in use
```

**Solutions**:

1. **Check what's using port 80**:
   ```bash
   # Linux/Mac
   sudo lsof -i :80
   sudo netstat -tulpn | grep :80

   # Windows
   netstat -ano | findstr :80
   ```

2. **Common culprits**:
   - Apache/httpd: `sudo systemctl stop apache2` or `sudo systemctl stop httpd`
   - Nginx: `sudo systemctl stop nginx`
   - IIS (Windows): Stop in Services panel
   - Skype: Change Skype settings to not use port 80

3. **Alternative**: Change the reverse proxy port in `docker-compose.storefronts.yml`:
   ```yaml
   reverse-proxy:
     ports:
       - "8080:80"  # Use port 8080 instead
   ```
   Then access via `http://master.local:8080`

### Container Not Reachable / 502 Bad Gateway

**Symptoms**: Browser shows "502 Bad Gateway" when accessing `master.local` or `shop1.local`

**Diagnosis Steps**:

1. **Check if storefront containers are running**:
   ```bash
   docker ps | grep front-
   ```

2. **Check container health**:
   ```bash
   docker inspect entrepreneur-front-master --format='{{json .State.Health}}' | jq
   ```

3. **Check container logs for errors**:
   ```bash
   docker logs entrepreneur-front-master
   docker logs entrepreneur-front-shop-01
   ```

4. **Test direct access to container**:
   ```bash
   docker exec -it entrepreneur-reverse-proxy wget -O- http://front-master/health
   ```

**Common Fixes**:

- Ensure all containers are on `entrepreneur-network`:
  ```bash
  docker network inspect entrepreneur-network
  ```

- Restart the containers:
  ```bash
  docker-compose -f docker-compose.storefronts.yml restart
  ```

### DNS Resolution Not Working

**Symptoms**: Browser shows "This site can't be reached" or "Unknown host"

**Fixes**:

1. **Verify hosts file entries**:
   ```bash
   # Linux/Mac
   cat /etc/hosts | grep local

   # Windows
   type C:\Windows\System32\drivers\etc\hosts | findstr local
   ```

2. **Flush DNS cache**:
   ```bash
   # Linux
   sudo systemd-resolve --flush-caches

   # Mac
   sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder

   # Windows (as Administrator)
   ipconfig /flushdns
   ```

3. **Test with curl**:
   ```bash
   curl -v http://master.local
   curl -v http://shop1.local
   ```

### Reverse Proxy Configuration Errors

**Symptoms**: Nginx container exits immediately or shows "unhealthy" status

**Diagnosis**:

1. **Check nginx configuration syntax**:
   ```bash
   docker run --rm -v $(pwd)/infrastructure/nginx/reverse-proxy.conf:/etc/nginx/conf.d/default.conf:ro nginx:alpine nginx -t
   ```

2. **View reverse proxy logs**:
   ```bash
   docker logs entrepreneur-reverse-proxy
   ```

**Fix**: If configuration is invalid, edit `infrastructure/nginx/reverse-proxy.conf` and restart:
```bash
docker-compose -f docker-compose.storefronts.yml restart reverse-proxy
```

### Storefront Build Failures

**Symptoms**: `docker-compose build` fails with npm/pnpm errors

**Fixes**:

1. **Clear Docker build cache**:
   ```bash
   docker-compose -f docker-compose.storefronts.yml build --no-cache
   ```

2. **Check available disk space**:
   ```bash
   df -h
   ```

3. **Check Docker resources**:
   - Ensure Docker has enough memory allocated (at least 4GB)
   - Docker Desktop → Settings → Resources → Memory

4. **Review build logs**:
   ```bash
   docker-compose -f docker-compose.storefronts.yml build front-master 2>&1 | tee build.log
   ```

### CORS Errors When Accessing API

**Symptoms**: Browser console shows CORS errors when frontend calls API

**Fixes**:

1. **Verify CORS headers in reverse proxy config**:
   Check `infrastructure/nginx/reverse-proxy.conf` has proper CORS headers for the API server block.

2. **Test API directly**:
   ```bash
   curl -v -H "Origin: http://shop1.local" http://api.local/shop-api
   ```

3. **Check if Vendure is running** (when applicable):
   ```bash
   docker ps | grep vendure
   ```

### Health Checks Failing

**Symptoms**: Containers show as "unhealthy" in `docker ps`

**Diagnosis**:
```bash
# Check health check logs
docker inspect entrepreneur-front-master --format='{{range .State.Health.Log}}{{.Output}}{{end}}'
```

**Fixes**:

1. **Verify health endpoint works**:
   ```bash
   docker exec -it entrepreneur-front-master wget -O- http://localhost/health
   ```

2. **Adjust health check timing** in `docker-compose.storefronts.yml`:
   ```yaml
   healthcheck:
     interval: 60s      # Check less frequently
     timeout: 10s       # Longer timeout
     start_period: 30s  # More time to start up
   ```

## Network Architecture Details

All services communicate via the `entrepreneur-network` Docker bridge network:

```bash
# Inspect the network
docker network inspect entrepreneur-network

# View which containers are connected
docker network inspect entrepreneur-network --format='{{range .Containers}}{{.Name}} {{end}}'
```

Container DNS resolution works automatically within the network:
- `front-master` resolves to the front-master container
- `front-shop-01` resolves to the front-shop-01 container
- `vendure-ecommerce` will resolve to the Vendure container (when running)

## Security Considerations (Local Development)

This setup is designed for **local development only** and includes several security configurations that should be enhanced for production:

1. **No TLS/HTTPS**: All traffic is HTTP
2. **Permissive CORS**: API accepts requests from any origin (`*`)
3. **No authentication on reverse proxy**: Direct access to all services
4. **Exposed ports**: Infrastructure services (databases, etc.) expose ports to host

**For production deployment**, consider:
- Implementing TLS with Let's Encrypt or similar
- Restricting CORS to specific domains
- Adding authentication middleware to the reverse proxy
- Using secrets management for credentials
- Restricting network access with firewall rules

## Advanced Configuration

### Adding More Storefronts

To add additional storefronts:

1. Add a new service in `docker-compose.storefronts.yml`:
   ```yaml
   front-shop-02:
     build:
       context: .
       dockerfile: apps/storefront-vite/front-shop-02/Dockerfile
     container_name: entrepreneur-front-shop-02
     restart: unless-stopped
     networks:
       - entrepreneur-network
   ```

2. Add routing in `infrastructure/nginx/reverse-proxy.conf`:
   ```nginx
   upstream front_shop_02 {
       server front-shop-02:80;
   }

   server {
       listen 80;
       server_name shop2.local;
       location / {
           proxy_pass http://front_shop_02;
           # ... (same proxy settings as other servers)
       }
   }
   ```

3. Add to hosts file:
   ```
   127.0.0.1  shop2.local
   ```

### Using with Vendure Backend

When Vendure is running, the API will be accessible at `http://api.local/shop-api`.

Configure your storefront to use this endpoint:

```typescript
// In your Vite config or environment
const API_URL = 'http://api.local/shop-api';
```

## References

- [Nginx Reverse Proxy Documentation](https://docs.nginx.com/nginx/admin-guide/web-server/reverse-proxy/)
- [Docker Compose Networking](https://docs.docker.com/compose/networking/)
- [Vendure Documentation](https://docs.vendure.io)
- Main project documentation: [CLAUDE.md](../../CLAUDE.md)
