#!/bin/bash

# Enhanced theme switcher script inspired by Omarchy
# Usage: theme-switcher.sh [theme-name]

THEMES_DIR="$HOME/dotfiles/.config/themes"
CURRENT_LINK="$HOME/dotfiles/.config/themes/current/theme"

list_themes() {
    echo "Available themes:"
    for theme in "$THEMES_DIR"/*; do
        if [ -d "$theme" ] && [ "$(basename "$theme")" != "current" ]; then
            echo "  - $(basename "$theme")"
        fi
    done
}

apply_terminal_theme() {
    local theme_path="$1"
    
    # Apply kitty theme if kitty.conf exists in theme
    if [ -f "$theme_path/kitty.conf" ]; then
        echo "Applying kitty theme..."
        ln -sf "$theme_path/kitty.conf" "$HOME/.config/kitty/current-theme.conf"
        # Signal kitty to reload config
        pkill -SIGUSR1 kitty 2>/dev/null || true
    fi
}

apply_notification_theme() {
    # Mako automatically uses theme colors from include
    echo "Applying mako theme..."
    # Just reload mako to pick up new theme colors
    makoctl reload 2>/dev/null || true
}

apply_osd_theme() {
    local theme_path="$1"
    
    # Apply swayosd theme if swayosd-style.css exists in theme
    if [ -f "$theme_path/swayosd-style.css" ]; then
        echo "Applying swayosd theme..."
        mkdir -p "$HOME/.config/swayosd"
        
        # Use symlink to theme's complete style file
        ln -sf "$theme_path/swayosd-style.css" "$HOME/.config/swayosd/style.css"
        
        # Restart swayosd to apply new theme
        pkill swayosd 2>/dev/null || true
        sleep 0.5
        uwsm app -s b -- swayosd-server >/dev/null 2>&1 &
        disown
    fi
}

apply_rofi_theme() {
    local theme_name="$1"
    
    # Apply rofi theme by updating the color symlink
    if [ -f "$HOME/.config/rofi/colors/$theme_name.rasi" ]; then
        echo "Applying Rofi theme..."
        ln -sf "$HOME/.config/rofi/colors/$theme_name.rasi" "$HOME/.config/rofi/colors/current.rasi"
    fi
}

apply_wallpaper() {
    local theme_path="$1"
    
    # Apply wallpaper if backgrounds directory exists
    if [ -d "$theme_path/backgrounds" ]; then
        echo "Applying wallpaper..."
        local wallpaper_dir="$theme_path/backgrounds"
        
        # Find the first image file in the backgrounds directory
        local wallpaper=$(find "$wallpaper_dir" -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" \) | head -1)
        
        if [ -n "$wallpaper" ] && [ -f "$wallpaper" ]; then
            # Update wallpaper symlink
            ln -sf "$wallpaper" "$HOME/dotfiles/.config/themes/current/wallpaper"
            
            # Need to unload all wallpapers first to clear cache
            hyprctl hyprpaper unload all 2>/dev/null || true
            
            # Now load and apply the new wallpaper through the symlink
            hyprctl hyprpaper preload "$HOME/dotfiles/.config/themes/current/wallpaper" 2>/dev/null || true
            hyprctl hyprpaper wallpaper ",$HOME/dotfiles/.config/themes/current/wallpaper" 2>/dev/null || true
            
            # Reset wallpaper cycle state to start from first wallpaper
            echo "0" > "$HOME/.cache/wallpaper-cycle-state"
        fi
    fi
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
    
    # Update theme symlink
    rm -f "$CURRENT_LINK"
    ln -sf "$theme_path" "$CURRENT_LINK"
    
    # Apply theme to different components
    apply_terminal_theme "$theme_path"
    # Hyprland automatically uses the symlinked theme
    apply_notification_theme "$theme_path"
    apply_osd_theme "$theme_path"
    apply_rofi_theme "$theme_name"
    apply_wallpaper "$theme_path"
    
    # Restart/reload components
    echo "Restarting components..."
    
    # Restart waybar
    killall waybar 2>/dev/null || true
    sleep 0.5
    uwsm app -- waybar >/dev/null 2>&1 &
    disown
    
    # Reload hyprland
    hyprctl reload
    
    # Reload btop if running
    pkill -SIGUSR2 btop 2>/dev/null || true
    
    # Restart mako (notifications)
    pkill mako 2>/dev/null || true
    sleep 0.5
    uwsm app -- mako >/dev/null 2>&1 &
    disown
    
    echo "Theme '$theme_name' applied successfully!"
    echo "All components have been updated and reloaded."
}

# Main logic
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