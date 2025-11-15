#!/bin/bash
# collect-inventory.sh
# Script para recolectar inventario automático de servidores
# Ejecutar en cada nodo: curl -fsSL https://raw.githubusercontent.com/tu-repo/main/scripts/collect-inventory.sh | bash

set -e

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  System Inventory Collector v1.0        ${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Detectar hostname
HOSTNAME=$(hostname)
echo -e "${GREEN}📍 Hostname:${NC} $HOSTNAME"

# Crear directorio de output
OUTPUT_DIR="/tmp/inventory-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$OUTPUT_DIR"

# ============================================
# 1. INFORMACIÓN DEL SISTEMA
# ============================================
echo -e "\n${YELLOW}[1/10]${NC} Recopilando información del sistema..."

cat > "$OUTPUT_DIR/system.json" <<EOF
{
  "hostname": "$(hostname)",
  "fqdn": "$(hostname -f 2>/dev/null || echo 'N/A')",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "uptime": "$(uptime -p 2>/dev/null || uptime)",
  "kernel": "$(uname -r)",
  "os": {
    "name": "$(lsb_release -ds 2>/dev/null || cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)",
    "version": "$(lsb_release -rs 2>/dev/null || cat /etc/os-release | grep VERSION_ID | cut -d'"' -f2)",
    "codename": "$(lsb_release -cs 2>/dev/null || echo 'unknown')",
    "arch": "$(uname -m)"
  }
}
EOF

# ============================================
# 2. HARDWARE
# ============================================
echo -e "${YELLOW}[2/10]${NC} Detectando hardware..."

# CPU
CPU_MODEL=$(lscpu | grep "Model name" | cut -d':' -f2 | xargs)
CPU_CORES=$(nproc)
CPU_THREADS=$(lscpu | grep "^CPU(s):" | awk '{print $2}')

# RAM
RAM_TOTAL=$(free -h | awk '/^Mem:/ {print $2}')
RAM_USED=$(free -h | awk '/^Mem:/ {print $3}')
RAM_AVAILABLE=$(free -h | awk '/^Mem:/ {print $7}')

# GPU (NVIDIA)
if command -v nvidia-smi &> /dev/null; then
    GPU_INFO=$(nvidia-smi --query-gpu=name,driver_version,memory.total --format=csv,noheader)
else
    GPU_INFO="No NVIDIA GPU detected"
fi

# Discos
DISK_INFO=$(lsblk -J -o NAME,SIZE,TYPE,MOUNTPOINT,FSTYPE 2>/dev/null || echo '{"blockdevices":[]}')

cat > "$OUTPUT_DIR/hardware.json" <<EOF
{
  "cpu": {
    "model": "$CPU_MODEL",
    "cores": $CPU_CORES,
    "threads": $CPU_THREADS
  },
  "memory": {
    "total": "$RAM_TOTAL",
    "used": "$RAM_USED",
    "available": "$RAM_AVAILABLE"
  },
  "gpu": "$GPU_INFO",
  "disks": $DISK_INFO
}
EOF

# ============================================
# 3. RED
# ============================================
echo -e "${YELLOW}[3/10]${NC} Analizando configuración de red..."

# Interfaces
INTERFACES=$(ip -j addr show 2>/dev/null || echo '[]')

# Tailscale status
if command -v tailscale &> /dev/null; then
    TAILSCALE_STATUS=$(tailscale status --json 2>/dev/null || echo '{"Err":"not running"}')
    TAILSCALE_IP=$(tailscale ip -4 2>/dev/null || echo "not configured")
else
    TAILSCALE_STATUS='{"Err":"not installed"}'
    TAILSCALE_IP="not installed"
fi

# Puertos abiertos
OPEN_PORTS=$(ss -tuln | grep LISTEN | awk '{print $5}' | cut -d':' -f2 | sort -n | uniq | tr '\n' ',' | sed 's/,$//')

cat > "$OUTPUT_DIR/network.json" <<EOF
{
  "interfaces": $INTERFACES,
  "tailscale": {
    "installed": $(command -v tailscale &> /dev/null && echo "true" || echo "false"),
    "ip": "$TAILSCALE_IP",
    "status": $TAILSCALE_STATUS
  },
  "open_ports": "$OPEN_PORTS",
  "default_gateway": "$(ip route | grep default | awk '{print $3}')"
}
EOF

# ============================================
# 4. DOCKER
# ============================================
echo -e "${YELLOW}[4/10]${NC} Verificando Docker..."

if command -v docker &> /dev/null; then
    DOCKER_VERSION=$(docker --version 2>/dev/null || echo "error")
    DOCKER_COMPOSE_VERSION=$(docker compose version 2>/dev/null || echo "not installed")
    DOCKER_RUNNING=$(systemctl is-active docker 2>/dev/null || echo "unknown")
    DOCKER_CONTAINERS=$(docker ps -a --format json 2>/dev/null | jq -s '.' || echo '[]')
    DOCKER_IMAGES=$(docker images --format json 2>/dev/null | jq -s '.' || echo '[]')
    DOCKER_NETWORKS=$(docker network ls --format json 2>/dev/null | jq -s '.' || echo '[]')
    DOCKER_VOLUMES=$(docker volume ls --format json 2>/dev/null | jq -s '.' || echo '[]')

    # Docker daemon config
    if [ -f /etc/docker/daemon.json ]; then
        DOCKER_DAEMON_CONFIG=$(cat /etc/docker/daemon.json)
    else
        DOCKER_DAEMON_CONFIG='{}'
    fi
else
    DOCKER_VERSION="not installed"
    DOCKER_COMPOSE_VERSION="not installed"
    DOCKER_RUNNING="not installed"
    DOCKER_CONTAINERS='[]'
    DOCKER_IMAGES='[]'
    DOCKER_NETWORKS='[]'
    DOCKER_VOLUMES='[]'
    DOCKER_DAEMON_CONFIG='{}'
fi

cat > "$OUTPUT_DIR/docker.json" <<EOF
{
  "installed": $(command -v docker &> /dev/null && echo "true" || echo "false"),
  "version": "$DOCKER_VERSION",
  "compose_version": "$DOCKER_COMPOSE_VERSION",
  "running": "$DOCKER_RUNNING",
  "containers": $DOCKER_CONTAINERS,
  "images": $DOCKER_IMAGES,
  "networks": $DOCKER_NETWORKS,
  "volumes": $DOCKER_VOLUMES,
  "daemon_config": $DOCKER_DAEMON_CONFIG
}
EOF

# ============================================
# 5. KUBERNETES (si existe)
# ============================================
echo -e "${YELLOW}[5/10]${NC} Verificando Kubernetes..."

if command -v kubectl &> /dev/null; then
    K8S_VERSION=$(kubectl version --client --short 2>/dev/null || echo "error")
    K8S_NODES=$(kubectl get nodes -o json 2>/dev/null || echo '{"items":[]}')
else
    K8S_VERSION="not installed"
    K8S_NODES='{"items":[]}'
fi

cat > "$OUTPUT_DIR/kubernetes.json" <<EOF
{
  "installed": $(command -v kubectl &> /dev/null && echo "true" || echo "false"),
  "version": "$K8S_VERSION",
  "nodes": $K8S_NODES
}
EOF

# ============================================
# 6. SOFTWARE INSTALADO
# ============================================
echo -e "${YELLOW}[6/10]${NC} Listando software relevante..."

check_software() {
    local cmd=$1
    if command -v "$cmd" &> /dev/null; then
        echo "\"$cmd\": \"$($cmd --version 2>&1 | head -n1)\","
    else
        echo "\"$cmd\": \"not installed\","
    fi
}

SOFTWARE_JSON="{"
SOFTWARE_JSON+=$(check_software git)
SOFTWARE_JSON+=$(check_software node)
SOFTWARE_JSON+=$(check_software npm)
SOFTWARE_JSON+=$(check_software pnpm)
SOFTWARE_JSON+=$(check_software python3)
SOFTWARE_JSON+=$(check_software ansible)
SOFTWARE_JSON+=$(check_software terraform)
SOFTWARE_JSON+=$(check_software kubectl)
SOFTWARE_JSON+=$(check_software helm)
SOFTWARE_JSON+=$(check_software nginx)
SOFTWARE_JSON+=$(check_software postgres)
SOFTWARE_JSON=$(echo "$SOFTWARE_JSON" | sed 's/,$//')
SOFTWARE_JSON+="}"

echo "$SOFTWARE_JSON" | jq '.' > "$OUTPUT_DIR/software.json" 2>/dev/null || echo "$SOFTWARE_JSON" > "$OUTPUT_DIR/software.json"

# ============================================
# 7. SERVICIOS SYSTEMD
# ============================================
echo -e "${YELLOW}[7/10]${NC} Verificando servicios systemd..."

SERVICES=$(systemctl list-units --type=service --all --no-pager --no-legend | \
    awk '{print $1, $2, $3, $4}' | \
    jq -R -s 'split("\n") | map(select(length > 0) | split(" ") | {name: .[0], load: .[1], active: .[2], sub: .[3]})' || echo '[]')

echo "$SERVICES" > "$OUTPUT_DIR/services.json"

# ============================================
# 8. USUARIOS Y GRUPOS
# ============================================
echo -e "${YELLOW}[8/10]${NC} Recopilando usuarios y grupos..."

USERS=$(cat /etc/passwd | awk -F: '$3 >= 1000 {print "{\"username\":\""$1"\",\"uid\":"$3",\"home\":\""$6"\",\"shell\":\""$7"\"}"}' | jq -s '.')
GROUPS=$(cat /etc/group | awk -F: '{print "{\"name\":\""$1"\",\"gid\":"$3"}"}' | jq -s '.')

cat > "$OUTPUT_DIR/users.json" <<EOF
{
  "users": $USERS,
  "groups": $GROUPS
}
EOF

# ============================================
# 9. FIREWALL
# ============================================
echo -e "${YELLOW}[9/10]${NC} Verificando firewall..."

if command -v ufw &> /dev/null; then
    UFW_STATUS=$(sudo ufw status verbose 2>/dev/null || echo "error checking")
    UFW_RULES=$(sudo ufw status numbered 2>/dev/null || echo "error checking")
else
    UFW_STATUS="not installed"
    UFW_RULES="not installed"
fi

cat > "$OUTPUT_DIR/firewall.txt" <<EOF
=== UFW Status ===
$UFW_STATUS

=== UFW Rules ===
$UFW_RULES

=== iptables (filter) ===
$(sudo iptables -L -n -v 2>/dev/null || echo "error checking")

=== iptables (nat) ===
$(sudo iptables -t nat -L -n -v 2>/dev/null || echo "error checking")
EOF

# ============================================
# 10. GENERAR RESUMEN
# ============================================
echo -e "${YELLOW}[10/10]${NC} Generando resumen..."

cat > "$OUTPUT_DIR/summary.txt" <<EOF
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  SYSTEM INVENTORY SUMMARY
  Generated: $(date)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

HOSTNAME: $HOSTNAME
OS: $(lsb_release -ds 2>/dev/null || cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)
KERNEL: $(uname -r)
UPTIME: $(uptime -p)

HARDWARE:
  CPU: $CPU_MODEL
  Cores: $CPU_CORES
  Threads: $CPU_THREADS
  RAM: $RAM_TOTAL (Used: $RAM_USED, Available: $RAM_AVAILABLE)
  GPU: $GPU_INFO

NETWORK:
  Tailscale IP: $TAILSCALE_IP
  Open Ports: $OPEN_PORTS

SOFTWARE:
  Docker: $DOCKER_VERSION
  Docker Compose: $DOCKER_COMPOSE_VERSION
  Docker Status: $DOCKER_RUNNING
  Running Containers: $(docker ps -q 2>/dev/null | wc -l)

FILES GENERATED:
  - system.json
  - hardware.json
  - network.json
  - docker.json
  - kubernetes.json
  - software.json
  - services.json
  - users.json
  - firewall.txt
  - summary.txt
EOF

# ============================================
# CREAR TARBALL
# ============================================
echo -e "\n${GREEN}✓${NC} Comprimiendo inventario..."
TARBALL="/tmp/inventory-$HOSTNAME-$(date +%Y%m%d-%H%M%S).tar.gz"
tar -czf "$TARBALL" -C "$(dirname $OUTPUT_DIR)" "$(basename $OUTPUT_DIR)"

echo -e "\n${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✓ Inventario completado${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${BLUE}📦 Archivo generado:${NC} $TARBALL"
echo -e "${BLUE}📁 Archivos individuales:${NC} $OUTPUT_DIR"
echo ""
echo -e "${YELLOW}📤 Para subir a GitHub:${NC}"
echo -e "   1. Copia el archivo: scp $TARBALL usuario@dev01:/ruta/"
echo -e "   2. O usa: cat $OUTPUT_DIR/summary.txt"
echo ""
echo -e "${YELLOW}🔗 O súbelo directamente:${NC}"
echo -e "   curl -F 'file=@$TARBALL' https://file.io"
echo ""

# Mostrar resumen
cat "$OUTPUT_DIR/summary.txt"