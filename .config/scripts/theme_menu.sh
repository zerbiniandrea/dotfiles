#!/bin/bash

# Theme switcher rofi menu

THEMES_DIR="$HOME/dotfiles/.config/themes"

# Get available themes
themes=()
for theme in "$THEMES_DIR"/*; do
    if [ -d "$theme" ] && [ "$(basename "$theme")" != "current" ]; then
        themes+=("$(basename "$theme")")
    fi
done

# Show rofi menu
selected=$(printf '%s\n' "${themes[@]}" | rofi -dmenu -i -p "Select Theme")

# Apply selected theme
if [ -n "$selected" ]; then
    "$HOME/dotfiles/.config/scripts/theme-switcher.sh" "$selected"
fi