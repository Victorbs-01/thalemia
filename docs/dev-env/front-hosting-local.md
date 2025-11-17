# Local Datacenter Hosting Guide

Guide for deploying TanStack Start storefronts in your local datacenter (not Vercel/cloud).

## Docker Deployment

### Build Docker Images

```bash
# Build front-master
docker build -t entrepreneur-os/front-master:latest \
  -f apps/storefront-vite/front-master/Dockerfile .

# Build front-shop-01
docker build -t entrepreneur-os/front-shop-01:latest \
  -f apps/storefront-vite/front-shop-01/Dockerfile .
```

### Run Containers

```bash
# Run front-master
docker run -d \
  --name front-master \
  -p 3011:80 \
  --env-file apps/storefront-vite/front-master/.env \
  entrepreneur-os/front-master:latest

# Run front-shop-01
docker run -d \
  --name front-shop-01 \
  -p 3012:80 \
  --env-file apps/storefront-vite/front-shop-01/.env \
  entrepreneur-os/front-shop-01:latest
```

### Docker Compose

Add to `docker-compose.yml`:

```yaml
  # Front Master Storefront
  front-master:
    build:
      context: .
      dockerfile: apps/storefront-vite/front-master/Dockerfile
    container_name: entrepreneur-front-master
    restart: unless-stopped
    ports:
      - "3011:80"
    environment:
      - NODE_ENV=production
    networks:
      - entrepreneur-network
    healthcheck:
      test: ["CMD", "wget", "--quiet", "--tries=1", "--spider", "http://localhost/health"]
      interval: 30s
      timeout: 3s
      retries: 3

  # Front Shop 01
  front-shop-01:
    build:
      context: .
      dockerfile: apps/storefront-vite/front-shop-01/Dockerfile
    container_name: entrepreneur-front-shop-01
    restart: unless-stopped
    ports:
      - "3012:80"
    environment:
      - NODE_ENV=production
    networks:
      - entrepreneur-network
    healthcheck:
      test: ["CMD", "wget", "--quiet", "--tries=1", "--spider", "http://localhost/health"]
      interval: 30s
      timeout: 3s
      retries: 3
```

Start with Docker Compose:
```bash
docker-compose up -d front-master front-shop-01
```

## Reverse Proxy Setup

### Nginx Configuration

`/etc/nginx/sites-available/storefronts`:

```nginx
# Front Master Storefront
server {
    listen 80;
    server_name store.entrepreneur-os.local;

    location / {
        proxy_pass http://localhost:3011;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}

# Front Shop 01
server {
    listen 80;
    server_name shop01.entrepreneur-os.local;

    location / {
        proxy_pass http://localhost:3012;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
```

Enable and reload:
```bash
sudo ln -s /etc/nginx/sites-available/storefronts /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

### Caddy Configuration

`/etc/caddy/Caddyfile`:

```caddy
store.entrepreneur-os.local {
    reverse_proxy localhost:3011
}

shop01.entrepreneur-os.local {
    reverse_proxy localhost:3012
}
```

Reload Caddy:
```bash
sudo systemctl reload caddy
```

## SSL/TLS Setup

### Let's Encrypt with Certbot (Nginx)

```bash
# Install certbot
sudo apt install certbot python3-certbot-nginx

# Obtain certificates
sudo certbot --nginx -d store.entrepreneur-os.com -d shop01.entrepreneur-os.com

# Auto-renewal is configured automatically
```

### Let's Encrypt with Caddy

Caddy handles SSL automatically:

```caddy
store.entrepreneur-os.com {
    reverse_proxy localhost:3011
}

