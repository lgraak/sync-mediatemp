# sync-mediatemp (2025 Overhaul)

## 🚀 Purpose

This script syncs media files from a remote SSH-accessible Linux server to a local directory mounted via Samba.

### ✅ Why We Updated It

The original version:
- Used `find -mtime` to build a file list
- Missed some BitTorrent-downloaded files that had older modification times

The new version:
- Lets `rsync` decide what needs copying
- Uses `--update` to avoid overwriting newer local files
- Removes file list dependency entirely

---

## 🛠 What's Included

- `sync-mediatemp.sh`: The updated sync script
- `README.md`: This file

---

## 🔁 Installation (after testing)

```bash
# Copy to system location
cp sync-mediatemp.sh /usr/local/bin/
chmod +x /usr/local/bin/sync-mediatemp.sh
```

---

## 🔌 Disable Old Version (systemd)

```bash
systemctl disable --now sync-mediatemp.service
systemctl disable --now sync-mediatemp.timer
```

---

## ☁️ Upload to GitHub

```bash
cd ~/sync-mediatemp
cp /usr/local/bin/sync-mediatemp.sh .

git add sync-mediatemp.sh README.md
git commit -m "Overhaul: Removed find logic, improved rsync behavior"
git push
```

---

## 🧪 One-Off Sync (manual run)

```bash
/usr/local/bin/sync-mediatemp.sh
```
