# sync-mediatemp

This script automatically syncs files from a remote server to the local `/mnt/Media/MediaTemp` directory using `rsync`. It uses `--size-only` to avoid downloading files that haven't changed in size, even if their timestamps differ.

## 💾 Files Included

- `sync-mediatemp.sh` — main sync script
- `sync-mediatemp.service` — systemd service
- `sync-mediatemp.timer` — systemd timer
- `.env` — optional file for future configs like webhook URLs

## 📦 Deployment Instructions

1. **Extract the zip on your server** (e.g., to `~/sync-mediatemp`):
    ```bash
    unzip sync-mediatemp.zip -d ~/sync-mediatemp
    cd ~/sync-mediatemp
    ```

2. **Make the script executable**:
    ```bash
    chmod +x sync-mediatemp.sh
    ```

3. **Copy files to system locations**:
    ```bash
    cp sync-mediatemp.sh /usr/local/bin/
    cp sync-mediatemp.service /etc/systemd/system/
    cp sync-mediatemp.timer /etc/systemd/system/
    ```

4. **Reload and enable systemd services**:
    ```bash
    systemctl daemon-reexec
    systemctl daemon-reload
    systemctl enable --now sync-mediatemp.timer
    ```

5. **Optional**: Run it manually to test:
    ```bash
    systemctl start sync-mediatemp.service
    ```

6. **GitHub Backup**:
    ```bash
    cd ~/sync-mediatemp
    git add .
    git commit -m "Switch to --size-only for safer syncing"
    git push
    ```

## ✅ Notes

- Ensure your remote SSH connection (`mediasource`) is working
- Make sure `/mnt/Media` is mounted before sync
- Script logs to `/var/log/sync-mediatemp.log`
