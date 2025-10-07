#!/bin/bash

# Wallpaper cycling script for current theme
# Usage: wallpaper-cycle.sh

THEMES_DIR="$HOME/dotfiles/.config/themes"
CURRENT_LINK="$HOME/dotfiles/.config/themes/current/theme"
STATE_FILE="$HOME/.cache/wallpaper-cycle-state"

# Get current theme
current_theme_path=$(readlink "$CURRENT_LINK" 2>/dev/null)
if [ ! -d "$current_theme_path" ]; then
    echo "Error: No current theme set"
    exit 1
fi

backgrounds_dir="$current_theme_path/backgrounds"
if [ ! -d "$backgrounds_dir" ]; then
    echo "Error: No backgrounds directory found for current theme"
    exit 1
fi

# Get all wallpaper files
wallpapers=($(find "$backgrounds_dir" -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" \) | sort))

if [ ${#wallpapers[@]} -eq 0 ]; then
    echo "Error: No wallpapers found in current theme"
    exit 1
fi

# Read current wallpaper index from state file
current_index=0
if [ -f "$STATE_FILE" ]; then
    current_index=$(cat "$STATE_FILE" 2>/dev/null || echo 0)
fi

# Cycle to next wallpaper
next_index=$(( (current_index + 1) % ${#wallpapers[@]} ))
next_wallpaper="${wallpapers[$next_index]}"

echo "Switching to wallpaper $((next_index + 1))/${#wallpapers[@]}: $(basename "$next_wallpaper")"

# Update wallpaper symlink
ln -sf "$next_wallpaper" "$HOME/dotfiles/.config/themes/current/wallpaper"

# Need to unload all wallpapers first to clear cache
hyprctl hyprpaper unload all 2>/dev/null || true

# Apply wallpaper (hyprpaper will use the symlink)
hyprctl hyprpaper preload "$HOME/dotfiles/.config/themes/current/wallpaper" 2>/dev/null || true
hyprctl hyprpaper wallpaper ",$HOME/dotfiles/.config/themes/current/wallpaper" 2>/dev/null || true

# Save current index
echo "$next_index" > "$STATE_FILE"

# Send notification
notify-send "Wallpaper" "$(basename "$next_wallpaper")" -t 2000