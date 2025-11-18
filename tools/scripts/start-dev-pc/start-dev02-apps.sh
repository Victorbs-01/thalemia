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
#    -e : exit on error
#    -u : treat unset variables as an error
#    -x : print commands before executing them (verbose mode)
#    -o pipefail : fail if any element of a pipeline fails
set -euxo pipefail

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

# -----------------------------------------------------------------------------
# Section 1: Install git and git-lfs, and configure basic global git identity
# -----------------------------------------------------------------------------

apt-get update
apt-get install -y git git-lfs

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

# We intentionally use the official VSCode download URL for Debian/Ubuntu.
VSCODE_DEB="vscode.deb"
curl -fsSL -o "${VSCODE_DEB}" \
  "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"

dpkg -i "${VSCODE_DEB}" || apt-get install -f -y

# Remove the .deb to keep the system clean
rm -f "${VSCODE_DEB}"

# -----------------------------------------------------------------------------
# Section 3: Install JetBrains Toolbox
# -----------------------------------------------------------------------------

# NOTE: JetBrains does not provide a permanent "latest" URL. We pin a version
#       here so that the script is deterministic. Update TOOLBOX_VERSION and
#       TOOLBOX_ARCHIVE_URL when you want to bump Toolbox.
TOOLBOX_VERSION="2.4.2.34524"  # Example pinned version; adjust as needed.
TOOLBOX_ARCHIVE="jetbrains-toolbox.tar.gz"
TOOLBOX_ARCHIVE_URL="https://download.jetbrains.com/toolbox/jetbrains-toolbox-${TOOLBOX_VERSION}.tar.gz"

curl -fsSL -o "${TOOLBOX_ARCHIVE}" "${TOOLBOX_ARCHIVE_URL}"

mkdir -p /opt/jetbrains-toolbox
tar -xzf "${TOOLBOX_ARCHIVE}" -C /opt/jetbrains-toolbox --strip-components=1

# Set permissions so all users can execute Toolbox, but only root can modify
chmod -R a+rX /opt/jetbrains-toolbox

rm -f "${TOOLBOX_ARCHIVE}"

# -----------------------------------------------------------------------------
# Section 4: Install Cursor IDE (.deb package)
# -----------------------------------------------------------------------------

# Cursor provides an official .deb download endpoint.
CURSOR_DEB="cursor.deb"
curl -fsSL -o "${CURSOR_DEB}" "https://downloader.cursor.sh/linux/app.deb"

dpkg -i "${CURSOR_DEB}" || apt-get install -f -y

rm -f "${CURSOR_DEB}"

# -----------------------------------------------------------------------------
# Section 5: Install ClashVerge (application only, no configs)
# -----------------------------------------------------------------------------

# IMPORTANT: We install only the ClashVerge application package, without any
#            VPN / proxy configuration files, credentials, or presets.

CLASHVERGE_DEB="clashverge.deb"

# The exact URL may need to be updated over time as releases change.
# This points to a Debian/Ubuntu build of ClashVerge or a compatible fork.
CLASHVERGE_URL="https://github.com/clash-verge-rev/clash-verge-rev/releases/latest/download/clash-verge-rev-linux-amd64.deb"

curl -fsSL -o "${CLASHVERGE_DEB}" "${CLASHVERGE_URL}"

dpkg -i "${CLASHVERGE_DEB}" || apt-get install -f -y

rm -f "${CLASHVERGE_DEB}"

# -----------------------------------------------------------------------------
# Section 6 (optional): Install python3 and pip (safe developer utilities)
# -----------------------------------------------------------------------------

apt-get install -y python3 python3-pip || true

# -----------------------------------------------------------------------------
# Final message
# -----------------------------------------------------------------------------

echo "System apps installed successfully. Continue with Script 3 (tailscale)."
