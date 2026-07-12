# Palworld Dedicated Server

Automated setup and maintenance scripts for a Palworld dedicated server on Linux (Ubuntu/Debian).

Includes installation via SteamCMD, automatic updates on every start, scheduled backups with 10-day rotation, easy restores, and a systemd service that keeps the server running.

## Quick install (one command)

Run this on a fresh Ubuntu/Debian server:

```bash
curl -fsSL https://raw.githubusercontent.com/abdellaouiamir/palworld-server/main/install.sh | sudo bash
```

This will:

1. Install `git` and `steamcmd` if they are missing (accepting the Steam license non-interactively)
2. Create a `steam` user with a home directory at `/home/steam`
3. Clone this repository into `/home/steam/palworld-server`
4. Run `setup.sh`, which copies the right scripts for your setup into `/home/steam`
5. Install and start the `palworld` systemd service

The first start downloads the Palworld server (~8 GB) via SteamCMD, so give it a few minutes.

## Checking the server

```bash
systemctl status palworld       # service status
journalctl -u palworld -f      # follow the live logs
```

## How it works

| File | Purpose |
|---|---|
| `install.sh` | One-shot installer: user, dependencies, clone, setup, service |
| `setup.sh` | Copies the scripts and service file into `/home/steam` (picks the right variant depending on whether `~/.steam` exists) |
| `palworld-update.sh` | Updates the server via SteamCMD — runs automatically before every service start |
| `palworld-backup.sh` | Archives the save data to `/home/steam/Palworld_backups/` and deletes backups older than 10 days — runs automatically when the service stops |
| `palworld-restore.sh` | Restores a chosen backup archive |
| `palworld.service` | systemd unit: auto-restart, update on start, backup on stop, restarts the server every 12 hours |

## Common operations

**Restart the server** (also triggers an update and a backup):

```bash
sudo systemctl restart palworld
```

**Backups run automatically** — do not run `palworld-backup.sh` directly. A backup is created every time the service stops or restarts:

```bash
sudo systemctl stop palworld       # triggers a backup
# or
sudo systemctl restart palworld    # triggers a backup, then an update
```

Backups land in `/home/steam/Palworld_backups/` and are kept for 10 days.

**Restore a backup:**

```bash
ls /home/steam/Palworld_backups/                      # find the backup you want
sudo systemctl stop palworld                          # stop the server first!
sudo -u steam /home/steam/palworld-restore.sh Palworld_2026-07-12_18-00-00.tar.gz
sudo systemctl start palworld
```

**Updates run automatically** — do not run `palworld-update.sh` directly. The server is updated via SteamCMD every time the service starts or restarts:

```bash
sudo systemctl start palworld      # triggers an update before launching
# or
sudo systemctl restart palworld    # triggers a backup, then an update
```

## Server configuration

Edit the Palworld settings file (server name, password, player limits, etc.):

```
/home/steam/.steam/steam/steamapps/common/PalServer/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
```

Restart the service after changing it.

## Notes

- The service restarts the server every 12 hours (`RuntimeMaxSec=12h`) to work around memory leaks — players are disconnected without warning when this happens.
- Default ports: `8211/udp` (game) and `27015/udp` (query). Open them in your firewall:

```bash
sudo ufw allow 8211/udp
sudo ufw allow 27015/udp
```
