#!/usr/bin/env bash
set -euo pipefail

DEST="/home/steam"

if [[ ! -d "$DEST" ]]; then
    echo "Error: $DEST does not exist." >&2
    exit 1
fi

if [[ -d "$DEST/.steam" ]]; then
    SRC_DIR="."
else
    SRC_DIR="./no.steam"
fi

cp \
    "$SRC_DIR/palworld-backup.sh" \
    "$SRC_DIR/palworld.service" \
    "palworld-update.sh" \
    "palworld-restore.sh" \
    "$DEST/"

chmod +x "$DEST"/*.sh

# Steam SDK symlinks: game servers look for steamclient.so in ~/.steam/sdk{32,64}
mkdir -p "$DEST/.steam"
ln -sfn steam/steamcmd/linux32 "$DEST/.steam/sdk32"
ln -sfn steam/steamcmd/linux64 "$DEST/.steam/sdk64"
