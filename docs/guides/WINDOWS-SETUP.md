# Windows Setup Guide - Vendure Scripts

Complete guide for running Vendure setup scripts on Windows using PowerShell or Bash.

## Table of Contents

- [Quick Start](#quick-start)
- [PowerShell Compatibility Analysis](#powershell-compatibility-analysis)
- [Running Bash Scripts on Windows](#running-bash-scripts-on-windows)
- [Using PowerShell Scripts](#using-powersh

ell-scripts)

- [Dry-Run Mode](#dry-run-mode)
- [Troubleshooting](#troubleshooting)

---

## Quick Start

### Option 1: PowerShell (Native Windows)

```powershell
# From project root in PowerShell
cd C:\dev\thalemia\entrepreneur-os

# Dry-run first (recommended)
.\tools\scripts\setup-vendure-master.ps1 -DryRun

# Run actual setup
.\tools\scripts\setup-vendure-master.ps1
```

### Option 2: Git Bash (Linux-style on Windows)

```bash
# From project root in Git Bash
cd /c/dev/thalemia/entrepreneur-os

# Dry-run first (recommended)
bash tools/scripts/setup-vendure-master.sh --dry-run

# Run actual setup
bash tools/scripts/setup-vendure-master.sh
```

---

## PowerShell Compatibility Analysis

### Where Bash Scripts FAIL in PowerShell

The original Bash scripts have **~25 incompatibilities** with PowerShell:

#### 1. **Shebang Line**

```bash
#!/bin/bash  # ❌ PowerShell doesn't recognize shebangs
```

#### 2. **Error Handling**

```bash
set -e  # ❌ Not a PowerShell command
# PowerShell equivalent: $ErrorActionPreference = "Stop"
```

#### 3. **ANSI Color Codes**

```bash
RED='\033[0;31m'  # ❌ Different syntax in PowerShell
echo -e "${RED}Error${NC}"  # ❌ -e flag doesn't exist

# PowerShell equivalent:
Write-Host "Error" -ForegroundColor Red
```

#### 4. **Test Operators**

```bash
if [ ! -f "file.txt" ]; then  # ❌ [ ] syntax not supported
# PowerShell equivalent:
if (-not (Test-Path "file.txt")) {
```

#### 5. **Heredocs**

```bash
cat > file.txt << EOF  # ❌ Heredoc syntax not supported
Content here
EOF

# PowerShell equivalent:
@"
Content here
"@ | Out-File -FilePath file.txt
```

#### 6. **Command Substitution**

```bash
SECRET=$(openssl rand -base64 32)  # ❌ $() syntax different
TIMESTAMP=$(date +%s)  # ❌ date command doesn't exist

# PowerShell equivalent:
$SECRET = openssl rand -base64 32
$TIMESTAMP = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
```

#### 7. **stderr Redirection**

```bash
2>/dev/null  # ❌ Different syntax
2>&1  # ✓ Works but different behavior

# PowerShell equivalent:
2>$null
```

#### 8. **Piping with Logical Operators**

```bash
command | grep "text" || echo "fallback"  # ❌ || doesn't work the same

# PowerShell equivalent:
$result = command | Select-String "text"
if (-not $result) { Write-Output "fallback" }
```

#### 9. **Directory Creation**

```bash
mkdir -p dir/subdir  # ❌ -p flag doesn't exist in PowerShell

# PowerShell equivalent:
New-Item -ItemType Directory -Force -Path "dir\subdir"
```

#### 10. **String Tests**

```bash
if [ -z "$VAR" ]; then  # ❌ -z test not supported

# PowerShell equivalent:
if ([string]::IsNullOrEmpty($VAR)) {
```

### Complete Incompatibility List

| Line(s)      | Bash Syntax       | PowerShell Issue       | Solution                                           |
| ------------ | ----------------- | ---------------------- | -------------------------------------------------- |
| 1            | `#!/bin/bash`     | Shebang not recognized | Remove or comment out                              |
| 2            | `set -e`          | Not a command          | Use `$ErrorActionPreference = "Stop"`              |
| 5-9          | ANSI codes        | Different syntax       | Use `Write-Host -ForegroundColor`                  |
| 15, etc.     | `echo -e`         | `-e` flag invalid      | Use `Write-Host` or remove `-e`                    |
| 37, 326, 336 | `[ ! -f ]`        | Test syntax            | Use `Test-Path`                                    |
| 55           | `cd "path"`       | Works but...           | Use `Push-Location`/`Pop-Location`                 |
| 59           | `mkdir -p`        | No `-p` flag           | Use `New-Item -Force`                              |
| 63-313       | Heredocs `<< EOF` | Not supported          | Use here-strings `@" "@`                           |
| 143          | `$(command)`      | Different behavior     | Use `$(command)` but test carefully                |
| 143          | `2>/dev/null`     | Invalid path           | Use `2>$null`                                      |
| 143          | `\|\|` operator   | Different logic        | Use `if` statements                                |
| 143          | `date +%s`        | Command missing        | Use `[DateTimeOffset]::UtcNow.ToUnixTimeSeconds()` |
| 317          | `pnpm install`    | Works if in PATH       | Same command                                       |
| 319          | `cd ../..`        | Works                  | But use `Pop-Location`                             |
| 334          | Complex piping    | Different behavior     | Rewrite with PowerShell cmdlets                    |

**Total:** 25+ incompatibilities

---

## Running Bash Scripts on Windows

### Prerequisites

Install **Git for Windows** (includes Git Bash):

```powershell
# Check if installed
Test-Path "C:\Program Files\Git\bin\bash.exe"

# If not installed, download from:
# https://git-scm.com/download/win
```

### Method 1: Git Bash Terminal

1. **Open Git Bash:**
   - Start Menu → "Git Bash"
   - Or right-click in folder → "Git Bash Here"

2. **Navigate to project:**

   ```bash
   cd /c/dev/thalemia/entrepreneur-os
   ```

3. **Run script:**

   ```bash
   # With dry-run
   bash tools/scripts/setup-vendure-master.sh --dry-run

   # Actual run
   bash tools/scripts/setup-vendure-master.sh
   ```

### Method 2: Direct Invocation from PowerShell

```powershell
# From PowerShell, invoke Git Bash
& "C:\Program Files\Git\bin\bash.exe" -c "cd /c/dev/thalemia/entrepreneur-os && bash tools/scripts/setup-vendure-master.sh"
```

### Method 3: WSL (Windows Subsystem for Linux)

1. **Install WSL2:**

   ```powershell
   wsl --install
   # Restart computer when prompted
   ```

2. **Run from WSL:**
   ```bash
   # In WSL terminal
   cd /mnt/c/dev/thalemia/entrepreneur-os
   bash tools/scripts/setup-vendure-master.sh
   ```

**Important:** Docker Desktop must have "WSL 2 based engine" enabled and "Enable integration with my default WSL distro" checked.

---

## Using PowerShell Scripts

### PowerShell Script Features

The `.ps1` scripts have **100% feature parity** with Bash versions:

- ✅ Same logic and behavior
- ✅ Same file creation
- ✅ Same validation checks
- ✅ Built-in dry-run mode
- ✅ Colored output
- ✅ Cryptographically secure secret generation

### Running PowerShell Scripts

#### Basic Usage

```powershell
# Navigate to project root
Set-Location "C:\dev\thalemia\entrepreneur-os"

# Run Master setup
.\tools\scripts\setup-vendure-master.ps1

# Run Ecommerce setup
.\tools\scripts\setup-vendure-ecommerce.ps1
```

#### With Dry-Run

```powershell
# Test Master setup (no changes made)
.\tools\scripts\setup-vendure-master.ps1 -DryRun

# Test Ecommerce setup
.\tools\scripts\setup-vendure-ecommerce.ps1 -DryRun
```

#### Execution Policy

If you get an "execution policy" error:

```powershell
# Check current policy
Get-ExecutionPolicy

# Allow script execution (run PowerShell as Administrator)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Or bypass for this session only
powershell -ExecutionPolicy Bypass -File .\tools\scripts\setup-vendure-master.ps1
```

---

## Dry-Run Mode

### What is Dry-Run Mode?

Dry-run mode **prints all commands without executing them**. Use this to:

- ✅ Verify what the script will do
- ✅ Check for potential issues
- ✅ Review configuration before changes
- ✅ Learn what the script does

### Bash Dry-Run

```bash
# Git Bash
bash tools/scripts/setup-vendure-master.sh --dry-run

# Or short flag
bash tools/scripts/setup-vendure-master.sh -n
```

### PowerShell Dry-Run

```powershell
# PowerShell
.\tools\scripts\setup-vendure-master.ps1 -DryRun
```

### Dry-Run Output Example

```
🔍 DRY-RUN MODE ENABLED - No changes will be made

ℹ Verificando que Docker está corriendo...
✓ Docker está corriendo

[DRY-RUN] Would create directory: apps/vendure-master/src
[DRY-RUN] Would create directory: apps/vendure-master/static-assets
[DRY-RUN] Would create file: apps/vendure-master/package.json
  Content preview: {
  "name": "vendure-master",
  "version": "1.0.0",
  ...

[DRY-RUN] Would run: pnpm install --shamefully-hoist in apps\vendure-master
  Command: pnpm install --shamefully-hoist
```

---

## Pre-Run Validation

Before running scripts, validate your environment:

### Automated Validation

```bash
# Bash (Git Bash / WSL)
bash tools/scripts/validate-environment.sh
```

```powershell
# PowerShell
.\tools\scripts\validate-environment.ps1
```

### Manual Checks

See: [WINDOWS-PRERUN-CHECKLIST.md](../../tools/scripts/WINDOWS-PRERUN-CHECKLIST.md)

Key checks:

- ✅ Docker running
- ✅ pnpm available
- ✅ PostgreSQL containers ready
- ✅ Project root confirmed
- ✅ Required folders exist

---

## Troubleshooting

### "execution of scripts is disabled"

**Error:**

```
.\setup-vendure-master.ps1 : File cannot be loaded because running scripts is disabled on this system.
```

**Solution:**

```powershell
# Option 1: Change execution policy
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Option 2: Bypass for single run
powershell -ExecutionPolicy Bypass -File .\tools\scripts\setup-vendure-master.ps1
```

### "bash: command not found"

**Error:**

```
bash: command not found
```

**Solution:** Install Git for Windows

```powershell
# Check if Git Bash exists
Test-Path "C:\Program Files\Git\bin\bash.exe"

# If False, download: https://git-scm.com/download/win
```

### "docker: command not found"

**Error:**

```
docker : The term 'docker' is not recognized
```

**Solution:**

1. Install Docker Desktop for Windows
2. Start Docker Desktop
3. Verify PATH includes Docker:

```powershell
Get-Command docker
# Expected: Shows path to docker.exe
```

### "pnpm: command not found"

**Error:**

```
pnpm : The term 'pnpm' is not recognized
```

**Solution:**

```powershell
# Enable Corepack
corepack enable

# Prepare pnpm
corepack prepare pnpm@9.15.4 --activate

# Verify
pnpm --version
```

### Path Translation Issues (Git Bash)

**Issue:** Windows paths (C:\) don't work in Git Bash

**Solution:** Use Unix-style paths

```bash
# ❌ Wrong
cd C:\dev\thalemia\entrepreneur-os

# ✓ Correct
cd /c/dev/thalemia/entrepreneur-os
```

Git Bash automatically translates:

- `C:\` → `/c/`
- `D:\` → `/d/`
- etc.

### PowerShell: "cannot create file"

**Error:**

```
Out-File : Could not find a part of the path
```

**Solution:** Ensure intermediate directories exist

The PowerShell script handles this automatically with `New-Item -Force`, but if manually creating files:

```powershell
# Create parent directories first
New-Item -ItemType Directory -Force -Path "apps\vendure-master\src"

# Then create file
$content | Out-File -FilePath "apps\vendure-master\src\file.ts"
```

---

## Comparison: PowerShell vs Bash

### When to Use PowerShell

✅ Native Windows environment
✅ No additional tools needed (included in Windows)
✅ Better Windows path handling
✅ Integrated with Windows features
✅ Color output works in Windows Terminal

### When to Use Bash (Git Bash/WSL)

✅ Prefer Unix-style scripting
✅ Already have Git for Windows installed
✅ Cross-platform development
✅ More familiar with Linux commands
✅ Using WSL for development

### Feature Parity

Both script versions provide **identical functionality**:

| Feature           | Bash (.sh)    | PowerShell (.ps1)                |
| ----------------- | ------------- | -------------------------------- |
| Dry-run mode      | ✓ `--dry-run` | ✓ `-DryRun`                      |
| Colored output    | ✓ ANSI codes  | ✓ `Write-Host`                   |
| Docker validation | ✓             | ✓                                |
| Database checks   | ✓             | ✓                                |
| File creation     | ✓ Heredocs    | ✓ Here-strings                   |
| Secret generation | ✓ OpenSSL     | ✓ .NET Crypto + OpenSSL fallback |
| Error handling    | ✓ `set -e`    | ✓ `$ErrorActionPreference`       |
| pnpm install      | ✓             | ✓                                |

---

## Advanced Usage

### Running Both Scripts in Sequence

#### PowerShell

```powershell
# Setup both instances
.\tools\scripts\setup-vendure-master.ps1
.\tools\scripts\setup-vendure-ecommerce.ps1
```

#### Bash

```bash
# Setup both instances
bash tools/scripts/setup-vendure-master.sh
bash tools/scripts/setup-vendure-ecommerce.sh
```

### Automating with npm Scripts

```powershell
# From package.json
pnpm run setup:vendure:master
pnpm run setup:vendure:ecommerce
```

### Testing with Dry-Run First

```powershell
# PowerShell - Test then run
.\tools\scripts\setup-vendure-master.ps1 -DryRun
# Review output, then:
.\tools\scripts\setup-vendure-master.ps1
```

---

## Summary

### Quick Reference

| Task                     | Bash (Git Bash)                                           | PowerShell                                            |
| ------------------------ | --------------------------------------------------------- | ----------------------------------------------------- |
| **Dry-run Master**       | `bash tools/scripts/setup-vendure-master.sh --dry-run`    | `.\tools\scripts\setup-vendure-master.ps1 -DryRun`    |
| **Setup Master**         | `bash tools/scripts/setup-vendure-master.sh`              | `.\tools\scripts\setup-vendure-master.ps1`            |
| **Dry-run Ecommerce**    | `bash tools/scripts/setup-vendure-ecommerce.sh --dry-run` | `.\tools\scripts\setup-vendure-ecommerce.ps1 -DryRun` |
| **Setup Ecommerce**      | `bash tools/scripts/setup-vendure-ecommerce.sh`           | `.\tools\scripts\setup-vendure-ecommerce.ps1`         |
| **Validate Environment** | `bash tools/scripts/validate-environment.sh`              | `.\tools\scripts\validate-environment.ps1`            |

### Recommendations

1. **First time?** Use dry-run mode first
2. **Windows user?** Use PowerShell scripts (native)
3. **Linux background?** Use Git Bash scripts
4. **Low RAM?** Follow sequential setup in [VENDURE-SETUP.md](./VENDURE-SETUP.md)
5. **Issues?** Check [WINDOWS-PRERUN-CHECKLIST.md](../../tools/scripts/WINDOWS-PRERUN-CHECKLIST.md)

---

## Additional Resources

- **Pre-Run Checklist:** [tools/scripts/WINDOWS-PRERUN-CHECKLIST.md](../../tools/scripts/WINDOWS-PRERUN-CHECKLIST.md)
- **Vendure Setup Guide:** [VENDURE-SETUP.md](./VENDURE-SETUP.md)
- **Project Documentation:** [CLAUDE.md](../../CLAUDE.md)
- **Git for Windows:** https://git-scm.com/download/win
- **Docker Desktop:** https://www.docker.com/products/docker-desktop
- **WSL Installation:** https://learn.microsoft.com/en-us/windows/wsl/install

---

**Last Updated:** 2025-11-16
**Applies To:** Windows 10/11, PowerShell 5.1+, Git Bash 2.x, WSL2
**Script Versions:** setup-vendure-master v1.0.0, setup-vendure-ecommerce v1.0.0
