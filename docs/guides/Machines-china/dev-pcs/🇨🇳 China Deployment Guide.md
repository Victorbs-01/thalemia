# 🇨🇳 China Deployment Guide

Guía completa para deployar Entrepreneur OS en China detrás del Great Firewall.

## 🚧 Desafíos en China

### Bloqueados/Lentos

- ❌ GitHub (intermitente)
- ❌ Docker Hub
- ❌ NPM registry
- ❌ PyPI
- ❌ Google (todos los servicios)
- ❌ AWS
- ⚠️ CloudFlare (lento)

### Accesibles

- ✅ Tailscale (funciona bien)
- ✅ DigitalOcean (desde VPN)
- ✅ Aliyun/Tencent Cloud
- ✅ Mirrors de universidades chinas

---

## 📋 Pre-requisitos

### Hardware

```
Mínimo para producción:
- DV02: Intel i9 + 32GB RAM + RTX 3070 (Vendure Master)
- DV04: Intel i9 + 32GB RAM + RTX 3070 (Vendure Ecom)
- DV05: Ryzen 7 + 32GB RAM + 500GB SSD (Monitoring)
- DV06: Ryzen 7 + 32GB RAM + 2TB HDD (Storage)
- Switch Gigabit Ethernet
```

### Software Base

```
- Debian 13 (bookworm) en todos los nodos Linux
- XFCE desktop (ligero)
- SSH habilitado
- Usuario con sudo
```

### Conexión

```
- Internet estable (aunque limitado por GFW)
- Acceso a Tailscale
- VPN o proxy funcional (recomendado)
```

---

## 🎯 Plan de Deployment

### Fase 0: Preparación (1-2 horas)

#### 1. Configurar mirrors ANTES de instalar nada

```bash
# En cada nodo Linux (DV02, DV04, DV05, DV06)

# Backup sources.list original
sudo cp /etc/apt/sources.list /etc/apt/sources.list.original

# Usar Tuna mirror
sudo tee /etc/apt/sources.list << 'EOF'
deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm main contrib non-free non-free-firmware
deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm-updates main contrib non-free non-free-firmware
deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm-backports main contrib non-free non-free-firmware
deb https://mirrors.tuna.tsinghua.edu.cn/debian-security bookworm-security main contrib non-free non-free-firmware
EOF

# Update
sudo apt update
```

#### 2. Instalar herramientas básicas

```bash
# En cada nodo
sudo apt install -y \
    curl \
    wget \
    git \
    vim \
    htop \
    net-tools \
    iptables \
    ufw \
    fail2ban \
    python3 \
    python3-pip \
    build-essential
```

#### 3. Configurar SSH para Ansible

```bash
# En tu máquina de control (DV01 o laptop)

# Generar SSH key si no tienes
ssh-keygen -t ed25519 -C "ansible@entrepreneur-os"

# Copiar a cada nodo
ssh-copy-id root@dv02
ssh-copy-id root@dv04
ssh-copy-id root@dv05
ssh-copy-id root@dv06

# Verificar acceso sin password
ssh root@dv02 'hostname'
```

---

### Fase 1: Setup con Ansible (2-3 horas)

#### 1. Clonar el repo

```bash
# En DV01 (Windows con Git Bash o WSL)
cd /c/dev/thalemia
git clone https://github.com/tu-usuario/entrepreneur-os.git
cd entrepreneur-os
```

#### 2. Instalar Ansible

```bash
# En WSL o Linux
pip3 install ansible

# Verificar
ansible --version
```

#### 3. Actualizar inventory con IPs reales

```bash
# Editar infrastructure/ansible/inventory/hosts.yml
# Reemplazar las IPs con las reales de tu red

# Ejemplo:
# dv02: ansible_host: 192.168.1.102
# dv04: ansible_host: 192.168.1.104
# etc.
```

#### 4. Ejecutar playbooks en orden

