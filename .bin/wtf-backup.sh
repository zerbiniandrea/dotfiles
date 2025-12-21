#!/bin/bash

# Set source and destination paths
SOURCE_DIR="$HOME/Games/World of Warcraft/_retail_/WTF"
BACKUP_DIR="$HOME/Backups/WoW/WTF"
STAGING_DIR="$BACKUP_DIR/latest"
CLOUD_PATH="gdrive:Games/WoW/WTF Backups"

# Create staging directory if it doesn't exist
mkdir -p "$STAGING_DIR"

# Sync files to staging (this becomes your "latest" backup)
rsync -av "$SOURCE_DIR/" "$STAGING_DIR/"

# Create timestamped archive backup for version history
TIMESTAMP=$(date +%Y%m%d%H%M%S)
BACKUP_FILE="backup-$TIMESTAMP.tar.gz"
tar -czf "$BACKUP_DIR/$BACKUP_FILE" -C "$STAGING_DIR" .

# Rotate: keep only the last 10 archived backups locally
ls -t "$BACKUP_DIR"/backup-*.tar.gz | tail -n +11 | xargs -r rm

# Sync the entire backup directory to Google Drive after rotation
# This will upload new files and delete removed files
rclone sync "$BACKUP_DIR" "$CLOUD_PATH" --include "*.tar.gz" --delete-excluded --progress
