#!/usr/bin/env bash
set -euo pipefail

DEST="/home/steam"

if [[ "$(whoami)" != "steam" ]]; then
    echo "Error: run this script as the steam user (sudo -u steam ./setup.sh)" >&2
    exit 1
fi

if [[ ! -d "$DEST" ]]; then
    echo "Error: $DEST does not exist." >&2
    exit 1
fi

cp \
    "palworld-backup.sh" \
    "palworld.service" \
    "palworld-update.sh" \
    "palworld-restore.sh" \
    "$DEST/"

chmod +x "$DEST"/*.sh

# Install/update the server via steamcmd into /home/steam/palserver.
bash palworld-update.sh

# Steam SDK symlinks: game servers look for steamclient.so in ~/.steam/sdk{32,64}
ln -sfn "$DEST/.local/share/Steam/steamcmd/linux32" "$DEST/.steam/sdk32"
ln -sfn "$DEST/.local/share/Steam/steamcmd/linux64" "$DEST/.steam/sdk64"
