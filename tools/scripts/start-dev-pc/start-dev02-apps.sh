#!/bin/bash

# -----------------------------------------------------------------------------
# start-dev02-apps.sh
# -----------------------------------------------------------------------------
# Provisioning script for the dev02 workstation (Ubuntu 24).
#
# PURPOSE
#   Install ONLY desktop / system applications needed for dev02 development.
#   This script MUST NOT install:
#     - Docker (engine, CLI, or plugins)
#     - Tailscale
#     - Any VPN clients or VPN config files
#     - Backend services or application servers
#
# INSTALLED COMPONENTS (high-level):
#   1) git and git-lfs (+ basic global user.name / user.email)
#   2) Visual Studio Code (latest stable .deb)
#   3) JetBrains Toolbox (extracted into /opt/jetbrains-toolbox)
#   4) Cursor IDE (.deb package)
#   5) ClashVerge (app only, via .deb, no configs)
#   6) Optional: python3 + pip
#
# DESIGN NOTES
#   - Uses "strict" bash mode and verbose (-x) so all commands are echoed.
#   - Verifies root and Ubuntu before making changes.
#   - Uses a temporary working directory under /tmp and cleans it on exit.
#   - Avoids creating any .desktop shortcuts or autostart entries.
#   - Does not write any secrets, tokens, or VPN configuration files.
# -----------------------------------------------------------------------------

# 1. Strict / verbose shell configuration
#    -u : treat unset variables as an error
#    -x : print commands before executing them (verbose mode)
#    -o pipefail : fail if any element of a pipeline fails
#
# NOTA IMPORTANTE:
#   No usamos `-e` porque queremos que el script CONTINÚE aunque falle
#   la instalación de una app concreta (por ejemplo VS Code). En vez de
#   abortar todo el script, capturamos errores por sección y mostramos
#   un resumen final con INSTALLED / SKIPPED / FAILED.
set -uxo pipefail

# 2. Ensure the script is being run as root
#    Many installation steps (apt, dpkg, /opt writes) require root privileges.
if [ "${EUID}" -ne 0 ]; then
  echo "This script must be run as root (e.g. sudo ./start-dev02-apps.sh)." >&2
  exit 1
fi

# 3. Basic OS validation: this script is intended for Ubuntu only
if [ ! -f /etc/os-release ]; then
  echo "/etc/os-release not found. This script only supports Ubuntu." >&2
  exit 1
fi

# Load OS metadata
. /etc/os-release

if [ "${ID:-}" != "ubuntu" ]; then
  echo "Detected OS: ${NAME:-unknown}. This script only supports Ubuntu." >&2
  exit 1
fi

# Soft version recommendation: Ubuntu 24.x preferred for dev02
UBUNTU_VERSION_MAJOR="${VERSION_ID%%.*}"
if [ "${UBUNTU_VERSION_MAJOR}" -lt 24 ]; then
  echo "Warning: Ubuntu ${VERSION_ID} detected. dev02 is designed for Ubuntu 24.x or newer." >&2
fi

# 4. Prepare a temporary working directory for downloaded artifacts
#    - All .deb files and archives are stored here and removed at the end.
WORKDIR="$(mktemp -d /tmp/dev02-apps.XXXXXX)"
cleanup() {
  # Best-effort cleanup of temporary files; ignore errors.
  set +e
  if [ -n "${WORKDIR:-}" ] && [ -d "${WORKDIR}" ]; then
    rm -rf "${WORKDIR}"
  fi
}
trap cleanup EXIT

cd "${WORKDIR}"

# 5. Estado de instalación por componente (para el resumen final)
GIT_STATUS="PENDING"
VSCODE_STATUS="PENDING"
TOOLBOX_STATUS="PENDING"
CURSOR_STATUS="PENDING"
CLASHVERGE_STATUS="PENDING"
PYTHON_STATUS="PENDING"

# -----------------------------------------------------------------------------
# Section 1: Install git and git-lfs, and configure basic global git identity
# -----------------------------------------------------------------------------

echo "==== [dev02-apps] Section 1: git + git-lfs ===="

# Hacemos un único apt-get update al principio, pero sin abortar el script
if apt-get update; then
  echo "[git] apt-get update OK"
else
  echo "[git] WARNING: apt-get update failed, se intentará continuar" >&2
fi

if command -v git >/dev/null 2>&1 && command -v git-lfs >/dev/null 2>&1; then
  echo "[git] git y git-lfs ya instalados, se omite apt-get install"
  GIT_STATUS="SKIPPED"
else
  if apt-get install -y git git-lfs; then
    echo "[git] git y git-lfs instalados correctamente"
    GIT_STATUS="INSTALLED"
  else
    echo "[git] ERROR: fallo instalando git/git-lfs" >&2
    GIT_STATUS="FAILED"
  fi
fi