shop01.entrepreneur-os.com {
    reverse_proxy localhost:3012
}
```

## Environment Variables

### Production .env Files

**apps/storefront-vite/front-master/.env.production**:
```bash
VENDURE_SHOP_API_ENDPOINT=https://api.entrepreneur-os.com/shop-api
SESSION_SECRET=<generated-32-character-secret>
VITE_COMPANY_NAME=Entrepreneur OS
VITE_SITE_NAME=Master Store
VITE_WEBSITE_URL=https://store.entrepreneur-os.com
NODE_ENV=production
```

**apps/storefront-vite/front-shop-01/.env.production**:
```bash
VENDURE_SHOP_API_ENDPOINT=https://api.entrepreneur-os.com/shop-api
SESSION_SECRET=<generated-32-character-secret>
VITE_COMPANY_NAME=Entrepreneur OS
VITE_SITE_NAME=Shop 01
VITE_WEBSITE_URL=https://shop01.entrepreneur-os.com
NODE_ENV=production
```

### Generate Session Secrets

```bash
openssl rand -base64 32
```

## Monitoring & Logging

### Health Checks

Each storefront exposes `/health`:
```bash
curl http://localhost:3011/health  # front-master
curl http://localhost:3012/health  # front-shop-01
```

### Logs

View nginx access logs:
```bash
docker logs front-master
docker logs front-shop-01
```

View nginx error logs:
```bash
docker logs front-master 2>&1 | grep error
```

### Uptime Monitoring

Add to Uptime Kuma (running on DV06):
- http://DV04:3011/health (front-master)
- http://DV04:3012/health (front-shop-01)

## Performance Tuning

### nginx Worker Processes

In container, nginx uses 1 worker. For heavy traffic, customize:

```dockerfile
# In Dockerfile, before CMD
RUN sed -i 's/worker_processes auto;/worker_processes 4;/' /etc/nginx/nginx.conf
```

### Static Asset Caching

nginx.conf already includes:
- 1 year cache for static assets
- gzip compression
- No cache for index.html

### CDN Integration (Future)

Front static assets with CloudFlare or local CDN:
- Configure DNS CNAME
- Update asset URLs in build config

## Backup & Disaster Recovery

### Configuration Backup

Backup these files:
- `apps/storefront-vite/front-master/.env.production`
- `apps/storefront-vite/front-shop-01/.env.production`
- Nginx/Caddy configurations
- SSL certificates (`/etc/letsencrypt/`)

### Deployment Rollback

```bash
# Tag Docker images
docker tag entrepreneur-os/front-master:latest entrepreneur-os/front-master:v1.0.0

# Rollback to previous version
docker stop front-master
docker run -d --name front-master -p 3011:80 entrepreneur-os/front-master:v0.9.0
```

## CI/CD Integration (Future)

### GitHub Actions Build Pipeline

```yaml
name: Build and Deploy Storefronts

on:
  push:
    branches: [main]
    paths:
      - 'apps/storefront-vite/**'
      - 'libs/storefront/**'

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Build Docker Images
        run: |
          docker build -t front-master -f apps/storefront-vite/front-master/Dockerfile .
          docker build -t front-shop-01 -f apps/storefront-vite/front-shop-01/Dockerfile .
      - name: Push to Registry
        run: |
          docker tag front-master your-registry.com/front-master:${{ github.sha }}
          docker push your-registry.com/front-master:${{ github.sha }}
```

## Troubleshooting

### Container Won't Start

```bash
# Check logs
docker logs front-master --tail 50

# Check nginx config
docker exec front-master nginx -t

# Verify environment variables
docker exec front-master env
```

### 502 Bad Gateway

- Ensure Vendure API is running and accessible
- Check VENDURE_SHOP_API_ENDPOINT in .env
- Verify network connectivity between containers

### Static Assets Not Loading

- Check nginx logs for 404s
- Verify build output in `/usr/share/nginx/html`
- Check browser console for CORS errors

## Related Documentation
- [Frontend Stack Architecture](../architecture/frontend-stack.md)
- [front-master Dev Guide](./front-master-tanstack.md)
- [front-shop-01 Dev Guide](./front-shop-01.md)
