# sync-mediatemp

A lightweight one-way sync system that copies files from a remote SSH server to a local Samba-mounted drive. Built with automation, reliability, and error reporting in mind.

---

## ✨ Features

- ✅ One-way sync from remote server
- 📅 Only syncs files modified in the last N days
- 📁 Folder-specific subdirectory structure: Movies, TV, Music, Books
- 🔁 Automatically retries failed syncs
- 💬 Discord Webhook alerts for errors
- 💽 Verifies CIFS mount and remounts if needed
- 🧠 Keeps logs in `/var/log/sync-mediatemp.log`
- 🌐 Optional web log viewer using `ttyd`

---

## 📁 File Overview

| File | Description |
|------|-------------|
| `sync-mediatemp.sh` | Main sync script |
| `.env` | Environment variables (see below) |
| `log-terminal.service` | Systemd service for optional web log viewer |
| `README.md` | You're reading it |

---

## 🔧 Installation & Setup

### 1. Clone the repository

```bash
git clone https://github.com/lgraak/sync-mediatemp.git
cd sync-mediatemp
```

---

### 2. Set up the sync script

```bash
cp sync-mediatemp.sh /usr/local/bin/
chmod +x /usr/local/bin/sync-mediatemp.sh
```

---

### 3. Create `.env` file

This controls sync window, retries, and disk space thresholds:

```bash
nano ~/sync-mediatemp/.env
```

```env
SYNC_WINDOW_DAYS=30         # Only sync files modified in the last 30 days
MAX_RETRIES=3               # Retry sync up to 3 times
RETRY_DELAY=30              # Wait 30 seconds between retries
MIN_FREE_MB=10240           # Require at least 10GB free space
```

---

### 4. Set up the log file

```bash
touch /var/log/sync-mediatemp.log
```

---

### 5. Schedule it (with `cron` or `systemd` timer)

You can run it every 15 minutes with a cron job:
```bash
crontab -e
```

Add:
```
*/15 * * * * /usr/local/bin/sync-mediatemp.sh
```

---

## 🌐 Optional: Web-based Log Viewer (ttyd)

### Install `ttyd`

```bash
apt install ttyd -y
```

### Create service

```bash
nano /etc/systemd/system/log-terminal.service
```

```ini
[Unit]
Description=Web-based log viewer for sync-mediatemp.log
After=network.target

[Service]
ExecStart=/usr/bin/ttyd -p 7682 tail -f /var/log/sync-mediatemp.log
Restart=always
User=root

[Install]
WantedBy=multi-user.target
```

Enable and start it:

```bash
systemctl daemon-reexec
systemctl daemon-reload
systemctl enable --now log-terminal.service
```

Then visit:

```
http://<your-sync-server-ip>:7682
```

---

## 🛠 Recovery / Re-deploy Instructions

If this server ever needs to be rebuilt:

```bash
# Clone the repo
git clone https://github.com/lgraak/sync-mediatemp.git
cd sync-mediatemp

# Restore the script
cp sync-mediatemp.sh /usr/local/bin/
chmod +x /usr/local/bin/sync-mediatemp.sh

# Set up environment
nano ~/sync-mediatemp/.env
touch /var/log/sync-mediatemp.log

# (Recreate cron or systemd jobs as needed)
```

---

## 🔒 Optional: HTTPS Access

If you want to secure the log viewer with HTTPS:
- Use Nginx reverse proxy
- Add a Let's Encrypt cert
- Or self-sign for internal-only access

Details available upon request.

---

## 📤 GitHub Workflow

Once changes are made and tested:

```bash
cd ~/sync-mediatemp
git add .
git commit -m "Updated script/config"
git push
```

---

## 🧾 License

MIT
