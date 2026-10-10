#!/usr/bin/env bash
# Post-hook for the sddm user template: installs the rendered theme.conf into
# simple-sddm-2 (user-owned, see README) with the current wallpaper copied into
# Backgrounds/, since sddm runs before login and can't read ~.
set -euo pipefail

sddm_dir=/usr/share/sddm/themes/simple-sddm-2
rendered="${XDG_CACHE_HOME:-$HOME/.cache}/noctalia/sddm-theme.conf"
wallpaper=$(readlink -f "${XDG_CACHE_HOME:-$HOME/.cache}/noctalia/wallpaper" 2>/dev/null || true)

[ -w "$sddm_dir" ] || { echo "sddm theme dir not writable: $sddm_dir" >&2; exit 0; }

rm -f "$sddm_dir/Backgrounds/current."*
bg=""
if [ -f "$wallpaper" ]; then
    ext="${wallpaper##*.}"
    cp "$wallpaper" "$sddm_dir/Backgrounds/current.$ext"
    chmod a+r "$sddm_dir/Backgrounds/current.$ext"
    bg="Backgrounds/current.$ext"
fi

sed "s|__WALLPAPER__|$bg|" "$rendered" > "$sddm_dir/theme.conf"
