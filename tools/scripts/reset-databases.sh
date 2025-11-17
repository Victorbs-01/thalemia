#!/bin/bash
set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${RED}⚠️  Entrepreneur OS - Database Reset${NC}"
echo "================================================"
echo ""
echo -e "${RED}WARNING: This will DELETE all data in the databases!${NC}"
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

# Verificar que existe .env
if [ ! -f ".env" ]; then
    print_error ".env file not found. Please create it from .env.example:"
    echo "  cp .env.example .env"
    echo "  # Then edit .env with your configuration"
    exit 1
fi

# Cargar variables de entorno
print_info "Loading configuration from .env..."
set -a
source .env
set +a

# Usar valores por defecto si no están definidos
POSTGRES_MASTER_DB=${POSTGRES_MASTER_DB:-vendure_master}
POSTGRES_MASTER_USER=${POSTGRES_MASTER_USER:-vendure}
POSTGRES_ECOMMERCE_DB=${POSTGRES_ECOMMERCE_DB:-vendure_ecommerce}
POSTGRES_ECOMMERCE_USER=${POSTGRES_ECOMMERCE_USER:-vendure}

# Confirmación del usuario
echo -e "${YELLOW}Databases to be reset:${NC}"
echo "  - $POSTGRES_MASTER_DB (Master)"
echo "  - $POSTGRES_ECOMMERCE_DB (Ecommerce)"
echo ""
read -p "Are you sure you want to DELETE all data? (type 'yes' to confirm): " confirmation

if [ "$confirmation" != "yes" ]; then
    echo ""
    print_info "Reset cancelled. No changes were made."
    exit 0
fi

# Verificar que Docker está corriendo
echo ""
print_info "Checking Docker is running..."
if ! docker ps > /dev/null 2>&1; then
    print_error "Docker is not running. Please start Docker first."
    exit 1
fi
print_status "Docker is running"

# Verificar que los contenedores de Postgres están corriendo
print_info "Checking PostgreSQL containers..."
if ! docker ps | grep -q "entrepreneur-postgres-master"; then
    print_error "postgres-master container is not running. Run: pnpm docker:up"
    exit 1
fi

if ! docker ps | grep -q "entrepreneur-postgres-ecommerce"; then
    print_error "postgres-ecommerce container is not running. Run: pnpm docker:up"
    exit 1
fi
print_status "PostgreSQL containers are running"

# Función para resetear una base de datos
reset_database() {
    local CONTAINER=$1
    local DB_NAME=$2
    local DB_USER=$3

    echo ""
    print_info "Resetting database: $DB_NAME in container: $CONTAINER"

    # Terminar conexiones activas
    print_info "Terminating active connections..."
    docker exec $CONTAINER psql -U postgres -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname='$DB_NAME' AND pid <> pg_backend_pid();" 2>/dev/null || true

    # Eliminar la base de datos si existe
    print_info "Dropping database: $DB_NAME"
    docker exec $CONTAINER psql -U postgres -c "DROP DATABASE IF EXISTS $DB_NAME;" || {
        print_error "Failed to drop database $DB_NAME"
        return 1
    }

    # Recrear la base de datos
    print_info "Creating database: $DB_NAME"
    docker exec $CONTAINER psql -U postgres -c "CREATE DATABASE $DB_NAME OWNER $DB_USER;" || {
        print_error "Failed to create database $DB_NAME"
        return 1
    }

    print_status "Database $DB_NAME reset successfully"
}

# Resetear Vendure Master database
reset_database "entrepreneur-postgres-master" "$POSTGRES_MASTER_DB" "$POSTGRES_MASTER_USER"

# Resetear Vendure Ecommerce database
reset_database "entrepreneur-postgres-ecommerce" "$POSTGRES_ECOMMERCE_DB" "$POSTGRES_ECOMMERCE_USER"

# Mensaje final
echo ""
echo "================================================"
echo -e "${GREEN}✅ Databases reset complete!${NC}"
echo "================================================"
echo ""
echo -e "${BLUE}Database Details:${NC}"
echo ""
echo "Vendure Master:"
echo "  - Database: $POSTGRES_MASTER_DB (EMPTY)"
echo "  - User: $POSTGRES_MASTER_USER"
echo ""
echo "Vendure Ecommerce:"
echo "  - Database: $POSTGRES_ECOMMERCE_DB (EMPTY)"
echo "  - User: $POSTGRES_ECOMMERCE_USER"
echo ""
echo -e "${BLUE}Next Steps:${NC}"
echo "  1. If Vendure is already set up, restart the instances:"
echo "     cd apps/vendure-master && pnpm run dev"
echo "     cd apps/vendure-ecommerce && pnpm run dev"
echo ""
echo "  2. Vendure will recreate tables automatically (synchronize: true)"
echo ""
echo "  3. You may want to populate with test data:"
echo "     ./tools/scripts/seed-databases.sh"
echo ""
