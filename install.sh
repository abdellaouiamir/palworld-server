#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/abdellaouiamir/palworld-server.git"
STEAM_USER="steam"
STEAM_HOME="/home/${STEAM_USER}"

# --- Must run as root -------------------------------------------------------
if [[ $EUID -ne 0 ]]; then
    echo "Error: this script must be run as root (try: sudo $0)" >&2
    exit 1
fi

# --- Prerequisites -----------------------------------------------------------
if ! command -v git >/dev/null 2>&1; then
    echo "Installing git..."
    apt-get update -qq && apt-get install -y -qq git
fi

if ! command -v /usr/games/steamcmd >/dev/null 2>&1; then
    echo "Installing steamcmd..."
    dpkg --add-architecture i386
    apt-get update -qq
    # steamcmd requires accepting the Steam license non-interactively
    echo "steam steam/question select I AGREE" | debconf-set-selections
    echo "steam steam/license note ''" | debconf-set-selections
    apt-get install -y -qq software-properties-common
    add-apt-repository -y multiverse 2>/dev/null || true
    apt-get update -qq
    apt-get install -y -qq steamcmd
fi

# --- Create the steam user with a home directory ---------------------------
if id "$STEAM_USER" >/dev/null 2>&1; then
    echo "User '$STEAM_USER' already exists, skipping creation."
else
    useradd --create-home --shell /bin/bash "$STEAM_USER"
    echo "Created user '$STEAM_USER' with home $STEAM_HOME."
fi

# --- Clone the repo into the home directory --------------------------------
REPO_DIR="${STEAM_HOME}/palworld-server"
if [[ -d "$REPO_DIR/.git" ]]; then
    echo "Repo already cloned, pulling latest..."
    sudo -u "$STEAM_USER" git -C "$REPO_DIR" pull --ff-only
else
    sudo -u "$STEAM_USER" git clone "$REPO_URL" "$REPO_DIR"
fi

# --- Run setup.sh as the steam user (from inside the repo: relative paths) --
chmod +x "$REPO_DIR/setup.sh"
sudo -u "$STEAM_USER" bash -c "cd '$REPO_DIR' && ./setup.sh"

# --- Install and start the systemd service ---------------------------------
cp "${STEAM_HOME}/palworld.service" /etc/systemd/system/palworld.service
systemctl daemon-reload
systemctl enable --now palworld.service

echo
echo "Done. Check status with:  systemctl status palworld"
echo "Follow the logs with:     journalctl -u palworld -f"
echo "(First start downloads the server via steamcmd — this can take a while.)"
