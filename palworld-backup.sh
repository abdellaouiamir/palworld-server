#!/bin/bash

set -euo pipefail

mkdir -p /home/steam/Palworld_backups/
tar -czvf /home/steam/Palworld_backups/"Palworld_$(date '+%Y-%m-%d_%H-%M-%S').tar.gz" /home/steam/.steam/steam/steamapps/common/PalServer/Pal/Saved && find /home/steam/Palworld_backups/ -mtime +10 -type f -delete
