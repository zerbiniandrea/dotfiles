#!/bin/bash
# Unified cloud backup — run as: backup.sh <keepass|wow|aegis>
# Driven by backup@<target>.timer (daily 16:00).

set -euo pipefail

backup_keepass() {
    local src="$HOME/KeePass"
    local dest="gdrive:Backups/KeePass"

    [ -d "$src" ] || { echo "Error: $src not found"; exit 1; }

    # Makes the remote exactly match the local folder.
    rclone sync "$src" "$dest"
}

backup_wow() {
    local src="$HOME/Games/World of Warcraft/_retail_/WTF"
    local backup_dir="$HOME/Backups/WoW/WTF"
    local staging="$backup_dir/latest"
    local dest="gdrive:Games/WoW/WTF Backups"

    mkdir -p "$staging"
    rsync -a --delete "$src/" "$staging/"

    tar -czf "$backup_dir/backup-$(date +%Y%m%d%H%M%S).tar.gz" -C "$staging" .

    # Keep only the last 10 archives locally; Drive mirrors the rotation.
    ls -t "$backup_dir"/backup-*.tar.gz | tail -n +11 | xargs -r rm
    rclone sync "$backup_dir" "$dest" --include "*.tar.gz" --delete-excluded
}

backup_aegis() {
    local src="$HOME/Backups/Aegis"
    local dest="gdrive:Backups/Aegis"

    [ -d "$src" ] || { echo "Error: $src not found"; exit 1; }

    # copy, not sync: if the phone rotates old exports away (and syncthing
    # propagates the deletion here), the copies already on Drive must survive.
    rclone copy "$src" "$dest" --exclude ".stfolder/**"
}

TARGET="${1:-}"
case "$TARGET" in
    keepass|wow|aegis)
        echo "Starting $TARGET backup..."
        "backup_$TARGET"
        echo "$TARGET backup completed at $(date)"
        ;;
    *)
        echo "usage: $(basename "$0") <keepass|wow|aegis>" >&2
        exit 1
        ;;
esac
