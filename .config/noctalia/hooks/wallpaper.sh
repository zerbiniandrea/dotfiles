#!/usr/bin/env bash
# wallpaper_changed/started hook: keeps a stable symlink to Noctalia's current
# wallpaper for hyprlock (background path) and refreshes SDDM's copy.
set -euo pipefail

link="${XDG_CACHE_HOME:-$HOME/.cache}/noctalia/wallpaper"
path=$(noctalia msg wallpaper-get 2>/dev/null || true)

[ -f "$path" ] || exit 0
mkdir -p "$(dirname "$link")"
ln -sfn "$path" "$link"

bash "$HOME/.config/noctalia/hooks/sddm.sh"
