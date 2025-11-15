# setup-vendure.ps1
# Script de configuración de Vendure para Entrepreneur OS
# Ejecutar desde la raíz del proyecto

[CmdletBinding()]
param()

# Configuración
$ErrorActionPreference = "Stop"
$VENDURE_VERSION = "^3.1.0"
$OSW_VERSION = "1.3.5"

# Colores para output
function Write-Success { Write-Host "✓ $args" -ForegroundColor Green }
function Write-Info { Write-Host "ℹ $args" -ForegroundColor Blue }
function Write-Warning { Write-Host "⚠ $args" -ForegroundColor Yellow }
function Write-Err { Write-Host "✗ $args" -ForegroundColor Red }

Write-Host "`n🚀 Entrepreneur OS - Vendure Setup" -ForegroundColor Blue
Write-Host "================================================`n"

# Verificar que estamos en la raíz del proyecto
if (-not (Test-Path "package.json") -or -not (Test-Path "apps")) {
    Write-Err "Este script debe ejecutarse desde la raíz del proyecto"
    exit 1
}

# Función para crear package.json con ConvertTo-Json
function New-VendurePackageJson {
    param(
        [string]$AppName,
        [string]$VendureVersion,
        [string]$OswVersion
    )

    $packageData = [ordered]@{
        name = $AppName
        version = "1.0.0"
        private = $true
        scripts = [ordered]@{
            dev = "ts-node-dev --respawn --transpile-only src/index.ts"
            "dev:worker" = "ts-node-dev --respawn --transpile-only src/index-worker.ts"
            build = "tsc"
            start = "node dist/index.js"
            "start:worker" = "node dist/index-worker.js"
        }
        dependencies = [ordered]@{
            "@vendure/core" = $VendureVersion
            "@vendure/admin-ui" = $VendureVersion
            "@vendure/asset-server-plugin" = $VendureVersion
            "@vendure/email-plugin" = $VendureVersion
            pg = "^8.12.0"
            dotenv = "^16.4.5"
        }
        devDependencies = [ordered]@{
            "@types/node" = "^20.11.0"
            "@vendure/ui-devkit" = $VendureVersion
            "ts-node" = "^10.9.2"
            "ts-node-dev" = "^2.0.0"
            typescript = "^5.3.3"
        }
        pnpm = [ordered]@{
            overrides = [ordered]@{
                osw = $OswVersion
            }
        }
    }

    return ($packageData | ConvertTo-Json -Depth 10)
}

# Función para crear tsconfig.json
function New-VendureTsConfig {
    $tsconfig = [ordered]@{
        extends = "../../tsconfig.base.json"
        compilerOptions = [ordered]@{
            outDir = "./dist"
            rootDir = "./src"
            module = "commonjs"
            target = "ES2021"
            lib = @("ES2021")
            emitDecoratorMetadata = $true
            experimentalDecorators = $true
            esModuleInterop = $true
            skipLibCheck = $true
            resolveJsonModule = $true
            allowSyntheticDefaultImports = $true
            strict = $false
            sourceMap = $true
        }
        include = @("src/**/*")
        exclude = @("node_modules", "dist", "migrations")
    }

    return ($tsconfig | ConvertTo-Json -Depth 10)
}

# Función para crear vendure-config.ts
function New-VendureConfig {
    return @'
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
    synchronize: true,
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
}

# Función para crear index.ts
function New-VendureIndex {
    return @'
import { bootstrap } from '@vendure/core';
import { config } from './vendure-config';

bootstrap(config).catch(err => {
  console.error('Error starting Vendure server:', err);
  process.exit(1);
});
'@
}

# Función para crear index-worker.ts
function New-VendureWorker {
    return @'
import { bootstrapWorker } from '@vendure/core';
import { config } from './vendure-config';

bootstrapWorker(config).catch(err => {
  console.error('Error starting Vendure worker:', err);
  process.exit(1);
});
'@
}

