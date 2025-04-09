#!/bin/bash

LOCKFILE="/tmp/sync-mediatemp.lock"
exec 200>$LOCKFILE
flock -n 200 || exit 1

WEBHOOK_URL="https://discordapp.com/api/webhooks/1359376456991375431/oNoD_sMFYrAfAPnYHh8RA2ocLUb8h30SyB37QNNeXC38tgtUid_XT7uhvAlBM7H1QqSX"
LOGFILE="/var/log/sync-mediatemp.log"
DEST_DIR="/mnt/Media/MediaTemp"
TEMP_DIR="$DEST_DIR/.inprogress"
RSYNC_OPTS="-avz --inplace --partial --progress --temp-dir=$TEMP_DIR"
SSH_CMD="ssh"
REMOTE_PATH="mediasource:/home/lgraak/files/MediaTemp/"

MIN_FREE_MB=20480  # 20GB

echo "[START $(date)] Starting sync..." >> "$LOGFILE"

error() {
    MSG="🚨 Sync error: $1"
    echo "[ERROR $(date)] $MSG" | tee -a "$LOGFILE"
    curl -s -H "Content-Type: application/json" -X POST \
      -d "{\"content\": \"$MSG\"}" "$WEBHOOK_URL" > /dev/null
}

# Ensure temp dir exists and destination folders exist
mkdir -p "$TEMP_DIR"
for folder in Books Movies Music TV; do
    mkdir -p "$DEST_DIR/$folder"
done

# Check for free disk space before syncing
AVAIL_MB=$(df "$DEST_DIR" | awk 'NR==2 {print $4}')
if [ "$AVAIL_MB" -lt "$MIN_FREE_MB" ]; then
    error "Not enough disk space at $DEST_DIR. Available: ${AVAIL_MB}MB"
    exit 1
fi

# Step 1: Sync from remote into destination with retry
MAX_RETRIES=3
RETRY_DELAY=30
attempt=1
success=0

while [ $attempt -le $MAX_RETRIES ]; do
    echo "[INFO] Attempt $attempt at $(date)" >> "$LOGFILE"
    rsync $RSYNC_OPTS -e "$SSH_CMD" "$REMOTE_PATH" "$DEST_DIR/" >> "$LOGFILE" 2>&1
    if [ $? -eq 0 ]; then
        success=1
        echo "[INFO] rsync completed successfully on attempt $attempt" >> "$LOGFILE"
        break
    else
        echo "[WARN] Attempt $attempt failed. Retrying in $RETRY_DELAY seconds..." >> "$LOGFILE"
        sleep $RETRY_DELAY
    fi
    attempt=$((attempt + 1))
done

if [ $success -ne 1 ]; then
    error "rsync from mediasource failed after $MAX_RETRIES attempts"
    exit 1
fi

echo "[FINISH $(date)] Sync completed." >> "$LOGFILE"

