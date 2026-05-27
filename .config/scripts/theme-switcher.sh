#!/bin/bash

# Theme switcher: rotates ~/.config/themes/current/theme symlink and reloads
# the stack to pick up the new colors. waybar/mako/swayosd are gone — wayle
# owns bar/notifications/osd now.
# Usage: theme-switcher.sh [theme-name]

THEMES_DIR="$HOME/.config/themes"
CURRENT_DIR="$THEMES_DIR/current"
CURRENT_LINK="$CURRENT_DIR/theme"
WALLPAPERS_DIR="$HOME/Pictures/Wallpapers"
SDDM_THEME_DIR="/usr/share/sddm/themes/simple-sddm-2"
DEFAULT_THEME="kanso-zen"

init_theme_system() {
    if [ ! -d "$CURRENT_DIR" ]; then
        echo "Initializing theme system..."
        mkdir -p "$CURRENT_DIR"
    fi

    if [ ! -L "$CURRENT_LINK" ] || [ ! -e "$CURRENT_LINK" ]; then
        echo "No theme set, applying default theme: $DEFAULT_THEME"
        switch_theme "$DEFAULT_THEME"
        exit 0
    fi
}

list_themes() {
    echo "Available themes:"
    for theme in "$THEMES_DIR"/*; do
        if [ -d "$theme" ] && [ "$(basename "$theme")" != "current" ]; then
            echo "  - $(basename "$theme")"
        fi
    done
}

apply_terminal_theme() {
    # Theme include is at ../themes/current/theme/kitty.conf; SIGUSR1 reloads.
    pkill -SIGUSR1 kitty 2>/dev/null || true
}

# Map: theme dir name -> nvim colorscheme name
declare -A NVIM_COLORSCHEME=(
    [kanagawa-dragon]=kanagawa-dragon
    [kanso-zen]=kanso-zen
    [kanso-ink]=kanso-ink
    [adwaita-dark]=adwaita
    [catppuccin]=catppuccin-mocha
    [tokyo-night]=tokyonight-night
)

apply_nvim_theme() {
    local theme_name="$1"
    local nvim_cs="${NVIM_COLORSCHEME[$theme_name]:-}"
    if [ -z "$nvim_cs" ]; then
        echo "  (no nvim colorscheme mapped for '$theme_name')"
        return
    fi

    # Persist for new nvim sessions (read by ~/.config/nvim/after/plugin/active-theme.lua).
    echo "$nvim_cs" > "$HOME/.cache/nvim-theme"

    # Signal running nvim instances via their auto-created sockets.
    # --remote-expr runs without touching input state (unlike --remote-send).
    for sock in /run/user/"$(id -u)"/nvim.*.0; do
        [ -S "$sock" ] || continue
        nvim --server "$sock" --remote-expr "execute('colorscheme $nvim_cs')" >/dev/null 2>&1 || true
    done
}

apply_wallpaper() {
    local theme_name="$1"
    local wallpaper_dir="$WALLPAPERS_DIR/$theme_name"

    if [ -d "$wallpaper_dir" ]; then
        echo "Applying wallpaper..."

        local wallpaper
        wallpaper=$(find "$wallpaper_dir" -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" \) | sort | head -1)

        if [ -n "$wallpaper" ] && [ -f "$wallpaper" ]; then
            ln -sf "$wallpaper" "$CURRENT_DIR/wallpaper"
            for mon in $(hyprctl monitors -j | jq -r '.[].name'); do
                hyprctl hyprpaper wallpaper "$mon,$CURRENT_DIR/wallpaper" >/dev/null 2>&1 || true
            done
            echo "0" > "$HOME/.cache/wallpaper-cycle-state"
        fi
    fi
}

# simple-sddm-2's dir is user-owned so this needs no sudo. Each theme ships its
# own sddm.conf with palette+layout tuned to its aesthetic; the wallpaper is
# copied into Backgrounds/ because sddm runs before login and can't read ~.
apply_sddm_theme() {
    local theme_name="$1"
    local theme_path="$THEMES_DIR/$theme_name"
    local src="$theme_path/sddm.conf"

    if [ ! -w "$SDDM_THEME_DIR" ]; then
        echo "  (sddm theme dir not writable, skipping: $SDDM_THEME_DIR)"
        return
    fi

    if [ ! -f "$src" ]; then
        echo "  (no sddm.conf for '$theme_name')"
        return
    fi

    echo "Applying sddm theme..."

    local wallpaper_dir="$WALLPAPERS_DIR/$theme_name"
    local wallpaper=""
    local bg_relpath=""

    if [ -d "$wallpaper_dir" ]; then
        wallpaper=$(find "$wallpaper_dir" -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" \) | sort | head -1)
    fi

    rm -f "$SDDM_THEME_DIR/Backgrounds/current."*

    if [ -n "$wallpaper" ] && [ -f "$wallpaper" ]; then
        local ext="${wallpaper##*.}"
        cp "$wallpaper" "$SDDM_THEME_DIR/Backgrounds/current.$ext"
        chmod a+r "$SDDM_THEME_DIR/Backgrounds/current.$ext"
        bg_relpath="Backgrounds/current.$ext"
    fi

    sed "s|__WALLPAPER__|$bg_relpath|" "$src" > "$SDDM_THEME_DIR/theme.conf"
}


switch_theme() {
    local theme_name="$1"
    local theme_path="$THEMES_DIR/$theme_name"

    if [ ! -d "$theme_path" ]; then
        echo "Error: Theme '$theme_name' not found."
        list_themes
        exit 1
    fi

    echo "Switching to theme: $theme_name"

    rm -f "$CURRENT_LINK"
    ln -sf "$theme_path" "$CURRENT_LINK"

    apply_terminal_theme "$theme_path"
    apply_nvim_theme "$theme_name"
    apply_wallpaper "$theme_name"
    apply_sddm_theme "$theme_name"

    echo "Reloading hyprland..."
    hyprctl reload

    echo "Theme '$theme_name' applied successfully!"
}

init_theme_system

if [ $# -eq 0 ]; then
    current_theme=$(readlink "$CURRENT_LINK" 2>/dev/null | xargs basename 2>/dev/null || echo "none")
    echo "Current theme: $current_theme"
    echo
    list_themes
    echo
    echo "Usage: $0 [theme-name]"
else
    switch_theme "$1"
fi