# Enable git-lfs hooks globally (safe: no secrets, just git filters)
git lfs install --system || true

# Configure a generic global git identity.
# NOTE: These values are intentionally generic and do NOT contain secrets.
#       You can override them later with your real name/email.
if ! git config --global user.name >/dev/null 2>&1; then
  git config --global user.name "dev02-user"
fi

if ! git config --global user.email >/dev/null 2>&1; then
  git config --global user.email "dev02@example.com"
fi

# -----------------------------------------------------------------------------
# Section 2: Install Visual Studio Code (latest stable .deb)
# -----------------------------------------------------------------------------

echo "==== [dev02-apps] Section 2: Visual Studio Code ===="

if command -v code >/dev/null 2>&1; then
  echo "[vscode] VS Code ya instalado, se omite descarga/instalación"
  VSCODE_STATUS="SKIPPED"
else
  # We intentionally use the official VSCode download URL for Debian/Ubuntu.
  VSCODE_DEB="vscode.deb"
  if curl -fsSL -o "${VSCODE_DEB}" \
    "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"; then
    echo "[vscode] Descarga de VS Code completada, instalando .deb"

    if dpkg -i "${VSCODE_DEB}"; then
      VSCODE_STATUS="INSTALLED"
      echo "[vscode] VS Code instalado correctamente"
    else
      echo "[vscode] dpkg devolvió error, intentando apt-get install -f -y" >&2
      if apt-get install -f -y && dpkg -i "${VSCODE_DEB}"; then
        VSCODE_STATUS="INSTALLED"
        echo "[vscode] VS Code instalado correctamente tras apt-get install -f"
      else
        echo "[vscode] ERROR: no se pudo instalar VS Code" >&2
        VSCODE_STATUS="FAILED"
      fi
    fi
  else
    echo "[vscode] ERROR: fallo al descargar VS Code" >&2
    VSCODE_STATUS="FAILED"
  fi

  # Remove the .deb to keep the system clean (best-effort)
  rm -f "${VSCODE_DEB}" || true
fi

# -----------------------------------------------------------------------------
# Section 3: Install JetBrains Toolbox
# -----------------------------------------------------------------------------

echo "==== [dev02-apps] Section 3: JetBrains Toolbox ===="

if [ -x /opt/jetbrains-toolbox/jetbrains-toolbox ]; then
  echo "[toolbox] JetBrains Toolbox ya instalado en /opt/jetbrains-toolbox"
  TOOLBOX_STATUS="SKIPPED"
else
  # NOTE: JetBrains does not provide a permanent "latest" URL. We pin a version
  #       here so that the script is deterministic. Update TOOLBOX_VERSION and
  #       TOOLBOX_ARCHIVE_URL when you want to bump Toolbox.
  TOOLBOX_VERSION="2.4.2.34524"  # Example pinned version; adjust as needed.
  TOOLBOX_ARCHIVE="jetbrains-toolbox.tar.gz"
  TOOLBOX_ARCHIVE_URL="https://download.jetbrains.com/toolbox/jetbrains-toolbox-${TOOLBOX_VERSION}.tar.gz"

  if curl -fsSL -o "${TOOLBOX_ARCHIVE}" "${TOOLBOX_ARCHIVE_URL}"; then
    mkdir -p /opt/jetbrains-toolbox
    if tar -xzf "${TOOLBOX_ARCHIVE}" -C /opt/jetbrains-toolbox --strip-components=1; then
      # Set permissions so all users can execute Toolbox, but only root can modify
      chmod -R a+rX /opt/jetbrains-toolbox || true
      TOOLBOX_STATUS="INSTALLED"
      echo "[toolbox] JetBrains Toolbox instalado correctamente en /opt/jetbrains-toolbox"
    else
      echo "[toolbox] ERROR: fallo al extraer el archivo de JetBrains Toolbox" >&2
      TOOLBOX_STATUS="FAILED"
    fi
  else
    echo "[toolbox] ERROR: fallo al descargar JetBrains Toolbox" >&2
    TOOLBOX_STATUS="FAILED"
  fi

  rm -f "${TOOLBOX_ARCHIVE}" || true
fi

# -----------------------------------------------------------------------------
# Section 4: Install Cursor IDE (.deb package)
# -----------------------------------------------------------------------------

echo "==== [dev02-apps] Section 4: Cursor IDE ===="

if command -v cursor >/dev/null 2>&1; then
  echo "[cursor] Cursor IDE ya instalado, se omite descarga/instalación"
  CURSOR_STATUS="SKIPPED"
