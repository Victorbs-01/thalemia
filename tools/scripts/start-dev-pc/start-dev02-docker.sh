#!/bin/bash

# -----------------------------------------------------------------------------
# start-dev02-docker.sh
# -----------------------------------------------------------------------------
# Script de preparación para la máquina dev02 (Ubuntu 24).
# Objetivo: instalar Docker Engine + plugins oficiales y probar `hello-world`.
#
# Requisitos y decisiones de diseño:
# - Modo "verbose" activado: `set -x` muestra todos los comandos.
# - Se verifica que el sistema operativo sea Ubuntu (usando /etc/os-release).
# - Se instalan paquetes base necesarios para administración y repositorios.
# - Se configura el repositorio oficial de Docker para la arquitectura actual.
# - Se habilita y arranca el servicio `docker`.
# - Se agrega el usuario actual al grupo `docker`.
# - Se ejecuta `docker run hello-world` como prueba.
# - Si Docker falla: se muestra el mensaje "No instalar VPN ni Tailscale" y se sale
#   con código de error.
# - NO se instala ni se menciona ningún cliente VPN, Tailscale ni similares.
# -----------------------------------------------------------------------------

# 1. Shebang ya definido arriba: indica que el script usa /bin/bash.

# 2. Modo estricto y verbose:
#    -e : salir si un comando falla
#    -u : error si se usa una variable no definida
#    -x : imprimir comandos antes de ejecutarlos (verbose)
#    -o pipefail : si cualquier comando en un pipe falla, falla todo el pipe
set -euxo pipefail

# Aseguramos que el script se ejecute como root (directamente o via sudo).
if [ "${EUID}" -ne 0 ]; then
  echo "Este script debe ejecutarse como root (por ejemplo: sudo ./start-dev02-docker.sh)." >&2
  exit 1
fi

# 3. Verificar Ubuntu en /etc/os-release
#    - Comprobamos que el archivo /etc/os-release existe.
#    - Cargamos sus variables de entorno.
#    - Validamos que ID sea "ubuntu".
if [ ! -f /etc/os-release ]; then
  echo "No se encontró /etc/os-release. Este script solo soporta Ubuntu." >&2
  exit 1
fi

# Cargar información del sistema
. /etc/os-release

# Verificar que el sistema operativo es Ubuntu
if [ "${ID:-}" != "ubuntu" ]; then
  echo "Sistema operativo detectado: ${NAME:-desconocido}. Este script solo soporta Ubuntu." >&2
  exit 1
fi

# Validación suave de versión de Ubuntu (recomendado 24.x)
UBUNTU_VERSION_MAJOR="${VERSION_ID%%.*}"
if [ "${UBUNTU_VERSION_MAJOR}" -lt 24 ]; then
  echo "Advertencia: Ubuntu ${VERSION_ID} detectado. Se recomienda Ubuntu 24.x o superior para dev02." >&2
fi

# 4. Configurar mirrors de APT para entornos con restricciones (por ejemplo, China)
#    - En algunos países (China) el acceso directo a los repositorios oficiales
#      puede ser lento o estar bloqueado.
#    - Antes de cualquier `apt-get update` cambiamos los mirrors de Ubuntu a
#      Tsinghua (TUNA) y USTC.
#    - Hacemos una copia de seguridad de /etc/apt/sources.list si aún no existe.

if [ -f /etc/apt/sources.list ] && [ ! -f /etc/apt/sources.list.backup-dev02-docker ]; then
  cp /etc/apt/sources.list /etc/apt/sources.list.backup-dev02-docker
fi

UBUNTU_CODENAME="${UBUNTU_CODENAME:-${VERSION_CODENAME:-}}"
if [ -z "${UBUNTU_CODENAME}" ]; then
  # Fallback por compatibilidad (no debería ocurrir en Ubuntu 24, pero es seguro).
  UBUNTU_CODENAME="$(lsb_release -cs)"
fi

cat <<EOF >/etc/apt/sources.list
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ ${UBUNTU_CODENAME} main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ ${UBUNTU_CODENAME}-updates main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ ${UBUNTU_CODENAME}-backports main restricted universe multiverse
deb https://mirrors.ustc.edu.cn/ubuntu/ ${UBUNTU_CODENAME} main restricted universe multiverse
deb https://mirrors.ustc.edu.cn/ubuntu/ ${UBUNTU_CODENAME}-updates main restricted universe multiverse
deb https://mirrors.ustc.edu.cn/ubuntu/ ${UBUNTU_CODENAME}-backports main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ ${UBUNTU_CODENAME}-security main restricted universe multiverse
deb https://mirrors.ustc.edu.cn/ubuntu/ ${UBUNTU_CODENAME}-security main restricted universe multiverse
EOF

