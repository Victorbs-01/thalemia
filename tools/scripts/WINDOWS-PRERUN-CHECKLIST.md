# Windows Pre-Run Checklist for Vendure Setup Scripts

Before running the Vendure setup scripts on Windows, validate your environment using this checklist.

## Quick Validation Commands

```powershell
# Run all checks at once (PowerShell)
.\tools\scripts\validate-environment.ps1
```

```bash
# Or run manually in Git Bash/WSL
bash tools/scripts/validate-environment.sh
```

---

## Manual Validation Steps

### 1. Bash Syntax Validation

**Check if script has valid Bash syntax:**

```bash
# Git Bash or WSL
bash -n tools/scripts/setup-vendure-master.sh
bash -n tools/scripts/setup-vendure-ecommerce.sh

# Expected: No output = syntax OK
# If errors: Fix syntax before running
```

**ShellCheck (recommended):**

```bash
# Install shellcheck (Git Bash with choco, or WSL with apt)
choco install shellcheck  # Windows with Chocolatey
# OR
sudo apt install shellcheck  # WSL

# Run validation
shellcheck tools/scripts/setup-vendure-master.sh
```

---

### 2. Docker Availability

**Check Docker is installed and running:**

```powershell
# PowerShell
docker --version
docker ps

# Expected output:
# Docker version 24.x.x, build xxxxx
# CONTAINER ID   IMAGE     COMMAND   ...
```

```bash
# Git Bash / WSL
docker --version
docker ps
```

**Common issues:**

