#!/usr/bin/env bash
   set -euo pipefail
   if [[ $# -ne 1 ]]; then
       echo "Usage: $0 <Palworld_MODIFY-DATE-HERE.tar.gz>" >&2
       exit 1
   fi
   tar -xzvf "/home/steam/Palworld_backups/$1" -C /