```bash
cd infrastructure/ansible

# 1. Configurar mirrors de China
ansible-playbook -i inventory/hosts.yml playbooks/00-china-mirrors.yml

# 2. Instalar Docker + Tailscale (ORDEN CORRECTO)
ansible-playbook -i inventory/hosts.yml playbooks/01-docker-tailscale.yml

# 3. Configurar Tailscale manualmente (primera vez)
# En cada nodo:
ssh root@dv02
tailscale up --accept-routes --advertise-routes=172.17.0.0/16
# Autorizar en https://login.tailscale.com/admin/machines

# Anotar las IPs de Tailscale
tailscale ip -4  # 100.x.x.x

# Repetir para dv04, dv05, dv06
```

---

### Fase 2: Deploy Monitoring Stack (2-3 horas)

#### 1. Preparar configuración de OpenSearch

```bash
# En DV05
cd /opt
mkdir -p opensearch-stack
cd opensearch-stack

# Copiar archivos del repo
scp -r infrastructure/compose/monitoring/* dv05:/opt/opensearch-stack/
```

#### 2. Configurar variables de entorno

```bash
# En DV05
cat > .env << 'EOF'
OPENSEARCH_PASSWORD=YourStrongPassword123!
OPENSEARCH_CLUSTER_NAME=entrepreneur-os-logs
OPENSEARCH_VERSION=2.11.1
EOF
```

#### 3. Generar certificados SSL

```bash
# En DV05
cd /opt/opensearch-stack

# Crear directorio de certs
mkdir -p opensearch/certs

# Generar certificados auto-firmados
docker run --rm -v $(pwd)/opensearch/certs:/certs \
  opensearchproject/opensearch:2.11.1 \
  /usr/share/opensearch/plugins/opensearch-security/tools/install_demo_configuration.sh -y -i -t
```

#### 4. Configurar System limits

```bash
# En DV05 y DV06
sudo tee -a /etc/sysctl.conf << 'EOF'
vm.max_map_count=262144
vm.swappiness=1
EOF

sudo sysctl -p
```

#### 5. Levantar el stack

```bash
# En DV05
docker-compose -f opensearch-stack.yml up -d

# Ver logs
docker-compose logs -f

# Esperar a que cluster esté verde
curl -k -u admin:YourStrongPassword123! \
  https://localhost:9200/_cluster/health?pretty
```

#### 6. Verificar servicios

```bash
# OpenSearch
curl -k -u admin:password https://localhost:9200

# OpenSearch Dashboards
open http://dv05-tailscale-ip:5601

# Redpanda
docker exec -it redpanda rpk cluster info
```

---

### Fase 3: Deploy Applications (2-3 horas)

#### 1. Setup PostgreSQL para Vendure

```bash
# En DV02 (Master)
docker run -d \
  --name postgres-master \
  --restart unless-stopped \
  -e POSTGRES_PASSWORD=vendure_master_pass \
  -e POSTGRES_USER=vendure \
  -e POSTGRES_DB=vendure_master \
  -p 5432:5432 \
  -v postgres-master-data:/var/lib/postgresql/data \
  postgres:16-alpine

# En DV04 (Ecommerce)
docker run -d \
  --name postgres-ecommerce \
  --restart unless-stopped \
  -e POSTGRES_PASSWORD=vendure_ecommerce_pass \
  -e POSTGRES_USER=vendure \
  -e POSTGRES_DB=vendure_ecommerce \
  -p 5433:5432 \
  -v postgres-ecommerce-data:/var/lib/postgresql/data \
  postgres:16-alpine
```

#### 2. Deploy Vendure Master

```bash
# En DV02
cd /opt/vendure-master
# Copiar desde tu repo
scp -r apps/vendure-master/* dv02:/opt/vendure-master/

# Instalar dependencias con mirror chino
npm config set registry https://registry.npmmirror.com
pnpm install

# Iniciar
pnpm run dev
```

#### 3. Deploy Vendure Ecommerce

```bash
# Similar en DV04
cd /opt/vendure-ecommerce
scp -r apps/vendure-ecommerce/* dv04:/opt/vendure-ecommerce/
pnpm install
pnpm run dev
```

---

### Fase 4: Setup Gateway VPS (1-2 horas)

#### 1. Crear VPS en Digital Ocean

```bash
# Región recomendada: Singapore (más cerca de China)
# OS: Ubuntu 24.04
# Plan: $12/mes (2GB RAM)
```

#### 2. Instalar WireGuard

