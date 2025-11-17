<#
.SYNOPSIS
    Vendure Ecommerce Setup Script - Sequential Installation (Windows PowerShell)

.DESCRIPTION
    This script installs ONLY the vendure-ecommerce instance.
    Designed for sequential installation on low-RAM systems (<8GB).

    Alternative: Use setup-vendure.ps1 to install BOTH instances simultaneously
    (requires ~8GB RAM).

    Database credentials: Loaded from project root .env file, with fallback defaults.

.PARAMETER DryRun
    If specified, commands are printed but not executed (dry-run mode)

.EXAMPLE
    .\setup-vendure-ecommerce.ps1

.EXAMPLE
    .\setup-vendure-ecommerce.ps1 -DryRun

.NOTES
    Author: Entrepreneur-OS
    Version: 2.0.0
    Requires: PowerShell 5.1+, Docker Desktop, pnpm
    Run from: Project root directory
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [switch]$DryRun
)

# Configuración estricta de errores
$ErrorActionPreference = "Stop"
$PSDefaultParameterValues['*:Encoding'] = 'utf8'

# Versiones de Vendure
$VENDURE_VERSION = "^3.1.0"
$OSW_VERSION = "1.3.5"

# Load environment variables from project root .env if it exists
if (Test-Path ".env") {
    Get-Content .env | ForEach-Object {
        if ($_ -match '^\s*([^#][^=]*)\s*=\s*(.*)$') {
            $name = $matches[1].Trim()
            $value = $matches[2].Trim()
            [Environment]::SetEnvironmentVariable($name, $value, [EnvironmentVariableTarget]::Process)
        }
    }
}

#region Helper Functions

function Write-ColorOutput {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message,

        [Parameter(Mandatory=$false)]
        [ValidateSet('Info', 'Success', 'Warning', 'Error')]
        [string]$Type = 'Info'
    )

    $color = switch ($Type) {
        'Success' { 'Green' }
        'Warning' { 'Yellow' }
        'Error'   { 'Red' }
        'Info'    { 'Cyan' }
    }

    $prefix = switch ($Type) {
        'Success' { '✓' }
        'Warning' { '⚠' }
        'Error'   { '✗' }
        'Info'    { 'ℹ' }
    }

    Write-Host "$prefix $Message" -ForegroundColor $color
}

function Invoke-SafeCommand {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Command,

        [Parameter(Mandatory=$false)]
        [string]$Description = "",

        [Parameter(Mandatory=$false)]
        [switch]$DryRunMode
    )

    if ($DryRunMode) {
        Write-Host "[DRY-RUN] $Description" -ForegroundColor Magenta
        Write-Host "  Command: $Command" -ForegroundColor DarkGray
    } else {
        if ($Description) {
            Write-ColorOutput -Message $Description -Type 'Info'
        }
        Invoke-Expression $Command
    }
}

function New-FileWithContent {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Path,

        [Parameter(Mandatory=$true)]
        [string]$Content,

        [Parameter(Mandatory=$false)]
        [switch]$DryRunMode
    )

    if ($DryRunMode) {
        Write-Host "[DRY-RUN] Would create file: $Path" -ForegroundColor Magenta
        Write-Host "  Content preview: $($Content.Substring(0, [Math]::Min(100, $Content.Length)))..." -ForegroundColor DarkGray
    } else {
        $Content | Out-File -FilePath $Path -Encoding UTF8 -NoNewline
    }
}

function Get-RandomSecret {
    param([int]$Length = 32)

    # Try OpenSSL first (if available via Git Bash or standalone)
    try {
        $opensslPath = Get-Command openssl -ErrorAction SilentlyContinue
        if ($opensslPath) {
            $bytes = & openssl rand -base64 $Length 2>$null
            if ($LASTEXITCODE -eq 0 -and $bytes) {
                return $bytes.Trim()
            }
        }
    } catch {
        # OpenSSL not available, use fallback
    }

    # Fallback: Use .NET cryptographic random
    try {
        $rng = [System.Security.Cryptography.RNGCryptoServiceProvider]::new()
        $randomBytes = New-Object byte[] $Length
        $rng.GetBytes($randomBytes)
        $rng.Dispose()
        return [Convert]::ToBase64String($randomBytes)
    } catch {
        # Final fallback: timestamp-based
        $timestamp = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
        return "change-me-in-production-$timestamp"
    }
}