else
  # Cursor provides an official .deb download endpoint.
  CURSOR_DEB="cursor.deb"
  if curl -fsSL -o "${CURSOR_DEB}" "https://downloader.cursor.sh/linux/app.deb"; then
    if dpkg -i "${CURSOR_DEB}"; then
      CURSOR_STATUS="INSTALLED"
      echo "[cursor] Cursor IDE instalado correctamente"
    else
      echo "[cursor] dpkg devolvió error, intentando apt-get install -f -y" >&2
      if apt-get install -f -y && dpkg -i "${CURSOR_DEB}"; then
        CURSOR_STATUS="INSTALLED"
        echo "[cursor] Cursor IDE instalado correctamente tras apt-get install -f"
      else
        echo "[cursor] ERROR: no se pudo instalar Cursor IDE" >&2
        CURSOR_STATUS="FAILED"
      fi
    fi
  else
    echo "[cursor] ERROR: fallo al descargar Cursor IDE" >&2
    CURSOR_STATUS="FAILED"
  fi

  rm -f "${CURSOR_DEB}" || true
fi

# -----------------------------------------------------------------------------
# Section 5: Install ClashVerge (application only, no configs)
# -----------------------------------------------------------------------------

echo "==== [dev02-apps] Section 5: ClashVerge ===="

# IMPORTANT: We install only the ClashVerge application package, without any
#            VPN / proxy configuration files, credentials, or presets.

if command -v clash-verge >/dev/null 2>&1 || command -v clash-verge-rev >/dev/null 2>&1; then
  echo "[clashverge] ClashVerge ya instalado, se omite descarga/instalación"
  CLASHVERGE_STATUS="SKIPPED"
else
  CLASHVERGE_DEB="clashverge.deb"

  # The exact URL may need to be updated over time as releases change.
  # This points to a Debian/Ubuntu build of ClashVerge or a compatible fork.
  CLASHVERGE_URL="https://github.com/clash-verge-rev/clash-verge-rev/releases/latest/download/clash-verge-rev-linux-amd64.deb"

  if curl -fsSL -o "${CLASHVERGE_DEB}" "${CLASHVERGE_URL}"; then
    if dpkg -i "${CLASHVERGE_DEB}"; then
      CLASHVERGE_STATUS="INSTALLED"
      echo "[clashverge] ClashVerge instalado correctamente"
    else
      echo "[clashverge] dpkg devolvió error, intentando apt-get install -f -y" >&2
      if apt-get install -f -y && dpkg -i "${CLASHVERGE_DEB}"; then
        CLASHVERGE_STATUS="INSTALLED"
        echo "[clashverge] ClashVerge instalado correctamente tras apt-get install -f"
      else
        echo "[clashverge] ERROR: no se pudo instalar ClashVerge" >&2
        CLASHVERGE_STATUS="FAILED"
      fi
    fi
  else
    echo "[clashverge] ERROR: fallo al descargar ClashVerge" >&2
    CLASHVERGE_STATUS="FAILED"
  fi

  rm -f "${CLASHVERGE_DEB}" || true
fi

# -----------------------------------------------------------------------------
# Section 6 (optional): Install python3 and pip (safe developer utilities)
# -----------------------------------------------------------------------------

echo "==== [dev02-apps] Section 6: python3 + pip ===="

if command -v python3 >/dev/null 2>&1 && command -v pip3 >/dev/null 2>&1; then
  echo "[python] python3 y pip3 ya instalados, se omite apt-get install"
  PYTHON_STATUS="SKIPPED"
else
  if apt-get install -y python3 python3-pip; then
    PYTHON_STATUS="INSTALLED"
    echo "[python] python3 y pip3 instalados correctamente"
  else
    echo "[python] ERROR: fallo instalando python3/python3-pip" >&2
    PYTHON_STATUS="FAILED"
  fi
fi

# -----------------------------------------------------------------------------
# Final summary & message
# -----------------------------------------------------------------------------

echo ""
echo "==== [dev02-apps] RESUMEN DE INSTALACIÓN ===="
printf '  %-15s %s\n' "git+git-lfs:" "${GIT_STATUS}"
printf '  %-15s %s\n' "vscode:" "${VSCODE_STATUS}"
printf '  %-15s %s\n' "jetbrains TB:" "${TOOLBOX_STATUS}"
printf '  %-15s %s\n' "cursor:" "${CURSOR_STATUS}"
printf '  %-15s %s\n' "clashverge:" "${CLASHVERGE_STATUS}"
printf '  %-15s %s\n' "python3+pip:" "${PYTHON_STATUS}"

echo ""
if printf '%s\n' "${GIT_STATUS}" "${VSCODE_STATUS}" "${TOOLBOX_STATUS}" "${CURSOR_STATUS}" "${CLASHVERGE_STATUS}" "${PYTHON_STATUS}" | grep -q "FAILED"; then
  echo "[dev02-apps] ATENCIÓN: una o más aplicaciones NO se pudieron instalar (estado FAILED). Revisa los logs anteriores para más detalle." >&2
else
  echo "[dev02-apps] Todas las aplicaciones se instalaron o ya estaban presentes."
fi

echo "System apps provisioning finished. Continue with Script 3 (tailscale)."