- ❌ "docker: command not found" → Install [Docker Desktop for Windows](https://www.docker.com/products/docker-desktop)
- ❌ "Cannot connect to the Docker daemon" → Start Docker Desktop
- ❌ "error during connect" → Enable WSL2 integration in Docker Desktop settings

---

### 3. PostgreSQL Container Name Check

**Verify the expected container name exists or will be created:**

```powershell
# PowerShell - Check if containers exist
docker ps -a --filter "name=entrepreneur-postgres-master"
docker ps -a --filter "name=entrepreneur-postgres-ecommerce"

# Expected: Either running containers or no output (will be created)
```

```bash
# Git Bash / WSL
docker ps -a | grep entrepreneur-postgres
```

**If containers exist but are stopped:**

```powershell
docker start entrepreneur-postgres-master
docker start entrepreneur-postgres-ecommerce
```

---

### 4. pnpm Availability and Version

**Check pnpm is available:**

```powershell
# PowerShell
pnpm --version
# Expected: 9.15.4 or compatible version

# Check if pnpm is in PATH
Get-Command pnpm
# Expected: Path to pnpm executable
```

```bash
# Git Bash / WSL
which pnpm
pnpm --version
```

**If pnpm not found:**

```powershell
# Enable Corepack (Node.js 16.9+)
corepack enable
corepack prepare pnpm@9.15.4 --activate

# Verify
pnpm --version
```

---

### 5. Required Folders Existence

**Check project structure:**

```powershell
# PowerShell
Test-Path "C:\dev\thalemia\entrepreneur-os\package.json"  # Should be True
Test-Path "C:\dev\thalemia\entrepreneur-os\apps"           # Should be True
Test-Path "C:\dev\thalemia\entrepreneur-os\tools\scripts"  # Should be True
```

```bash
# Git Bash
ls -la /c/dev/thalemia/entrepreneur-os/package.json
ls -la /c/dev/thalemia/entrepreneur-os/apps/
ls -la /c/dev/thalemia/entrepreneur-os/tools/scripts/
```

**Expected:**

- ✅ `package.json` exists in project root
- ✅ `apps/` directory exists
- ✅ `tools/scripts/` directory exists

**If missing:**

- ❌ You're not in the correct directory → `cd C:\dev\thalemia\entrepreneur-os`
- ❌ Project not cloned properly → Re-clone the repository

---

### 6. Git Bash / WSL Availability

**Option A: Git Bash**

```powershell
# PowerShell - Check Git Bash installation
Test-Path "C:\Program Files\Git\bin\bash.exe"
# Should return: True

# Launch Git Bash
& "C:\Program Files\Git\bin\bash.exe"
```

**Option B: WSL**

```powershell
# PowerShell - Check WSL installation
wsl --list --verbose

# Expected: At least one WSL distribution listed
# NAME            STATE           VERSION
# Ubuntu          Running         2
```

**If neither available:**

- Git Bash: Install [Git for Windows](https://git-scm.com/download/win)
- WSL: Follow [Microsoft WSL Installation Guide](https://learn.microsoft.com/en-us/windows/wsl/install)

---

### 7. OpenSSL Availability

**Check OpenSSL (for secret generation):**

```bash
# Git Bash / WSL
which openssl
openssl version

# Expected: OpenSSL 1.x.x or 3.x.x
```

```powershell
# PowerShell
Get-Command openssl -ErrorAction SilentlyContinue

# If not found, script will use fallback (timestamp-based secret)
```

**Note:** Git Bash includes OpenSSL by default. PowerShell version has a fallback if OpenSSL is unavailable.

---

### 8. Project Root Validation

**Ensure you're in the project root:**

```bash
# Git Bash
pwd
# Expected: /c/dev/thalemia/entrepreneur-os

# Verify package.json exists
cat package.json | grep '"name": "entrepreneur-os"'
```

```powershell
# PowerShell
Get-Location
# Expected: C:\dev\thalemia\entrepreneur-os

# Verify package.json
Get-Content package.json | Select-String '"name": "entrepreneur-os"'
```

**If wrong directory:**

```bash
cd /c/dev/thalemia/entrepreneur-os  # Git Bash
```

```powershell
Set-Location "C:\dev\thalemia\entrepreneur-os"  # PowerShell
```

---

### 9. Environment File Check

**Check if .env file exists:**

```powershell
# PowerShell
Test-Path ".env"

# If False, create from example
Copy-Item ".env.example" ".env"
```

```bash
# Git Bash
test -f .env && echo "✓ .env exists" || echo "✗ .env missing"

# Create if missing
cp .env.example .env
```

**Verify .env has PostgreSQL configuration:**

```bash
# Git Bash / PowerShell
cat .env | grep POSTGRES_MASTER_PORT
cat .env | grep POSTGRES_ECOMMERCE

# Expected: Database configuration lines
```

---

### 10. Path Translation (Git Bash Only)

**Git Bash translates Windows paths automatically:**

```bash
# All these are equivalent in Git Bash:
# C:\dev\thalemia\entrepreneur-os
# /c/dev/thalemia/entrepreneur-os
# //c/dev/thalemia/entrepreneur-os

# Verify translation
pwd
# Shows: /c/dev/thalemia/entrepreneur-os

cd /c/dev/thalemia/entrepreneur-os
# Works correctly
```

---

## Pre-Run Summary Checklist

Before running `setup-vendure-master.sh` or `.ps1`:

- [ ] **Bash syntax validated** (no errors from `bash -n script.sh`)
- [ ] **Docker installed and running** (`docker ps` works)
- [ ] **PostgreSQL containers ready** (running or will be created)
- [ ] **pnpm available** (`pnpm --version` shows 9.x)
- [ ] **Project root confirmed** (`package.json` exists, has correct name)
- [ ] **apps/ directory exists**
- [ ] **Git Bash or WSL available** (for Bash scripts)
- [ ] **OpenSSL available** (or using PowerShell with fallback)
- [ ] **.env file exists** (created from .env.example)
- [ ] **User is in project root** (`pwd` or `Get-Location` confirms)

---

## Automated Validation Script

**PowerShell Validator:** `tools/scripts/validate-environment.ps1`

```powershell
# Run complete validation
.\tools\scripts\validate-environment.ps1

# Expected output: ✓ or ✗ for each check
```

**Bash Validator:** `tools/scripts/validate-environment.sh`

```bash
# Run complete validation
bash tools/scripts/validate-environment.sh

# Expected output: ✓ or ✗ for each check
```

---

## Troubleshooting

### "bash: command not found"

**Solution:** Install Git for Windows or WSL

```powershell
# Check if Git Bash exists
Test-Path "C:\Program Files\Git\bin\bash.exe"

# If False, download: https://git-scm.com/download/win
```

### "docker: command not found"

**Solution:** Install Docker Desktop and add to PATH

```powershell
# Check Docker installation
Get-Command docker -ErrorAction SilentlyContinue

# If null, install: https://www.docker.com/products/docker-desktop
```

### "pnpm: command not found"

**Solution:** Enable Corepack

```powershell
corepack enable
corepack prepare pnpm@9.15.4 --activate
```

### "Cannot create directory: Permission denied"

**Solution:** Run with appropriate permissions

```bash
# Git Bash - Check directory permissions
ls -la apps/

# PowerShell - Run as Administrator (if needed)
# Right-click PowerShell → "Run as Administrator"
```

### "Container entrepreneur-postgres-master not found"

**Solution:** Start PostgreSQL containers

```powershell
docker-compose up -d postgres-master postgres-ecommerce

# Wait 10-15 seconds, then verify
docker ps | Select-String "postgres"
```

---

## Next Steps

After all checks pass:

**For Bash scripts:**

```bash
# Git Bash
cd /c/dev/thalemia/entrepreneur-os
bash tools/scripts/setup-vendure-master.sh
```

**For PowerShell scripts:**

```powershell
# PowerShell
Set-Location "C:\dev\thalemia\entrepreneur-os"
.\tools\scripts\setup-vendure-master.ps1
```

**For dry-run testing:**

```bash
# Bash dry-run
bash tools/scripts/setup-vendure-master.sh --dry-run
```

```powershell
# PowerShell dry-run
.\tools\scripts\setup-vendure-master.ps1 -DryRun
```

---

**Last Updated:** 2025-11-16
**Compatibility:** Windows 10/11, Git Bash 2.x, WSL2, PowerShell 5.1+