```bash
# En VPS
curl -O https://raw.githubusercontent.com/angristan/wireguard-install/master/wireguard-install.sh
chmod +x wireguard-install.sh
sudo ./wireguard-install.sh

# Generar configs para cada nodo en China
```

#### 3. Instalar Nginx

```bash
sudo apt update
sudo apt install nginx certbot python3-certbot-nginx

# Configurar reverse proxy
sudo tee /etc/nginx/sites-available/entrepreneur-os << 'EOF'
# API Master
server {
    listen 80;
    server_name api-master.tudominio.com;

    location / {
        proxy_pass http://100.x.x.x:3000;  # IP Tailscale de DV02
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}

# API Ecommerce
server {
    listen 80;
    server_name api.tudominio.com;

    location / {
        proxy_pass http://100.y.y.y:3002;  # IP Tailscale de DV04
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
EOF

# Habilitar y obtener SSL
sudo ln -s /etc/nginx/sites-available/entrepreneur-os /etc/nginx/sites-enabled/
sudo certbot --nginx -d api-master.tudominio.com -d api.tudominio.com
```

---

## 🔍 Troubleshooting

### Problema: Tailscale no conecta containers

```bash
# Verificar que Docker se instaló ANTES de Tailscale
systemctl status docker
systemctl status tailscaled

# Reconciliar iptables
sudo /usr/local/bin/reconcile-iptables.sh

# Verificar rutas
ip route | grep tailscale
```

### Problema: OpenSearch no inicia

```bash
# Verificar vm.max_map_count
sysctl vm.max_map_count

# Debe ser >= 262144
sudo sysctl -w vm.max_map_count=262144

# Verificar memoria
free -h

# OpenSearch necesita mínimo 2GB RAM libre
```

### Problema: No puedo descargar de Docker Hub

```bash
# Verificar mirror está configurado
cat /etc/docker/daemon.json

# Debe tener registry-mirrors de China

# Restart Docker
sudo systemctl restart docker

# Probar pull
docker pull nginx
```

### Problema: NPM timeout en instalación

```bash
# Verificar registry
npm config get registry

# Debe ser https://registry.npmmirror.com

# Limpiar cache
npm cache clean --force

# Retry con timeout mayor
npm install --timeout=300000
```

---

## 📊 Verificación Final

### Checklist de servicios

```bash
# En cada nodo, verificar:

# 1. Docker
docker ps
docker info

# 2. Tailscale
tailscale status
tailscale ip

# 3. Servicios corriendo
# DV02:
curl http://localhost:3000/health  # Vendure Master
curl http://localhost:5432  # PostgreSQL

# DV04:
curl http://localhost:3002/health  # Vendure Ecommerce
curl http://localhost:5678  # n8n

# DV05:
curl -k https://localhost:9200  # OpenSearch
curl http://localhost:5601  # Dashboards
curl http://localhost:3000  # Grafana

# 4. Conectividad via Tailscale
# Desde DV01
curl http://100.x.x.x:3000/health  # DV02
curl http://100.y.y.y:3002/health  # DV04
curl http://100.z.z.z:5601  # DV05
```

### Test de extremo a extremo

```bash
# 1. Crear producto en Vendure Master
# 2. Sincronizar a Vendure Ecommerce (via n8n)
# 3. Ver producto en Storefront
# 4. Ver logs en OpenSearch
# 5. Ver métricas en Grafana
```

---

## 🚀 Próximos Pasos

Una vez todo esté funcionando:

1. ✅ Configurar backups automatizados
2. ✅ Setup monitoring alerts
3. ✅ Configurar Wazuh para security
4. ✅ Deploy storefronts
5. ✅ Configurar CI/CD con Gitea
6. ✅ Agregar más nodos si es necesario

---

## 📚 Recursos

- Tuna Mirrors: https://mirrors.tuna.tsinghua.edu.cn/
- Tailscale Docs: https://tailscale.com/kb/
- OpenSearch Docs: https://opensearch.org/docs/
- Ansible China Best Practices: [tu documentación]

---

## 🆘 Soporte

Si algo falla:

1. Revisa logs: `docker-compose logs -f`
2. Verifica conectividad: `ping`, `curl`, `telnet`
3. Revisa iptables: `iptables -L -n`
4. Consulta documentación del servicio específico