function Get-UnixTimestamp {
    return [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
}

#endregion

#region Main Script

Write-Host ""
Write-Host "🚀 Entrepreneur OS - Vendure Ecommerce Setup" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

if ($DryRun) {
    Write-Host "🔍 DRY-RUN MODE ENABLED - No changes will be made" -ForegroundColor Magenta
    Write-Host ""
}

# Verificar que estamos en la raíz del proyecto
if (-not (Test-Path "package.json") -or -not (Test-Path "apps")) {
    Write-ColorOutput -Message "Este script debe ejecutarse desde la raíz del proyecto" -Type 'Error'
    Write-ColorOutput -Message "Directorio actual: $(Get-Location)" -Type 'Error'
    exit 1
}

# Función para configurar una instancia de Vendure
function Setup-Vendure {
    param(
        [string]$AppName,
        [string]$DbPort,
        [string]$ApiPort,
        [string]$AdminPort,
        [string]$DbName,
        [string]$DbPass,
        [switch]$DryRunMode
    )

    Write-Host ""
    Write-Host "📦 Configurando $AppName..." -ForegroundColor Cyan
    Write-Host "----------------------------------------" -ForegroundColor Cyan

    $appPath = "apps\$AppName"

    # Crear estructura de directorios
    if (-not $DryRunMode) {
        Write-ColorOutput -Message "Creando estructura de directorios..." -Type 'Info'
        New-Item -ItemType Directory -Force -Path "$appPath\src" | Out-Null
        New-Item -ItemType Directory -Force -Path "$appPath\static-assets" | Out-Null
        New-Item -ItemType Directory -Force -Path "$appPath\static-email-templates" | Out-Null
        New-Item -ItemType Directory -Force -Path "$appPath\static-email-output" | Out-Null
        New-Item -ItemType Directory -Force -Path "$appPath\migrations" | Out-Null
    } else {
        Write-Host "[DRY-RUN] Would create directories in: $appPath" -ForegroundColor Magenta
        Write-Host "  - src/" -ForegroundColor DarkGray
        Write-Host "  - static-assets/" -ForegroundColor DarkGray
        Write-Host "  - static-email-templates/" -ForegroundColor DarkGray
        Write-Host "  - static-email-output/" -ForegroundColor DarkGray
        Write-Host "  - migrations/" -ForegroundColor DarkGray
    }

    # Crear package.json
    $packageJson = @"
{
  "name": "$AppName",
  "version": "1.0.0",
  "private": true,
  "scripts": {
    "dev": "concurrently -n SERVER,WORKER -c blue,green \`"ts-node-dev --respawn --transpile-only src/index.ts\`" \`"ts-node-dev --respawn --transpile-only src/index-worker.ts\`"",
    "dev:server": "ts-node-dev --respawn --transpile-only src/index.ts",
    "dev:worker": "ts-node-dev --respawn --transpile-only src/index-worker.ts",
    "build": "tsc",
    "start": "node dist/index.js",
    "start:worker": "node dist/index-worker.js",
    "migration:generate": "ts-node ./node_modules/typeorm/cli.js migration:generate -d src/vendure-config.ts",
    "migration:run": "ts-node ./node_modules/typeorm/cli.js migration:run -d src/vendure-config.ts",
    "migration:revert": "ts-node ./node_modules/typeorm/cli.js migration:revert -d src/vendure-config.ts"
  },
  "dependencies": {
    "@vendure/core": "$VENDURE_VERSION",
    "@vendure/admin-ui": "$VENDURE_VERSION",
    "@vendure/asset-server-plugin": "$VENDURE_VERSION",
    "@vendure/email-plugin": "$VENDURE_VERSION",
    "pg": "^8.12.0",
    "dotenv": "^16.4.5"
  },
  "devDependencies": {
    "@types/node": "^20.11.0",
    "@vendure/ui-devkit": "$VENDURE_VERSION",
    "ts-node": "^10.9.2",
    "ts-node-dev": "^2.0.0",
    "typescript": "^5.3.3",
    "concurrently": "^8.2.2"
  },
  "pnpm": {
    "overrides": {
      "osw": "$OSW_VERSION"
    }
  }
}
"@

    New-FileWithContent -Path "$appPath\package.json" -Content $packageJson -DryRunMode:$DryRunMode

    # Crear tsconfig.json
    $tsconfigJson = @'
{
  "extends": "../../tsconfig.base.json",
  "compilerOptions": {
    "outDir": "./dist",
    "rootDir": "./src",
    "module": "commonjs",
    "target": "ES2021",
    "lib": ["ES2021"],
    "emitDecoratorMetadata": true,
    "experimentalDecorators": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "resolveJsonModule": true,
    "allowSyntheticDefaultImports": true,
    "strict": false,
    "sourceMap": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist", "migrations"]
}
'@

    New-FileWithContent -Path "$appPath\tsconfig.json" -Content $tsconfigJson -DryRunMode:$DryRunMode

    # Generar COOKIE_SECRET
    $cookieSecret = Get-RandomSecret -Length 32

    # Crear .env
    $envContent = @"
# Database Configuration
DB_HOST=localhost
DB_PORT=$DbPort
DB_USERNAME=vendure
DB_PASSWORD=$DbPass
DB_NAME=$DbName

# Server Configuration
PORT=$ApiPort
ADMIN_PORT=$AdminPort

# Security
COOKIE_SECRET=$cookieSecret
SUPERADMIN_USERNAME=superadmin
SUPERADMIN_PASSWORD=superadmin

# Email Configuration (Development)
EMAIL_FROM=noreply@$AppName.local
EMAIL_TRANSPORT=file

# Environment
NODE_ENV=development
"@

    New-FileWithContent -Path "$appPath\.env" -Content $envContent -DryRunMode:$DryRunMode

    # Crear vendure-config.ts
    $vendureConfigTs = @'
import { VendureConfig } from '@vendure/core';
import { defaultEmailHandlers, EmailPlugin } from '@vendure/email-plugin';
import { AssetServerPlugin } from '@vendure/asset-server-plugin';
import { AdminUiPlugin } from '@vendure/admin-ui';
import path from 'path';
import { config as dotenvConfig } from 'dotenv';

dotenvConfig();

export const config: VendureConfig = {
  apiOptions: {
    port: parseInt(process.env.PORT || '3000'),
    adminApiPath: 'admin-api',
    shopApiPath: 'shop-api',
    adminApiPlayground: {
      settings: { 'request.credentials': 'include' } as any,
    },
    adminApiDebug: true,
    shopApiPlayground: {
      settings: { 'request.credentials': 'include' } as any,
    },
    shopApiDebug: true,
  },
  authOptions: {
    tokenMethod: ['bearer', 'cookie'],
    superadminCredentials: {
      identifier: process.env.SUPERADMIN_USERNAME || 'superadmin',
      password: process.env.SUPERADMIN_PASSWORD || 'superadmin',
    },
    cookieOptions: {
      secret: process.env.COOKIE_SECRET || 'cookie-secret',
    },
  },
  dbConnectionOptions: {
    type: 'postgres',
    synchronize: true, // Set to false in production
    logging: false,
    host: process.env.DB_HOST,
    port: parseInt(process.env.DB_PORT || '5432'),
    username: process.env.DB_USERNAME,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    migrations: [path.join(__dirname, '../migrations/*.ts')],
  },
  paymentOptions: {
    paymentMethodHandlers: [],
  },
  customFields: {},
  plugins: [
    AssetServerPlugin.init({
      route: 'assets',
      assetUploadDir: path.join(__dirname, '../static-assets'),
      port: parseInt(process.env.PORT || '3000'),
    }),
    EmailPlugin.init({
      devMode: true,
      outputPath: path.join(__dirname, '../static-email-output'),
      route: 'mailbox',
      handlers: defaultEmailHandlers,
      templatePath: path.join(__dirname, '../static-email-templates'),
      globalTemplateVars: {
        fromAddress: process.env.EMAIL_FROM || '"Vendure" <noreply@vendure.local>',
      },
    }),
    AdminUiPlugin.init({
      route: 'admin',
      port: parseInt(process.env.ADMIN_PORT || '3001'),
      adminUiConfig: {
        apiHost: 'auto',
        apiPort: 'auto',
      },
    }),
  ],
};
'@

    New-FileWithContent -Path "$appPath\src\vendure-config.ts" -Content $vendureConfigTs -DryRunMode:$DryRunMode

    # Crear index.ts
    $indexTs = @'
import { bootstrap } from '@vendure/core';
import { config } from './vendure-config';

bootstrap(config).catch(err => {
  console.error('Error starting Vendure server:', err);
  process.exit(1);
});
'@

    New-FileWithContent -Path "$appPath\src\index.ts" -Content $indexTs -DryRunMode:$DryRunMode

    # Crear index-worker.ts
    $indexWorkerTs = @'
import { bootstrapWorker } from '@vendure/core';
import { config } from './vendure-config';

bootstrapWorker(config).catch(err => {
  console.error('Error starting Vendure worker:', err);
  process.exit(1);
});
'@

    New-FileWithContent -Path "$appPath\src\index-worker.ts" -Content $indexWorkerTs -DryRunMode:$DryRunMode

    # Crear project.json para Nx
    $projectJson = @"
{
  "name": "$AppName",
  "`$schema": "../../node_modules/nx/schemas/project-schema.json",
  "sourceRoot": "apps/$AppName/src",
  "projectType": "application",
  "targets": {
    "serve": {
      "executor": "@nx/js:node",
      "defaultConfiguration": "development",
      "options": {
        "buildTarget": "$AppName:build",
        "runBuildTargetDependencies": false,
        "watch": true
      },
      "configurations": {
        "development": {
          "buildTarget": "$AppName:build:development"
        },
        "production": {
          "buildTarget": "$AppName:build:production"
        }
      }
    },
    "build": {
      "executor": "@nx/js:tsc",
      "outputs": ["{options.outputPath}"],
      "options": {
        "outputPath": "dist/apps/$AppName",
        "main": "apps/$AppName/src/index.ts",
        "tsConfig": "apps/$AppName/tsconfig.json",
        "assets": [
          "apps/$AppName/static-assets",
          "apps/$AppName/static-email-templates"
        ]
      },
      "configurations": {
        "development": {},
        "production": {
          "optimization": true,
          "sourceMap": false
        }
      }
    },
    "lint": {
      "executor": "@nx/eslint:lint",
      "options": {
        "lintFilePatterns": ["apps/$AppName/**/*.ts"]
      }
    }
  },
  "tags": ["type:app", "scope:vendure", "platform:backend"]
}
"@

    New-FileWithContent -Path "$appPath\project.json" -Content $projectJson -DryRunMode:$DryRunMode

    # Instalar dependencias
    if (-not $DryRunMode) {
        Write-ColorOutput -Message "Instalando dependencias (esto puede tardar 5-10 minutos)..." -Type 'Info'
        Push-Location $appPath
        try {
            pnpm install --shamefully-hoist
        } finally {
            Pop-Location
        }
    } else {
        Write-Host "[DRY-RUN] Would run: pnpm install --shamefully-hoist in $appPath" -ForegroundColor Magenta
    }

    Write-ColorOutput -Message "$AppName configurado exitosamente!" -Type 'Success'
}

# Verificar que Docker está corriendo
Write-ColorOutput -Message "Verificando que Docker está corriendo..." -Type 'Info'
try {
    $dockerCheck = docker ps 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "Docker not running"
    }
    Write-ColorOutput -Message "Docker está corriendo" -Type 'Success'
} catch {
    Write-ColorOutput -Message "Docker no está corriendo. Inicia Docker Desktop primero." -Type 'Error'
    exit 1
}

# Verificar que la base de datos ECOMMERCE está disponible
Write-ColorOutput -Message "Verificando base de datos Ecommerce..." -Type 'Info'
try {
    $dbCheck = docker exec entrepreneur-postgres-ecommerce pg_isready -U vendure 2>&1
    if ($dbCheck -match "accepting connections") {
        Write-ColorOutput -Message "Base de datos Ecommerce lista" -Type 'Success'
    } else {
        throw "Database not ready"
    }
} catch {
    Write-ColorOutput -Message "La base de datos Ecommerce no está lista." -Type 'Error'
    Write-ColorOutput -Message "Ejecuta: docker-compose up -d postgres-ecommerce" -Type 'Info'
    Write-ColorOutput -Message "O consulta: docs\guides\VENDURE-SETUP.md" -Type 'Info'
    exit 1
}

# Configurar Vendure Ecommerce (usando variables de .env con fallbacks)
$ecomDbPort = if ($env:POSTGRES_ECOMMERCE_PORT) { $env:POSTGRES_ECOMMERCE_PORT } else { "5433" }
$ecomApiPort = if ($env:VENDURE_ECOMMERCE_PORT) { $env:VENDURE_ECOMMERCE_PORT } else { "3002" }
$ecomAdminPort = if ($env:VENDURE_ECOMMERCE_ADMIN_PORT) { $env:VENDURE_ECOMMERCE_ADMIN_PORT } else { "3003" }
$ecomDbName = if ($env:POSTGRES_ECOMMERCE_DB) { $env:POSTGRES_ECOMMERCE_DB } else { "vendure_ecommerce" }
$ecomDbPass = if ($env:POSTGRES_ECOMMERCE_PASSWORD) { $env:POSTGRES_ECOMMERCE_PASSWORD } else { "vendure_ecommerce_pass" }

Setup-Vendure `
    -AppName "vendure-ecommerce" `
    -DbPort $ecomDbPort `
    -ApiPort $ecomApiPort `
    -AdminPort $ecomAdminPort `
    -DbName $ecomDbName `
    -DbPass $ecomDbPass `
    -DryRunMode:$DryRun

# Mensaje final
Write-Host ""
Write-Host "================================================" -ForegroundColor Green
Write-Host "🎉 ¡Vendure Ecommerce configurado exitosamente!" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Información importante:" -ForegroundColor Cyan
Write-Host ""
Write-ColorOutput -Message "OSW (OpenSearch Widget) pineado en versión $OSW_VERSION" -Type 'Warning'
Write-Host "  Esto previene bugs conocidos en el Admin UI de Vendure"
Write-Host ""
Write-Host "Próximos pasos:" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Iniciar Vendure Ecommerce:"
Write-Host "   cd apps\vendure-ecommerce && pnpm run dev"
Write-Host ""
Write-Host "2. O usar Nx (desde la raíz):"
Write-Host "   nx serve vendure-ecommerce"
Write-Host ""
Write-Host "URLs de acceso (Vendure Ecommerce):" -ForegroundColor Cyan
Write-Host ""
Write-Host "  - API GraphQL: http://localhost:3002/shop-api"
Write-Host "  - Admin UI: http://localhost:3003/admin"
Write-Host "  - Credenciales: superadmin / superadmin"
Write-Host ""
Write-Host "Resumen completo del sistema:" -ForegroundColor Cyan
Write-Host ""
Write-Host "Vendure Master:"
Write-Host "  - API: http://localhost:3000/shop-api"
Write-Host "  - Admin: http://localhost:3001/admin"
Write-Host ""
Write-Host "Vendure Ecommerce:"
Write-Host "  - API: http://localhost:3002/shop-api"
Write-Host "  - Admin: http://localhost:3003/admin"
Write-Host ""
Write-ColorOutput -Message "⚠ IMPORTANTE:" -Type 'Warning'
Write-Host "  - La primera vez que inicies Vendure, creará las tablas automáticamente"
Write-Host "  - Esto puede tardar 30-60 segundos"
Write-Host "  - Una vez iniciado, completa el setup wizard en el Admin UI"
Write-Host ""
Write-Host "Para más información consulta: docs\guides\VENDURE-SETUP.md"
Write-Host ""

#endregion