# Función para crear project.json
function New-VendureProjectJson {
    param([string]$AppName)

    $projectData = [ordered]@{
        name = $AppName
        '$schema' = "../../node_modules/nx/schemas/project-schema.json"
        sourceRoot = "apps/$AppName/src"
        projectType = "application"
        targets = [ordered]@{
            serve = [ordered]@{
                executor = "@nx/js:node"
                defaultConfiguration = "development"
                options = [ordered]@{
                    buildTarget = "$AppName:build"
                    runBuildTargetDependencies = $false
                    watch = $true
                }
            }
            build = [ordered]@{
                executor = "@nx/js:tsc"
                outputs = @("{options.outputPath}")
                options = [ordered]@{
                    outputPath = "dist/apps/$AppName"
                    main = "apps/$AppName/src/index.ts"
                    tsConfig = "apps/$AppName/tsconfig.json"
                    assets = @(
                        "apps/$AppName/static-assets",
                        "apps/$AppName/static-email-templates"
                    )
                }
            }
            lint = [ordered]@{
                executor = "@nx/eslint:lint"
                options = [ordered]@{
                    lintFilePatterns = @("apps/$AppName/**/*.ts")
                }
            }
        }
        tags = @("type:app", "scope:vendure", "platform:backend")
    }

    return ($projectData | ConvertTo-Json -Depth 10)
}

# Función principal para configurar Vendure
function Initialize-VendureApp {
    param(
        [string]$AppName,
        [string]$DbPort,
        [string]$ApiPort,
        [string]$AdminPort,
        [string]$DbName,
        [string]$DbPass
    )

    Write-Host "`n📦 Configurando $AppName..." -ForegroundColor Blue
    Write-Host "----------------------------------------"

    Push-Location "apps\$AppName"

    try {
        # Crear estructura de directorios
        Write-Info "Creando estructura de directorios..."
        $dirs = @("src", "static-assets", "static-email-templates", "static-email-output", "migrations")
        foreach ($dir in $dirs) {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
        }

        # Crear package.json
        Write-Info "Creando package.json..."
        New-VendurePackageJson -AppName $AppName -VendureVersion $VENDURE_VERSION -OswVersion $OSW_VERSION |
                Set-Content -Path "package.json" -Encoding UTF8

        # Crear tsconfig.json
        Write-Info "Creando tsconfig.json..."
        New-VendureTsConfig | Set-Content -Path "tsconfig.json" -Encoding UTF8

        # Generar COOKIE_SECRET
        $bytes = New-Object byte[] 32
        $rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
        $rng.GetBytes($bytes)
        $cookieSecret = [System.Convert]::ToBase64String($bytes)

        # Crear .env
        Write-Info "Creando archivo .env..."
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
        $envContent | Set-Content -Path ".env" -Encoding UTF8

        # Crear archivos TypeScript
        Write-Info "Creando archivos de configuración..."
        New-VendureConfig | Set-Content -Path "src\vendure-config.ts" -Encoding UTF8
        New-VendureIndex | Set-Content -Path "src\index.ts" -Encoding UTF8
        New-VendureWorker | Set-Content -Path "src\index-worker.ts" -Encoding UTF8

        # Crear project.json
        Write-Info "Creando project.json (Nx integration)..."
        New-VendureProjectJson -AppName $AppName | Set-Content -Path "project.json" -Encoding UTF8

        # Instalar dependencias
        Write-Info "Instalando dependencias (esto puede tardar)..."
        pnpm install --shamefully-hoist 2>&1 | Out-Null

        Write-Success "$AppName configurado exitosamente!"
    }
    catch {
        Write-Err "Error configurando $AppName : $_"
        throw
    }
    finally {
        Pop-Location
    }
}

# Verificar Docker
Write-Info "Verificando que Docker está corriendo..."
try {
    docker ps 2>&1 | Out-Null
    Write-Success "Docker está corriendo"
} catch {
    Write-Err "Docker no está corriendo. Inicia Docker Desktop primero."
    exit 1
}

