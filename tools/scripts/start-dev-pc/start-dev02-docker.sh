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

# 4. Instalar paquetes base: git curl gnupg ca-certificates lsb-release htop
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

# 5. Crear /etc/apt/keyrings
#    - Se usa este directorio para almacenar claves GPG de repositorios externos.
#    - Se configura con permisos 0755 (lectura para todos, escritura solo root).

mkdir -p /etc/apt/keyrings
chmod 0755 /etc/apt/keyrings

# 6. Descargar y configurar la GPG key de Docker
#    - Descargamos la clave oficial de Docker para Ubuntu.
#    - La convertimos al formato .gpg binario con gpg --dearmor.
#    - Damos permisos de lectura global para que apt pueda usarla.

if [ ! -f /etc/apt/keyrings/docker.gpg ]; then
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
    | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  chmod a+r /etc/apt/keyrings/docker.gpg
fi

# 7. Agregar repo oficial de Docker para la arquitectura actual
#    - Detectamos la arquitectura con dpkg --print-architecture (amd64, arm64, etc.).
#    - Obtenemos el codename de Ubuntu (noble, jammy, etc.) con lsb_release -cs.
#    - Creamos /etc/apt/sources.list.d/docker.list apuntando al repositorio estable.

ARCH="$(dpkg --print-architecture)"
UBUNTU_CODENAME="$(lsb_release -cs)"

cat <<EOF > /etc/apt/sources.list.d/docker.list
deb [arch=${ARCH} signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu ${UBUNTU_CODENAME} stable
EOF

# 8. apt update
#    - Actualizamos la lista de paquetes para incluir el repositorio de Docker.

apt-get update

# 9. Instalar docker-ce, docker-ce-cli, containerd.io, docker-buildx-plugin, docker-compose-plugin
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

# 10. Habilitar y arrancar servicio docker
#     - enable: se inicia automáticamente al arrancar el sistema.
#     - start: lo arranca inmediatamente.

systemctl enable docker
systemctl start docker

# 11. Agregar usuario actual al grupo docker
#     - Si se ejecuta con sudo, SUDO_USER es el usuario "real".
#     - Si no, usamos whoami.
#     - Agregar al grupo docker permite ejecutar `docker` sin sudo (después de reloguear).

TARGET_USER="${SUDO_USER:-$(whoami)}"

if ! id -nG "${TARGET_USER}" | tr ' ' '\n' | grep -q '^docker$'; then
  usermod -aG docker "${TARGET_USER}"
fi

# 12. Mostrar mensaje: "Reinicia sesión"
#     - Es necesario cerrar sesión y volver a entrar para que el grupo docker
#       se aplique al usuario TARGET_USER.

echo "Reinicia sesión"

# 13. Ejecutar prueba docker run hello-world
#     14. Si falla, mostrar mensaje: "No instalar VPN ni Tailscale"
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

# 15. Mensaje final si todo va bien (Docker funcionando correctamente)

echo "Docker se instaló y se probó correctamente con 'hello-world' en dev02."
