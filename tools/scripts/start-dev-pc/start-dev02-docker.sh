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

# 4. Fase de limpieza previa de Docker y repos relacionados
#    - Objetivo: evitar conflictos con instalaciones previas o repositorios
#      antiguos (incluyendo posibles repos no firmados).
#    - Pasos:
#      * Eliminar listas de repositorios Docker antiguas.
#      * Eliminar claves GPG previas asociadas a Docker.
#      * Desinstalar paquetes Docker existentes de forma tolerante.

# 4.1 Eliminar listas de repositorios Docker previas
rm -f /etc/apt/sources.list.d/docker.list || true
rm -f /etc/apt/sources.list.d/docker-ce.list || true
rm -f /etc/apt/sources.list.d/docker*.list.save || true

# 4.2 Eliminar claves GPG antiguas de Docker
rm -f /etc/apt/keyrings/docker.gpg || true
# Limpiar posibles claves heredadas en el keyring global (best-effort, no crítico).
set +e
if command -v apt-key >/dev/null 2>&1; then
  apt-key list 2>/dev/null | grep -i "docker" -B1 -A1 >/tmp/docker-keys.txt || true
fi
set -e

# 4.3 Desinstalar paquetes Docker si ya existen (sin fallar si no están instalados)
apt-get remove -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras || true
apt-get autoremove -y || true

# 5. Configurar mirrors de APT para entornos con restricciones (por ejemplo, China)
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

# 6. Instalar paquetes base: git curl gnupg ca-certificates lsb-release htop
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

# 7. Crear /etc/apt/keyrings
#    - Se usa este directorio para almacenar claves GPG de repositorios externos.
#    - Se configura con permisos 0755 (lectura para todos, escritura solo root).

mkdir -p /etc/apt/keyrings
chmod 0755 /etc/apt/keyrings

# 8. Descargar y configurar la GPG key de Docker usando solo mirror USTC
#    - Para evitar bloqueos y asegurar repositorios firmados, usamos únicamente
#      la clave publicada en el mirror chino de USTC.

if [ ! -f /etc/apt/keyrings/docker.gpg ]; then
  curl -fsSL https://mirrors.ustc.edu.cn/docker-ce/linux/ubuntu/gpg \
    | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  chmod a+r /etc/apt/keyrings/docker.gpg
fi

# 9. Agregar repositorio de Docker usando mirrors TUNA y USTC para la arquitectura actual
#    - Detectamos la arquitectura con dpkg --print-architecture (amd64, arm64, etc.).
#    - Usamos el mismo UBUNTU_CODENAME calculado arriba.
#    - Añadimos ambas URLs para mayor resiliencia en China.

ARCH="$(dpkg --print-architecture)"

cat <<EOF >/etc/apt/sources.list.d/docker.list
deb [arch=${ARCH} signed-by=/etc/apt/keyrings/docker.gpg] https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/ubuntu ${UBUNTU_CODENAME} stable
deb [arch=${ARCH} signed-by=/etc/apt/keyrings/docker.gpg] https://mirrors.ustc.edu.cn/docker-ce/linux/ubuntu ${UBUNTU_CODENAME} stable
EOF

# 10. apt update
#    - Actualizamos la lista de paquetes para incluir los repositorios de Docker
#      desde mirrors TUNA/USTC.

apt-get update

# 11. Instalar docker-ce, docker-ce-cli, containerd.io, docker-buildx-plugin, docker-compose-plugin
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

# 12. Habilitar servicio docker y configurar mirrors de registro para China
#     - enable: se inicia automáticamente al arrancar el sistema.
#     - Además, configuramos mirrors chinos para que los pulls (incluyendo
#       `hello-world`) no vayan a docker.io directamente, que suele estar
#       bloqueado en China.

systemctl enable docker

# 12.1 Asegurar directorio de configuración de Docker
mkdir -p /etc/docker

# 12.2 Respaldar configuración previa de daemon.json (si existe)
if [ -f /etc/docker/daemon.json ] && [ ! -f /etc/docker/daemon.json.backup-dev02-docker ]; then
  cp /etc/docker/daemon.json /etc/docker/daemon.json.backup-dev02-docker
fi

# 12.3 Configurar mirrors de registro apuntando a mirrors chinos (USTC y TUNA)
#       Esto hace que las imágenes se obtengan desde mirrors accesibles en China
#       en lugar del registro por defecto bloqueado.
cat <<'EOF' >/etc/docker/daemon.json
{
  "registry-mirrors": [
    "https://docker.mirrors.ustc.edu.cn",
    "https://docker.mirrors.tuna.tsinghua.edu.cn"
  ]
}
EOF

# 12.4 Recargar configuración de systemd y reiniciar Docker para aplicar mirrors
systemctl daemon-reload
systemctl restart docker

# 13. Agregar usuario actual al grupo docker
#     - Si se ejecuta con sudo, SUDO_USER es el usuario "real".
#     - Si no, usamos whoami.
#     - Agregar al grupo docker permite ejecutar `docker` sin sudo (después de reloguear).

TARGET_USER="${SUDO_USER:-$(whoami)}"

if ! id -nG "${TARGET_USER}" | tr ' ' '\n' | grep -q '^docker$'; then
  usermod -aG docker "${TARGET_USER}"
fi

# 14. Mostrar mensaje: "Reinicia sesión"
#     - Es necesario cerrar sesión y volver a entrar para que el grupo docker
#       se aplique al usuario TARGET_USER.

echo "Reinicia sesión"

# 15. Ejecutar prueba docker run hello-world
#     16. Si falla, mostrar mensaje: "No instalar VPN ni Tailscale"
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

# 17. Mensaje final si todo va bien (Docker funcionando correctamente)

echo "Docker se instaló y se probó correctamente con 'hello-world' en dev02."