# Verificar bases de datos
Write-Info "Verificando bases de datos..."
$masterDbReady = docker exec entrepreneur-postgres-master pg_isready -U vendure 2>&1 | Select-String "accepting connections"
$ecommerceDbReady = docker exec entrepreneur-postgres-ecommerce pg_isready -U vendure 2>&1 | Select-String "accepting connections"

if (-not $masterDbReady -or -not $ecommerceDbReady) {
    Write-Err "Las bases de datos no están listas. Ejecuta: pnpm docker:up"
    exit 1
}
Write-Success "Bases de datos listas"

# Configurar ambas instancias
Initialize-VendureApp -AppName "vendure-master" -DbPort "5432" -ApiPort "3000" -AdminPort "3001" -DbName "vendure_master" -DbPass "vendure_master_pass"
Initialize-VendureApp -AppName "vendure-ecommerce" -DbPort "5433" -ApiPort "3002" -AdminPort "3003" -DbName "vendure_ecommerce" -DbPass "vendure_ecommerce_pass"

# Crear .pnpmfile.cjs en la raíz
Write-Info "Creando .pnpmfile.cjs para forzar OSW $OSW_VERSION..."
$pnpmfile = @"
// .pnpmfile.cjs
function readPackage(pkg, context) {
  if (pkg.dependencies && pkg.dependencies['osw']) {
    pkg.dependencies['osw'] = '$OSW_VERSION';
    context.log('Forcing osw@$OSW_VERSION in ' + pkg.name);
  }

  if (pkg.devDependencies && pkg.devDependencies['osw']) {
    pkg.devDependencies['osw'] = '$OSW_VERSION';
    context.log('Forcing osw@$OSW_VERSION in ' + pkg.name + ' (dev)');
  }

  return pkg;
}

module.exports = {
  hooks: {
    readPackage
  }
};
"@
$pnpmfile | Set-Content -Path ".pnpmfile.cjs" -Encoding UTF8

# Mensaje final
Write-Host "`n================================================" -ForegroundColor Green
Write-Host "🎉 ¡Vendure configurado exitosamente!" -ForegroundColor Green
Write-Host "================================================`n"

Write-Host "Información importante:" -ForegroundColor Blue
Write-Warning "OSW (OpenSearch Widget) pineado en versión $OSW_VERSION"
Write-Host "  Esto previene bugs conocidos en el Admin UI de Vendure`n"

Write-Host "Próximos pasos:" -ForegroundColor Blue
Write-Host ""
Write-Host "1. Iniciar Vendure Master:"
Write-Host "   cd apps\vendure-master && pnpm run dev"
Write-Host ""
Write-Host "2. Iniciar Vendure Ecommerce:"
Write-Host "   cd apps\vendure-ecommerce && pnpm run dev"
Write-Host ""
Write-Host "3. O usar Nx (desde la raíz):"
Write-Host "   pnpm exec nx serve vendure-master"
Write-Host "   pnpm exec nx serve vendure-ecommerce"
Write-Host ""
Write-Host "URLs de acceso:" -ForegroundColor Blue
Write-Host ""
Write-Host "Vendure Master:"
Write-Host "  - API GraphQL: http://localhost:3000/shop-api"
Write-Host "  - Admin UI: http://localhost:3001/admin"
Write-Host "  - Credenciales: superadmin / superadmin"
Write-Host ""
Write-Host "Vendure Ecommerce:"
Write-Host "  - API GraphQL: http://localhost:3002/shop-api"
Write-Host "  - Admin UI: http://localhost:3003/admin"
Write-Host "  - Credenciales: superadmin / superadmin"
Write-Host ""
Write-Warning "IMPORTANTE:"
Write-Host "  - La primera vez que inicies Vendure, creará las tablas automáticamente"
Write-Host "  - Esto puede tardar 30-60 segundos"
Write-Host "  - Una vez iniciado, completa el setup wizard en el Admin UI"
Write-Host ""
