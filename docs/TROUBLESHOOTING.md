# Troubleshooting Guide

Common issues and solutions for Entrepreneur-OS development.

## Port Conflicts

If services fail to start due to port conflicts:

### Common Ports

```
Vendure Master:       3000 (API), 3001 (Admin)
Vendure Ecommerce:    3002 (API), 3003 (Admin)
PostgreSQL Master:    5432
PostgreSQL Ecommerce: 5433
Redis:                6379
n8n:                  5678
Adminer:              8080
```

### Check Port Usage

```bash
# Check which process is using a port
lsof -i :3000
netstat -tulpn | grep :3000

# Kill process using port
kill -9 <PID>
```

### Solutions

1. **Stop conflicting services:**
   ```bash
   pnpm run docker:down
   ```

2. **Check for zombie Docker containers:**
   ```bash
   docker ps -a
   docker rm -f <container-id>
   ```

3. **Change port in docker-compose.yml** (if port is unavailable)

## Database Issues

### Reset Databases

```bash
# Reset both databases
pnpm run db:reset

# Reset Docker volumes (nuclear option)
pnpm run docker:db:reset
```

### Check Database Connectivity

```bash
# Connect to master database
docker exec -it postgres-master psql -U vendure -d vendure_master

# Connect to ecommerce database
docker exec -it postgres-ecommerce psql -U vendure -d vendure_ecommerce

# List databases
\l

# List tables
\dt

# Exit
\q
```

### Common Database Errors

**Error: "database does not exist"**
```bash
# Re-initialize databases
bash tools/scripts/init-databases.sh
pnpm run db:migrate
```

**Error: "too many connections"**
```bash
# Restart PostgreSQL containers
docker restart postgres-master postgres-ecommerce
```

**Error: "could not connect to server"**
```bash
# Check if containers are running
docker ps | grep postgres

# Restart if needed
pnpm run docker:restart
```

## Docker Issues

### Clean Rebuild

```bash
# Full clean and rebuild
pnpm run docker:clean
pnpm run docker:rebuild
```

### Check Container Logs

```bash
# Follow all logs
pnpm run docker:logs

# Specific service logs
docker logs -f <container-name>
docker logs -f postgres-master
docker logs -f vendure-master
```

### Check Container Status

```bash
# List running containers
pnpm run docker:ps

# List all containers (including stopped)
docker ps -a

# Inspect container
docker inspect <container-name>
```

### Common Docker Errors

**Error: "Cannot connect to the Docker daemon"**
```bash
# Start Docker service
sudo systemctl start docker

# Or on macOS
open /Applications/Docker.app
```

**Error: "port is already allocated"**
- See [Port Conflicts](#port-conflicts) section above

**Error: "no space left on device"**
```bash
# Clean up Docker
docker system prune -a
docker volume prune
```

## Nx Cache Issues

### Clear Nx Cache

```bash
# Clear cache
pnpm run reset

# Manually clear
rm -rf .nx/cache

# Run without cache
nx run-many -t build --all --skip-nx-cache
```

### Common Nx Errors

**Error: "Nx cache is corrupted"**
```bash
pnpm run reset
```

**Error: "Cannot find project"**
```bash
# Refresh Nx workspace
nx reset
pnpm install
```

**Error: "Task target configuration is missing"**
- Check `nx.json` and project's `project.json`
- Ensure target exists in configuration

## Build Failures

### TypeScript Errors

```bash
# Check TypeScript errors
pnpm run lint

# Auto-fix linting issues
pnpm run lint:fix

# Check specific project
nx lint <project-name>
```

### Dependency Issues

```bash
# Clean install
rm -rf node_modules pnpm-lock.yaml
pnpm install

# Clear Nx cache
pnpm run reset
```

### Build Specific Project

```bash
# Build single project
nx build <project-name>

# Build with verbose output
nx build <project-name> --verbose

# Build without cache
nx build <project-name> --skip-nx-cache
```

## Testing Issues

### Tests Failing

```bash
# Run tests with verbose output
nx test <project-name> --verbose

# Run single test file
nx test <project-name> --testFile=<path-to-test>

# Clear Jest cache
nx test <project-name> --clearCache
```

### E2E Tests Failing

```bash
# Run E2E with UI for debugging
pnpm run e2e:ui

# Run specific E2E test
nx e2e <project-name> --spec=<test-file>
```

## Environment Issues

### Missing Environment Variables

```bash
# Check if .env exists
ls -la .env

# Copy from example if missing
cp .env.example .env

# Edit with your configuration
nano .env
```

### Environment Variable Not Loaded

```bash
# Restart services to reload .env
pnpm run docker:restart

# Check if Docker Compose picks up .env
docker-compose config
```

## Performance Issues

### Slow Builds

```bash
# Use affected builds only
pnpm run build:affected

# Enable Nx daemon (if not already)
# Add to nx.json:
{
  "tasksRunnerOptions": {
    "default": {
      "options": {
        "cacheableOperations": ["build", "test", "lint"]
      }
    }
  }
}
```

### Slow Tests

```bash
# Run affected tests only
pnpm run test:affected

# Run tests in parallel
nx run-many -t test --parallel=3
```

## Common Error Patterns

### "MODULE_NOT_FOUND"

1. Check if dependency is installed: `pnpm install`
2. Check tsconfig.base.json paths
3. Verify import path uses `@entrepreneur-os` namespace
4. Clear Nx cache: `pnpm run reset`

### "Cannot find module '@entrepreneur-os/...'"

1. Check if library exists in `libs/`
2. Verify tsconfig.base.json has path mapping
3. Run `pnpm install`
4. Restart IDE/editor

### "GraphQL Error: ..."

1. Check if Vendure instance is running
2. Verify database is initialized
3. Check GraphQL endpoint URL
4. Review Vendure logs: `docker logs -f vendure-master`

## Getting Help

If issues persist:

1. **Check logs:**
   ```bash
   pnpm run docker:logs
   docker logs -f <service-name>
   ```

2. **Check git status:**
   ```bash
   git status
   git diff
   ```

3. **Nuclear option (⚠️ destroys data):**
   ```bash
   pnpm run docker:clean
   rm -rf node_modules .nx
   pnpm install
   pnpm run docker:up
   pnpm run db:reset
   ```

4. **Review documentation:**
   - [CLAUDE.md](../CLAUDE.md) - Development workflow
   - [ARCHITECTURE.md](ARCHITECTURE.md) - System architecture
   - [INFRASTRUCTURE.md](INFRASTRUCTURE.md) - Infrastructure details
