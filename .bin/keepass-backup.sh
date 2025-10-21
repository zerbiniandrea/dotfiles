#!/bin/bash

# KeePass backup script - syncs ~/KeePass to Google Drive daily
# This will make the remote exactly match the local folder

SOURCE_DIR="$HOME/KeePass"
CLOUD_PATH="gdrive:Backups/KeePass"

# Check if source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: KeePass directory not found at $SOURCE_DIR"
    exit 1
fi

# Sync to Google Drive (makes remote identical to local)
echo "Starting KeePass backup to Google Drive..."
rclone sync "$SOURCE_DIR" "$CLOUD_PATH" --progress

if [ $? -eq 0 ]; then
    echo "KeePass backup completed successfully at $(date)"
else
    echo "KeePass backup failed at $(date)"
    exit 1
fi
