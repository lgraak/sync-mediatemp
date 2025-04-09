# MediaTemp Sync Script

This repo contains a systemd-based solution for automatically syncing media files from a remote server via rsync over SSH. It supports large files, retry logic, error notifications via Discord, and ensures only fully downloaded files are processed by media managers like Sonarr and Radarr.

---

## Features
- One-way sync from remote server to local destination
- Preserves subdirectory structure (Books, Movies, Music, TV)
- Avoids re-downloading already-synced files
- Direct-to-destination syncing with hidden temp files
- Only syncs files modified within the last X days (configurable)
- Retry logic with delay and error reporting
- Disk space check before starting
- Systemd timer for scheduled syncs
- `.env` support for config management

---

## Folder Structure
```
/mnt/Media/MediaTemp/
├── Books/
├── Movies/
├── Music/
└── TV/
└── .inprogress/
```

---

## Requirements
- Debian or Ubuntu-based container or server
- rsync
- systemd
- curl (for Discord notifications)
- SSH key-based access to remote server (no passphrase)

---

## Setup Instructions

### 1. Clone or copy this repo
```bash
git clone https://github.com/yourusername/sync-mediatemp.git
```

### 2. Create `.env` file for configuration
```ini
# .env
SYNC_WINDOW_DAYS=30
MIN_FREE_MB=20480
MAX_RETRIES=3
RETRY_DELAY=30
```

> Do **not** commit this file. It is ignored by `.gitignore`.

### 3. SSH Key Setup
- Generate a dedicated passphrase-less SSH key (e.g., `id_github`)
- Copy the public key to the remote server's `~/.ssh/authorized_keys`
- Add to GitHub for code pushing, and to `~/.ssh/config`:
```ini
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_github
    IdentitiesOnly yes
```

- Also configure access to the source server (`mediasource`):
```ini
Host mediasource
    HostName your.remote.server
    User yourusername
    IdentityFile ~/.ssh/id_sync_rsync
```

### 4. Install Script
```bash
sudo cp sync-mediatemp.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/sync-mediatemp.sh
```

### 5. Set Up Systemd Service and Timer
```bash
sudo cp sync-mediatemp.service /etc/systemd/system/
sudo cp sync-mediatemp.timer /etc/systemd/system/
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable --now sync-mediatemp.timer
```

---

## Discord Notification
- Create a webhook in your Discord server
- Replace `WEBHOOK_URL` in `sync-mediatemp.sh` with your actual webhook

---

## Logging
- Log file: `/var/log/sync-mediatemp.log`
- System logs:
```bash
journalctl -u sync-mediatemp.service
```

---

## Git Tips
- `.env` is excluded via `.gitignore`
- Update and push code:
```bash
git add sync-mediatemp.sh .gitignore
git commit -m "Updated sync script with .env support"
git push
```

---

## Files Included
- `sync-mediatemp.sh` — main sync script
- `sync-mediatemp.service` — systemd service unit
- `sync-mediatemp.timer` — systemd timer unit
- `.gitignore` — excludes sensitive config
- `README.md` — this file

---

## License
MIT

---

## Credits
Originally developed as an automated sync solution for use with torrent-based downloaders and local media libraries.
