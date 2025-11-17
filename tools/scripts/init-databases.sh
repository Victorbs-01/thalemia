#!/bin/bash
set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=' Entrepreneur OS - Database Initialization${NC}"
echo "================================================"
echo ""

# Funciones de output
print_status() {
    echo -e "${GREEN}${NC} $1"
}

print_warning() {
    echo -e "${YELLOW} ${NC} $1"
}

print_error() {
    echo -e "${RED}${NC} $1"
}

print_info() {
    echo -e "${BLUE}9${NC} $1"
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
POSTGRES_MASTER_PASSWORD=${POSTGRES_MASTER_PASSWORD:-vendure_master_pass}

POSTGRES_ECOMMERCE_DB=${POSTGRES_ECOMMERCE_DB:-vendure_ecommerce}
POSTGRES_ECOMMERCE_USER=${POSTGRES_ECOMMERCE_USER:-vendure}
POSTGRES_ECOMMERCE_PASSWORD=${POSTGRES_ECOMMERCE_PASSWORD:-vendure_ecommerce_pass}

# Verificar que Docker está corriendo
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

# Función para inicializar una base de datos
init_database() {
    local CONTAINER=$1
    local DB_NAME=$2
    local DB_USER=$3
    local DB_PASS=$4

    echo ""
    print_info "Initializing database: $DB_NAME in container: $CONTAINER"

    # Verificar si la base de datos ya existe
    DB_EXISTS=$(docker exec $CONTAINER psql -U postgres -tAc "SELECT 1 FROM pg_database WHERE datname='$DB_NAME'" 2>/dev/null || echo "")

    if [ "$DB_EXISTS" = "1" ]; then
        print_warning "Database $DB_NAME already exists, skipping creation"
        return 0
    fi

    # Crear la base de datos
    print_info "Creating database: $DB_NAME"
    docker exec $CONTAINER psql -U postgres -c "CREATE DATABASE $DB_NAME OWNER $DB_USER;" || {
        print_error "Failed to create database $DB_NAME"
        return 1
    }

    print_status "Database $DB_NAME initialized successfully"
}

# Inicializar Vendure Master database
init_database "entrepreneur-postgres-master" "$POSTGRES_MASTER_DB" "$POSTGRES_MASTER_USER" "$POSTGRES_MASTER_PASSWORD"

# Inicializar Vendure Ecommerce database
init_database "entrepreneur-postgres-ecommerce" "$POSTGRES_ECOMMERCE_DB" "$POSTGRES_ECOMMERCE_USER" "$POSTGRES_ECOMMERCE_PASSWORD"

# Mensaje final
echo ""
echo "================================================"
echo -e "${GREEN} Database initialization complete!${NC}"
echo "================================================"
echo ""
echo -e "${BLUE}Database Details:${NC}"
echo ""
echo "Vendure Master:"
echo "  - Database: $POSTGRES_MASTER_DB"
echo "  - User: $POSTGRES_MASTER_USER"
echo "  - Container: entrepreneur-postgres-master"
echo "  - Port: 5432 (internal), ${POSTGRES_MASTER_PORT:-5432} (external)"
echo ""
echo "Vendure Ecommerce:"
echo "  - Database: $POSTGRES_ECOMMERCE_DB"
echo "  - User: $POSTGRES_ECOMMERCE_USER"
echo "  - Container: entrepreneur-postgres-ecommerce"
echo "  - Port: 5432 (internal), 5433 (external)"
echo ""
echo -e "${BLUE}Next Steps:${NC}"
echo "  1. Run the Vendure setup script:"
echo "     ./tools/scripts/setup-vendure.sh"
echo ""
echo "  2. Or setup manually by following the runbooks in:"
echo "     docs/runbooks/vendure-master-install.md"
echo "     docs/runbooks/vendure-ecommerce-install.md"
echo ""
