#!/bin/bash

LOCKFILE="/tmp/sync-mediatemp.lock"
exec 200>$LOCKFILE
flock -n 200 || exit 1

# Load .env if present
ENV_FILE="/root/sync-mediatemp/.env"
if [ -f "$ENV_FILE" ]; then
    set -o allexport
    source "$ENV_FILE"
    set +o allexport
fi

WEBHOOK_URL="https://discordapp.com/api/webhooks/your_webhook_here"
LOGFILE="/var/log/sync-mediatemp.log"
DEST_DIR="/mnt/Media/MediaTemp"
TEMP_DIR="$DEST_DIR/.inprogress"
SSH_CMD="ssh"
REMOTE_PATH="mediasource:/home/lgraak/files/MediaTemp/"

echo "[START $(date)] Starting sync..." >> "$LOGFILE"

error() {
    MSG="🚨 Sync error: $1"
    echo "[ERROR $(date)] $MSG" | tee -a "$LOGFILE"
    curl -s -H "Content-Type: application/json" -X POST -d "{"content": "$MSG"}" "$WEBHOOK_URL" > /dev/null
}

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

mkdir -p "$DEST_DIR"
for folder in Books Movies Music TV; do
    mkdir -p "$DEST_DIR/$folder"
done

echo "[INFO] Starting rsync with --size-only to avoid unnecessary re-downloads..." >> "$LOGFILE"

rsync -avz --inplace --size-only --progress -e "$SSH_CMD" "$REMOTE_PATH" "$DEST_DIR" >> "$LOGFILE" 2>&1

if [ $? -ne 0 ]; then
    error "rsync encountered an error during sync."
    exit 1
fi

echo "[COMPLETE $(date)] Sync completed." >> "$LOGFILE"
