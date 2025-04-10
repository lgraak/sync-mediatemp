#!/bin/bash

LOCKFILE="/tmp/sync-mediatemp.lock"
exec 200>$LOCKFILE
flock -n 200 || exit 1

# Load variables from .env if it exists
ENV_FILE="/root/sync-mediatemp/.env"
if [ -f "$ENV_FILE" ]; then
    set -o allexport
    source "$ENV_FILE"
    set +o allexport
fi

WEBHOOK_URL="https://discordapp.com/api/webhooks/1359376456991375431/oNoD_sMFYrAfAPnYHh8RA2ocLUb8h30SyB37QNNeXC38tgtUid_XT7uhvAlBM7H1QqSX"
LOGFILE="/var/log/sync-mediatemp.log"
DEST_DIR="/mnt/Media/MediaTemp"
TEMP_DIR="$DEST_DIR/.inprogress"
SSH_CMD="ssh"
REMOTE_PATH="mediasource:/home/lgraak/files/MediaTemp/"
FILELIST_TMP="/tmp/rsync_filelist.txt"

echo "[START $(date)] Starting sync..." >> "$LOGFILE"

error() {
    MSG="🚨 Sync error: $1"
    echo "[ERROR $(date)] $MSG" | tee -a "$LOGFILE"
    curl -s -H "Content-Type: application/json" -X POST \
      -d "{\"content\": \"$MSG\"}" "$WEBHOOK_URL" > /dev/null
}

# ✅ Check and mount CIFS if needed
if ! mountpoint -q /mnt/Media; then
    echo "[WARN $(date)] /mnt/Media is not mounted, attempting mount..." >> "$LOGFILE"
    mount /mnt/Media
    sleep 2
    if ! mountpoint -q /mnt/Media; then
        error "CIFS mount at /mnt/Media failed to remount."
        exit 1
    else
        echo "[INFO $(date)] Remounted /mnt/Media successfully." >> "$LOGFILE"
    fi
fi

# Ensure temp dir and subfolders exist
mkdir -p "$TEMP_DIR"
for folder in Books Movies Music TV; do
    mkdir -p "$DEST_DIR/$folder"
done

# Check disk space
AVAIL_MB=$(df "$DEST_DIR" | awk 'NR==2 {print $4}')
if [ "$AVAIL_MB" -lt "$MIN_FREE_MB" ]; then
    error "Not enough disk space at $DEST_DIR. Available: ${AVAIL_MB}MB"
    exit 1
fi

# Build file list from remote
echo "[INFO] Building file list for last $SYNC_WINDOW_DAYS days..." >> "$LOGFILE"
$SSH_CMD mediasource "find /home/lgraak/files/MediaTemp -type f -mtime -$SYNC_WINDOW_DAYS" > "$FILELIST_TMP"
if [ $? -ne 0 ]; then
    error "Failed to get file list from remote"
    exit 1
fi

# Log currently syncing folder (best guess from first path)
SYNCING_FOLDER=$(head -n 1 "$FILELIST_TMP" | awk -F '/' '{print $(NF-1)}')
if [ -n "$SYNCING_FOLDER" ]; then
    echo "[SYNCING] Folder: $SYNCING_FOLDER" >> "$LOGFILE"
fi

# Sync with retry logic
attempt=1
success=0

while [ $attempt -le $MAX_RETRIES ]; do
    echo "[INFO] Attempt $attempt at $(date)" >> "$LOGFILE"

    stdbuf -oL -eL rsync -avz --inplace --partial --info=progress2 \
      --files-from="$FILELIST_TMP" --relative -e "$SSH_CMD" mediasource:/ "$DEST_DIR/" >> "$LOGFILE" 2>&1

    if [ $? -eq 0 ]; then
        success=1
        echo "[INFO] rsync completed successfully on attempt $attempt" >> "$LOGFILE"
        break
    else
        echo "[WARN] Attempt $attempt failed. Retrying in $RETRY_DELAY seconds..." >> "$LOGFILE"
        sleep "$RETRY_DELAY"
    fi
    attempt=$((attempt + 1))
done

rm -f "$FILELIST_TMP"

if [ $success -ne 1 ]; then
    error "rsync from mediasource failed after $MAX_RETRIES attempts"
    exit 1
fi
