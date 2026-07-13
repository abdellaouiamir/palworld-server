#!/usr/bin/env bash
set -euo pipefail

STEAM_USER="steam"
STEAM_HOME="/home/${STEAM_USER}"
SERVICE="palworld.service"

# --- Must run as root -------------------------------------------------------
if [[ $EUID -ne 0 ]]; then
    echo "Error: this script must be run as root (try: sudo bash uninstall.sh)" >&2
    exit 1
fi

confirm() {
    read -r -p "$1 [y/N] " reply
    [[ "$reply" =~ ^[Yy]$ ]]
}

echo "This will uninstall the Palworld dedicated server."

# --- Stop and remove the systemd service ------------------------------------
if [[ -f "/etc/systemd/system/$SERVICE" ]]; then
    echo "Stopping and disabling $SERVICE..."
    # Backup-on-stop (ExecStopPost) still runs here — one last backup is taken.
    systemctl disable --now "$SERVICE" || true
    rm -f "/etc/systemd/system/$SERVICE"
    systemctl daemon-reload
    systemctl reset-failed "$SERVICE" 2>/dev/null || true
else
    echo "Service $SERVICE not installed, skipping."
fi

# --- Remove the installed scripts and server files --------------------------
echo "Removing scripts, repo, and server files..."
rm -f "$STEAM_HOME"/palworld-backup.sh \
      "$STEAM_HOME"/palworld-update.sh \
      "$STEAM_HOME"/palworld-restore.sh \
      "$STEAM_HOME"/palworld.service
rm -rf "$STEAM_HOME/palworld-server"             # cloned repo
rm -rf "$STEAM_HOME/palserver"                   # server (force_install_dir)
rm -rf "$STEAM_HOME/Steam" "$STEAM_HOME/.steam"  # legacy/steamcmd data

# --- Backups (ask first — this is save data) --------------------------------
if [[ -d "$STEAM_HOME/Palworld_backups" ]]; then
    if confirm "Delete all backups in $STEAM_HOME/Palworld_backups (contains your world saves)?"; then
        rm -rf "$STEAM_HOME/Palworld_backups"
        echo "Backups deleted."
    else
        echo "Backups kept at $STEAM_HOME/Palworld_backups."
    fi
fi

# --- Steam user (ask first) --------------------------------------------------
if id "$STEAM_USER" >/dev/null 2>&1; then
    if confirm "Delete the '$STEAM_USER' user and its entire home directory?"; then
        pkill -u "$STEAM_USER" 2>/dev/null || true
        userdel -r "$STEAM_USER"
        echo "User '$STEAM_USER' removed."
    else
        echo "User '$STEAM_USER' kept."
    fi
fi

echo
echo "Uninstall complete."
echo "Note: steamcmd and git were not removed (they may be used by other software)."
echo "To remove steamcmd: sudo apt-get remove steamcmd"
