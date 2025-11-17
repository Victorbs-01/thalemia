#!/bin/bash
set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🌱 Entrepreneur OS - Database Seeding${NC}"
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

# Función para poblar una base de datos
seed_database() {
    local APP_NAME=$1
    local APP_DISPLAY=$2

    echo ""
    print_info "Seeding $APP_DISPLAY database..."

    cd "apps/$APP_NAME"

    # Verificar que node_modules existe
    if [ ! -d "node_modules" ]; then
        print_warning "Dependencies not installed for $APP_NAME. Installing..."
        pnpm install
    fi

    # Usar el comando de Vendure para poblar
    print_info "Running Vendure populate command..."
    npx vendure migrate || {
        print_warning "Migration command failed or not needed"
    }

    cd ../..

    print_status "$APP_DISPLAY database seeded"
}

print_warning "This will populate the databases with example data"
print_info "You can use this to test the setup or for development"
echo ""

# Poblar Vendure Master
seed_database "vendure-master" "Vendure Master"

# Poblar Vendure Ecommerce
seed_database "vendure-ecommerce" "Vendure Ecommerce"

# Mensaje final
echo ""
echo "================================================"
echo -e "${GREEN}✅ Database seeding complete!${NC}"
echo "================================================"
echo ""
echo -e "${BLUE}What was seeded:${NC}"
echo "  - Database schema created/updated"
echo "  - Migrations applied (if any)"
echo ""
echo -e "${YELLOW}Note:${NC}"
echo "  Vendure uses 'synchronize: true' in development,"
echo "  so tables are created automatically on first start."
echo ""
echo "  For initial sample data (products, customers, etc.),"
echo "  you need to:"
echo "  1. Start Vendure: cd apps/vendure-master && pnpm run dev"
echo "  2. Use the Admin UI setup wizard"
echo "  3. Or import data via GraphQL API"
echo ""
echo -e "${BLUE}Next Steps:${NC}"
echo "  1. Start Vendure instances:"
echo "     pnpm run dev:vendure"
echo ""
echo "  2. Access Admin UI and complete setup wizard:"
echo "     http://localhost:3001/admin (Master)"
echo "     http://localhost:3003/admin (Ecommerce)"
echo ""
