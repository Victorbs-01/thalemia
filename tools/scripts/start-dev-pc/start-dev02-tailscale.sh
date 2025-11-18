#!/bin/bash

# -----------------------------------------------------------------------------
# start-dev02-tailscale.sh
# -----------------------------------------------------------------------------
# Provisioning script for dev02 (Ubuntu) to install ONLY the Tailscale client.
#
# IMPORTANT CONSTRAINTS
#   - This script MUST ONLY install the official "tailscale" package.
#   - It MUST NOT:
#       * run "tailscale up" or any Tailscale login/auth commands
#       * configure exit nodes or other routing features
#       * install Docker, GUI VPN tools, or any other applications
#       * embed or reference any secrets, tokens, or credentials
#   - Docker is expected to be installed and working BEFORE running this script.
# -----------------------------------------------------------------------------

# 1. Strict / verbose shell configuration
#    -e : exit on error
#    -u : treat unset variables as an error
#    -x : print commands before executing them (verbose mode)
#    -o pipefail : fail if any element of a pipeline fails
set -euxo pipefail

# 2. Ensure the script is being run as root.
#    - Required for apt repository modifications and package installation.
if [ "${EUID}" -ne 0 ]; then
  echo "This script must be run as root (e.g. sudo ./start-dev02-tailscale.sh)." >&2
  exit 1
fi

# 3. Verify operating system: this script is only for Ubuntu.
#    - Read /etc/os-release
#    - Confirm ID=ubuntu
if [ ! -f /etc/os-release ]; then
  echo "/etc/os-release not found. This script is only for Ubuntu. Aborting." >&2
  exit 1
fi

. /etc/os-release

if [ "${ID:-}" != "ubuntu" ]; then
  echo "This script is only for Ubuntu. Aborting." >&2
  exit 1
fi

# Optional: soft recommendation for Ubuntu 24.x, but do not enforce.
UBUNTU_VERSION_MAJOR="${VERSION_ID%%.*}"
if [ "${UBUNTU_VERSION_MAJOR}" -lt 24 ]; then
  echo "Warning: Ubuntu ${VERSION_ID} detected. dev02 is designed for Ubuntu 24.x or newer." >&2
fi

# 4. Install Tailscale via the official apt repository.
#    - Import the official Tailscale GPG key.
#    - Add the official Tailscale apt repository for the current Ubuntu codename.
#    - Run apt-get update.
#    - Install ONLY the "tailscale" package.

UBUNTU_CODENAME="$(lsb_release -cs)"

# 4.1 Ensure keyrings directory exists (used by many third-party repos).
mkdir -p /usr/share/keyrings

# 4.2 Import the official Tailscale GPG key.
curl -fsSL "https://pkgs.tailscale.com/stable/ubuntu/${UBUNTU_CODENAME}.noarmor.gpg" \
  | tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null

# 4.3 Add the official Tailscale apt repository.
cat <<EOF >/etc/apt/sources.list.d/tailscale.list
deb [signed-by=/usr/share/keyrings/tailscale-archive-keyring.gpg] \
  https://pkgs.tailscale.com/stable/ubuntu ${UBUNTU_CODENAME} main
EOF

# 4.4 Update package lists and install ONLY the tailscale package.
apt-get update
apt-get install -y tailscale

# 5. Post-installation instructions (no automatic login or networking changes).
#    - We deliberately DO NOT run "tailscale up" here, to avoid:
#        * interactive authentication flows
#        * configuring exit nodes or routes
#        * applying any VPN settings automatically
#    - The operator should run "tailscale up" manually with the desired
#      options once Docker and the rest of the dev02 environment are ready.

echo "Run 'sudo tailscale up --authkey=YOUR_KEY' manually after verifying Docker works."

# 6. Validate that Docker still works AFTER installing Tailscale.
#    - Docker must already be installed and working before running this script.
#    - Here we just sanity-check that Docker can list containers and run the
#      hello-world image. We do NOT attempt to install or configure Docker.

DOCKER_TEST_FAILED=0

# 6.1 Check that Docker can talk to the daemon by listing containers.
if ! docker ps; then
  DOCKER_TEST_FAILED=1
fi

# 6.2 Try running the hello-world container.
#     - Per requirements, the script must NOT stop if this fails.
#     - We still want to know if it failed, so we track the exit code.
if ! docker run --rm hello-world; then
  DOCKER_TEST_FAILED=1
fi

# 6.3 If any Docker check failed, show a clear warning but do not abort.
if [ "${DOCKER_TEST_FAILED}" -ne 0 ]; then
  echo "WARNING: Docker test failed after Tailscale installation. Do NOT continue. Revert Tailscale or reboot." >&2
fi

echo "Tailscale installed. Docker test executed. If Docker failed, fix before continuing."
