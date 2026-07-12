#!/usr/bin/env bash
set -euo pipefail

DEST="/home/steam"

if [[ ! -d "$DEST" ]]; then
    echo "Error: $DEST does not exist." >&2
    exit 1
fi

# Run the update first: downloads the server via steamcmd. This also creates
# ~/.steam, so the variant check below reflects the real installation.
bash palworld-update.sh
ln -sfn $DEST/.steam/steam/steamcmd/linux32 "$DEST/.steam/sdk32"
ln -sfn $DEST/.steam/steam/steamcmd/linux64 "$DEST/.steam/sdk64"

if [[ -d "$DEST/Steam" ]]; then
    SRC_DIR="./no.steam"    
else
    SRC_DIR="."
fi

cp \
    "$SRC_DIR/palworld-backup.sh" \
    "$SRC_DIR/palworld.service" \
    "palworld-update.sh" \
    "palworld-restore.sh" \
    "$DEST/"

chmod +x "$DEST"/*.sh
