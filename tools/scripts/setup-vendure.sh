#!/bin/bash
set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Versión de Vendure a instalar
VENDURE_VERSION="^3.1.0"  # Usa 3.1.x que es estable
OSW_VERSION="1.3.5"       # Pin OSW version para evitar bugs

echo -e "${BLUE}🚀 Entrepreneur OS - Vendure Setup${NC}"
echo "================================================"
echo ""

# Función para imprimir con color
print_status() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

# Verificar que estamos en la raíz del proyecto
if [ ! -f "package.json" ] || [ ! -d "apps" ]; then
    print_error "Este script debe ejecutarse desde la raíz del proyecto"
    exit 1
fi

# Función para configurar una instancia de Vendure
setup_vendure() {
    local APP_NAME=$1
    local DB_PORT=$2
    local API_PORT=$3
    local ADMIN_PORT=$4
    local DB_NAME=$5
    local DB_PASS=$6

    echo ""
    echo -e "${BLUE}📦 Configurando $APP_NAME...${NC}"
    echo "----------------------------------------"

    cd "apps/$APP_NAME"

    # Crear estructura de directorios
    print_info "Creando estructura de directorios..."
    mkdir -p src static-assets static-email-templates static-email-output migrations

    # Crear package.json
    print_info "Creando package.json..."
    cat > package.json << EOF
{
  "name": "$APP_NAME",
  "version": "1.0.0",
  "private": true,
  "scripts": {
    "dev": "concurrently -n SERVER,WORKER -c blue,green \"ts-node-dev --respawn --transpile-only src/index.ts\" \"ts-node-dev --respawn --transpile-only src/index-worker.ts\"",
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
EOF

    # Crear tsconfig.json
    print_info "Creando tsconfig.json..."
    cat > tsconfig.json << 'EOF'
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
EOF

    # Crear .env
    print_info "Creando archivo .env..."
    cat > .env << EOF
# Database Configuration
DB_HOST=localhost
DB_PORT=$DB_PORT
DB_USERNAME=vendure
DB_PASSWORD=$DB_PASS
DB_NAME=$DB_NAME

# Server Configuration
PORT=$API_PORT
ADMIN_PORT=$ADMIN_PORT

# Security
COOKIE_SECRET=$(openssl rand -base64 32 2>/dev/null || echo "change-me-in-production-$(date +%s)")
SUPERADMIN_USERNAME=superadmin
SUPERADMIN_PASSWORD=superadmin

# Email Configuration (Development)
EMAIL_FROM=noreply@$APP_NAME.local
EMAIL_TRANSPORT=file

# Environment
NODE_ENV=development
EOF

    # Crear vendure-config.ts
    print_info "Creando vendure-config.ts..."
    cat > src/vendure-config.ts << 'CONFIGEOF'
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
CONFIGEOF

    # Crear index.ts
    print_info "Creando index.ts..."
    cat > src/index.ts << 'EOF'
import { bootstrap } from '@vendure/core';
import { config } from './vendure-config';

bootstrap(config).catch(err => {
  console.error('Error starting Vendure server:', err);
  process.exit(1);
});
EOF

    # Crear index-worker.ts
    print_info "Creando index-worker.ts..."
    cat > src/index-worker.ts << 'EOF'
import { bootstrapWorker } from '@vendure/core';
import { config } from './vendure-config';

bootstrapWorker(config).catch(err => {
  console.error('Error starting Vendure worker:', err);
  process.exit(1);
});
EOF

    # Crear project.json para Nx
    print_info "Creando project.json (Nx integration)..."
    cat > project.json << EOF
{
  "name": "$APP_NAME",
  "\$schema": "../../node_modules/nx/schemas/project-schema.json",
  "sourceRoot": "apps/$APP_NAME/src",
  "projectType": "application",
  "targets": {
    "serve": {
      "executor": "@nx/js:node",
      "defaultConfiguration": "development",
      "options": {
        "buildTarget": "$APP_NAME:build",
        "runBuildTargetDependencies": false,
        "watch": true
      },
      "configurations": {
        "development": {
          "buildTarget": "$APP_NAME:build:development"
        },
        "production": {
          "buildTarget": "$APP_NAME:build:production"
        }
      }
    },
    "build": {
      "executor": "@nx/js:tsc",
      "outputs": ["{options.outputPath}"],
      "options": {
        "outputPath": "dist/apps/$APP_NAME",
        "main": "apps/$APP_NAME/src/index.ts",
        "tsConfig": "apps/$APP_NAME/tsconfig.json",
        "assets": [
          "apps/$APP_NAME/static-assets",
          "apps/$APP_NAME/static-email-templates"
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
        "lintFilePatterns": ["apps/$APP_NAME/**/*.ts"]
      }
    }
  },
  "tags": ["type:app", "scope:vendure", "platform:backend"]
}
EOF

    # Instalar dependencias
    print_info "Instalando dependencias (esto puede tardar)..."
    pnpm install --shamefully-hoist

    cd ../..

    print_status "$APP_NAME configurado exitosamente!"
}

# Verificar que Docker está corriendo
print_info "Verificando que Docker está corriendo..."
if ! docker ps > /dev/null 2>&1; then
    print_error "Docker no está corriendo. Inicia Docker Desktop primero."
    exit 1
fi
print_status "Docker está corriendo"

# Verificar que las bases de datos están disponibles
print_info "Verificando bases de datos..."
MASTER_DB_READY=$(docker exec entrepreneur-postgres-master pg_isready -U vendure 2>&1 | grep "accepting connections" || echo "")
ECOMMERCE_DB_READY=$(docker exec entrepreneur-postgres-ecommerce pg_isready -U vendure 2>&1 | grep "accepting connections" || echo "")

if [ -z "$MASTER_DB_READY" ] || [ -z "$ECOMMERCE_DB_READY" ]; then
    print_error "Las bases de datos no están listas. Ejecuta: pnpm docker:up"
    exit 1
fi
print_status "Bases de datos listas"

# Configurar Vendure Master
setup_vendure "vendure-master" "5432" "3000" "3001" "vendure_master" "vendure_master_pass"

# Configurar Vendure Ecommerce
setup_vendure "vendure-ecommerce" "5433" "3002" "3003" "vendure_ecommerce" "vendure_ecommerce_pass"

# Mensaje final
echo ""
echo "================================================"
echo -e "${GREEN}🎉 ¡Vendure configurado exitosamente!${NC}"
echo "================================================"
echo ""
echo -e "${BLUE}Información importante:${NC}"
echo ""
print_warning "OSW (OpenSearch Widget) pineado en versión $OSW_VERSION"
echo "  Esto previene bugs conocidos en el Admin UI de Vendure"
echo ""
echo -e "${BLUE}Próximos pasos:${NC}"
echo ""
echo "1. Iniciar Vendure Master:"
echo "   cd apps/vendure-master && pnpm run dev"
echo ""
echo "2. Iniciar Vendure Ecommerce:"
echo "   cd apps/vendure-ecommerce && pnpm run dev"
echo ""
echo "3. O usar Nx (desde la raíz):"
echo "   nx serve vendure-master"
echo "   nx serve vendure-ecommerce"
echo ""
echo -e "${BLUE}URLs de acceso:${NC}"
echo ""
echo "Vendure Master:"
echo "  - API GraphQL: http://localhost:3000/shop-api"
echo "  - Admin UI: http://localhost:3001/admin"
echo "  - Credenciales: superadmin / superadmin"
echo ""
echo "Vendure Ecommerce:"
echo "  - API GraphQL: http://localhost:3002/shop-api"
echo "  - Admin UI: http://localhost:3003/admin"
echo "  - Credenciales: superadmin / superadmin"
echo ""
echo -e "${YELLOW}⚠ IMPORTANTE:${NC}"
echo "  - La primera vez que inicies Vendure, creará las tablas automáticamente"
echo "  - Esto puede tardar 30-60 segundos"
echo "  - Una vez iniciado, completa el setup wizard en el Admin UI"
echo ""