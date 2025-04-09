# MediaTemp Sync & Log Viewer

This project includes:

1. A systemd-based rsync sync script to copy media files from a remote server
2. A Python Flask-based real-time log viewer for sync logs

---

## 🧩 Features

- Syncs only files modified in the last X days (configurable)
- Retries on failure and sends errors to a Discord webhook
- Logs to `/var/log/sync-mediatemp.log`
- Streams live sync logs to a browser using Server-Sent Events (like `tail -f`)
- All configuration stored in a `.env` file

---

## 📁 Project Structure

```
sync-mediatemp/
├── sync-mediatemp.sh           # Main sync script
├── logviewer.py                # Flask real-time log viewer
├── logviewer.service           # Systemd service to run log viewer at boot
├── sync-mediatemp.service      # Systemd sync service
├── sync-mediatemp.timer        # Systemd timer
├── .env                        # Environment configuration (not tracked in Git)
├── .gitignore                  # Git ignore file
└── README.md                   # This file
```

---

## ⚙️ Setup Instructions

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/sync-mediatemp.git
cd sync-mediatemp
```

### 2. Configure SSH and `.env`

Follow the existing instructions for setting up SSH and fill out `.env` with:
```ini
SYNC_WINDOW_DAYS=30
MIN_FREE_MB=20480
MAX_RETRIES=3
RETRY_DELAY=30
```

---

## 🔁 Set Up Sync Script

```bash
sudo cp sync-mediatemp.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/sync-mediatemp.sh

sudo cp sync-mediatemp.service /etc/systemd/system/
sudo cp sync-mediatemp.timer /etc/systemd/system/

sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable --now sync-mediatemp.timer
```

---

## 🌐 Set Up Real-Time Log Viewer

### 1. Install Python dependencies
```bash
sudo apt update
sudo apt install python3-pip -y
pip3 install flask
```

### 2. Create Systemd Service

```bash
sudo cp logviewer.py /usr/local/bin/
sudo cp logviewer.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now logviewer.service
```

### 3. Access the Viewer

Open your browser to:
```
http://<server-ip>:8080
```

You’ll see a live stream of `/var/log/sync-mediatemp.log`.

---

## 🔒 Security Notes

- Do not expose this server to the public without securing access
- You can use a reverse proxy with authentication or IP restrictions

---

## 🪵 Logging

- Sync log: `/var/log/sync-mediatemp.log`
- Log viewer: view in browser or run `journalctl -u logviewer.service`

---

## 📦 Deployment Recap

1. Script and timer installed
2. Log viewer service enabled
3. Configurable via `.env`
4. GitHub connected

---

## 📜 License

MIT

---

## 🙌 Credits

Brought to life with real-world rsync frustration and a passion for automation!