# 5. Instalar paquetes base: git curl gnupg ca-certificates lsb-release htop
#    - git: control de versiones
#    - curl: descargas HTTP/HTTPS desde terminal
#    - gnupg: gestión de claves GPG (necesario para repositorios seguros)
#    - ca-certificates: certificados raíz para HTTPS
#    - lsb-release: información de distribución (lsb_release -cs)
#    - htop: monitor de sistema interactivo

apt-get update
apt-get install -y \
  git \
  curl \
  gnupg \
  ca-certificates \
  lsb-release \
  htop

# 6. Crear /etc/apt/keyrings
#    - Se usa este directorio para almacenar claves GPG de repositorios externos.
#    - Se configura con permisos 0755 (lectura para todos, escritura solo root).

mkdir -p /etc/apt/keyrings
chmod 0755 /etc/apt/keyrings

# 7. Descargar y configurar la GPG key de Docker usando mirrors (TUNA/USTC)
#    - En vez de usar download.docker.com, utilizamos los mirrors chinos.
#    - Intentamos primero TUNA; si falla, probamos USTC.

if [ ! -f /etc/apt/keyrings/docker.gpg ]; then
  if ! curl -fsSL https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/ubuntu/gpg \
    | gpg --dearmor -o /etc/apt/keyrings/docker.gpg; then
    # Fallback a USTC si TUNA falla
    curl -fsSL https://mirrors.ustc.edu.cn/docker-ce/linux/ubuntu/gpg \
      | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  fi
  chmod a+r /etc/apt/keyrings/docker.gpg
fi

# 8. Agregar repositorio de Docker usando mirrors TUNA y USTC para la arquitectura actual
#    - Detectamos la arquitectura con dpkg --print-architecture (amd64, arm64, etc.).
#    - Usamos el mismo UBUNTU_CODENAME calculado arriba.
#    - Añadimos ambas URLs para mayor resiliencia en China.

ARCH="$(dpkg --print-architecture)"

cat <<EOF >/etc/apt/sources.list.d/docker.list
deb [arch=${ARCH} signed-by=/etc/apt/keyrings/docker.gpg] https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/ubuntu ${UBUNTU_CODENAME} stable
deb [arch=${ARCH} signed-by=/etc/apt/keyrings/docker.gpg] https://mirrors.ustc.edu.cn/docker-ce/linux/ubuntu ${UBUNTU_CODENAME} stable
EOF

# 9. apt update
#    - Actualizamos la lista de paquetes para incluir los repositorios de Docker
#      desde mirrors TUNA/USTC.

apt-get update

# 10. Instalar docker-ce, docker-ce-cli, containerd.io, docker-buildx-plugin, docker-compose-plugin
#    - docker-ce: Docker Engine
#    - docker-ce-cli: cliente de línea de comandos
#    - containerd.io: runtime de contenedores
#    - docker-buildx-plugin: tooling de build avanzado
#    - docker-compose-plugin: plugin oficial de docker compose v2

apt-get install -y \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin

# 11. Habilitar y arrancar servicio docker
#     - enable: se inicia automáticamente al arrancar el sistema.
#     - start: lo arranca inmediatamente.

systemctl enable docker
systemctl start docker

# 12. Agregar usuario actual al grupo docker
#     - Si se ejecuta con sudo, SUDO_USER es el usuario "real".
#     - Si no, usamos whoami.
#     - Agregar al grupo docker permite ejecutar `docker` sin sudo (después de reloguear).

TARGET_USER="${SUDO_USER:-$(whoami)}"

if ! id -nG "${TARGET_USER}" | tr ' ' '\n' | grep -q '^docker$'; then
  usermod -aG docker "${TARGET_USER}"
fi

# 13. Mostrar mensaje: "Reinicia sesión"
#     - Es necesario cerrar sesión y volver a entrar para que el grupo docker
#       se aplique al usuario TARGET_USER.

echo "Reinicia sesión"

# 14. Ejecutar prueba docker run hello-world
#     15. Si falla, mostrar mensaje: "No instalar VPN ni Tailscale"
#
#     IMPORTANTE:
#     - Usamos un bloque especial para capturar el código de salida de docker
#       sin que `set -e` detenga el script antes de nuestro mensaje personalizado.

set +e

docker run --rm hello-world
DOCKER_EXIT_CODE=$?

set -e

if [ "${DOCKER_EXIT_CODE}" -ne 0 ]; then
  echo "docker run hello-world falló con código ${DOCKER_EXIT_CODE}." >&2
  echo "No instalar VPN ni Tailscale"
  exit "${DOCKER_EXIT_CODE}"
fi

# 16. Mensaje final si todo va bien (Docker funcionando correctamente)

echo "Docker se instaló y se probó correctamente con 'hello-world' en dev02."
