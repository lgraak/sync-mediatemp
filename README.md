# MediaTemp Sync Script

This repo contains a systemd-based solution for automatically syncing media files from a remote server via rsync over SSH. It supports large files, retry logic, error notifications via Discord, and ensures only fully downloaded files are processed by media managers like Sonarr and Radarr.

---

## Features
- One-way sync from remote server to local destination
- Preserves subdirectory structure (Books, Movies, Music, TV)
- Avoids re-downloading already-synced files
- Direct-to-destination syncing with hidden temp files
- Retry logic with delay and error reporting
- Disk space check before starting
- Systemd timer for regular scheduled syncs

---

## Folder Structure
```
/mnt/Media/MediaTemp/
├── Books/
├── Movies/
├── Music/
└── TV/
```

Temp files are written to:
```
/mnt/Media/MediaTemp/.inprogress/
```

---

## Requirements
- Debian or Ubuntu-based container or server
- rsync
- systemd
- curl (for Discord notifications)
- SSH key-based access to remote server (key must not use a passphrase)

---

## Setup Instructions

### 1. Clone or copy this repo
```
git clone https://github.com/yourusername/sync-mediatemp.git
```

### 2. SSH Key Setup
- Generate a dedicated passphrase-less SSH key (e.g., `id_sync_rsync`)
- Copy the public key to the remote server's `~/.ssh/authorized_keys`
- Place the private key in `~/.ssh/id_sync_rsync` on the local machine
- Create or edit `~/.ssh/config` to add:
```
Host mediasource
    HostName your.remote.server
    User yourusername
    IdentityFile ~/.ssh/id_sync_rsync
```

### 3. Install Script
Copy `sync-mediatemp.sh` to `/usr/local/bin/` and make it executable:
```
sudo cp sync-mediatemp.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/sync-mediatemp.sh
```

### 4. Setup Systemd Service & Timer
Copy `sync-mediatemp.service` and `sync-mediatemp.timer` to `/etc/systemd/system/`:
```
sudo cp sync-mediatemp.service /etc/systemd/system/
sudo cp sync-mediatemp.timer /etc/systemd/system/
```
Reload and enable the timer:
```
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable --now sync-mediatemp.timer
```

---

## Discord Notification
- Create a Discord webhook in your server (Server Settings → Integrations → Webhooks)
- Replace the `WEBHOOK_URL` in `sync-mediatemp.sh` with your actual webhook URL

---

## Customization
- Adjust sync frequency in `sync-mediatemp.timer` by modifying `OnUnitActiveSec`
- Change disk space threshold in script (`MIN_FREE_MB`)
- Add `--max-age=14d` to `RSYNC_OPTS` if you want to only sync recent files

---

## Logging
Logs are written to:
```
/var/log/sync-mediatemp.log
```

Systemd journal logs can also be viewed with:
```
journalctl -u sync-mediatemp.service
```

---

## Files Included
- `sync-mediatemp.sh` — main sync script
- `sync-mediatemp.service` — systemd service unit
- `sync-mediatemp.timer` — systemd timer unit
- `README.md` — this file

---

## Security Note
This repo does not include any sensitive information. You must generate and manage your own SSH keys and webhook URLs.

---

## License
MIT

---

## Credits
Originally developed as an automated sync solution for use with torrent-based downloaders and local media libraries.