#!/bin/bash
set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔄 Entrepreneur OS - Database Migrations${NC}"
echo "================================================"
echo ""

# Funciones de output
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
    print_error "This script must be run from the project root"
    exit 1
fi

# Verificar que las aplicaciones Vendure existen
if [ ! -d "apps/vendure-master" ]; then
    print_error "vendure-master app not found. Run setup-vendure.sh first."
    exit 1
fi

if [ ! -d "apps/vendure-ecommerce" ]; then
    print_error "vendure-ecommerce app not found. Run setup-vendure.sh first."
    exit 1
fi

# Función para ejecutar migraciones en una base de datos
run_migrations() {
    local APP_NAME=$1
    local APP_DISPLAY=$2

    echo ""
    print_info "Running migrations for $APP_DISPLAY..."

    cd "apps/$APP_NAME"

    # Verificar que node_modules existe
    if [ ! -d "node_modules" ]; then
        print_warning "Dependencies not installed for $APP_NAME. Installing..."
        pnpm install
    fi

    # Verificar si hay migraciones
    if [ ! -d "migrations" ] || [ -z "$(ls -A migrations 2>/dev/null)" ]; then
        print_warning "No migrations found for $APP_NAME"
        cd ../..
        return 0
    fi

    # Ejecutar migraciones
    print_info "Applying migrations..."
    pnpm run migration:run || {
        print_error "Migration failed for $APP_NAME"
        cd ../..
        return 1
    }

    cd ../..

    print_status "$APP_DISPLAY migrations applied successfully"
}

print_info "This will apply TypeORM migrations to the databases"
echo ""

# Ejecutar migraciones para Vendure Master
run_migrations "vendure-master" "Vendure Master"

# Ejecutar migraciones para Vendure Ecommerce
run_migrations "vendure-ecommerce" "Vendure Ecommerce"

# Mensaje final
echo ""
echo "================================================"
echo -e "${GREEN}✅ Database migrations complete!${NC}"
echo "================================================"
echo ""
echo -e "${BLUE}Migration Status:${NC}"
echo "  - vendure-master: Migrations applied"
echo "  - vendure-ecommerce: Migrations applied"
echo ""
echo -e "${YELLOW}Important Notes:${NC}"
echo ""
echo "1. Development Mode (synchronize: true):"
echo "   - In development, Vendure auto-creates/updates tables"
echo "   - Migrations are NOT strictly required"
echo "   - Use migrations for controlled schema changes"
echo ""
echo "2. Production Mode:"
echo "   - DISABLE synchronize in vendure-config.ts"
echo "   - ALWAYS use migrations for schema changes"
echo "   - Generate migrations with: pnpm run migration:generate"
echo ""
echo "3. Creating New Migrations:"
echo "   - Make changes to entities"
echo "   - Generate migration: cd apps/vendure-master && pnpm run migration:generate -- MyMigration"
echo "   - Review generated migration in migrations/"
echo "   - Apply with: ./tools/scripts/migrate-databases.sh"
echo ""
echo -e "${BLUE}Next Steps:${NC}"
echo "  1. Start Vendure instances:"
echo "     pnpm run dev:vendure"
echo ""
echo "  2. Verify schema in database:"
echo "     docker exec -it entrepreneur-postgres-master psql -U vendure -d vendure_master"
echo ""
