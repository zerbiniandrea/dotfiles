#!/bin/bash

# Enhanced theme switcher script inspired by Omarchy
# Usage: theme-switcher.sh [theme-name]

THEMES_DIR="$HOME/dotfiles/.config/themes/themes"
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
        cp "$theme_path/kitty.conf" "$HOME/.config/kitty/current-theme.conf"
        # Signal kitty to reload config
        pkill -SIGUSR1 kitty 2>/dev/null || true
    fi
}

apply_notification_theme() {
    local theme_path="$1"
    
    # Apply mako theme if mako.ini exists in theme
    if [ -f "$theme_path/mako.ini" ]; then
        echo "Applying mako theme..."
        
        # Read the theme colors from mako.ini
        local text_color=$(grep "text-color=" "$theme_path/mako.ini" | cut -d'=' -f2)
        local border_color=$(grep "border-color=" "$theme_path/mako.ini" | cut -d'=' -f2)
        local background_color=$(grep "background-color=" "$theme_path/mako.ini" | cut -d'=' -f2)
        
        # Update mako config with new colors
        sed -i "s/text-color=.*/text-color=$text_color/" "$HOME/.config/mako/config"
        sed -i "s/border-color=.*/border-color=$border_color/" "$HOME/.config/mako/config"
        sed -i "s/background-color=.*/background-color=$background_color/" "$HOME/.config/mako/config"
        
        # Reload mako
        makoctl reload 2>/dev/null || true
    fi
}

apply_osd_theme() {
    local theme_path="$1"
    
    # Apply swayosd theme if swayosd.css exists in theme
    if [ -f "$theme_path/swayosd.css" ]; then
        echo "Applying swayosd theme..."
        mkdir -p "$HOME/.config/swayosd"
        
        # Read colors from theme's swayosd.css
        local bg_color=$(grep "background-color" "$theme_path/swayosd.css" | cut -d' ' -f3 | tr -d ';')
        local border_color=$(grep "border-color" "$theme_path/swayosd.css" | cut -d' ' -f3 | tr -d ';')
        local label_color=$(grep "label" "$theme_path/swayosd.css" | cut -d' ' -f3 | tr -d ';')
        local image_color=$(grep "image" "$theme_path/swayosd.css" | cut -d' ' -f3 | tr -d ';')
        local progress_color=$(grep "progress" "$theme_path/swayosd.css" | cut -d' ' -f3 | tr -d ';')
        
        # Create the themed style.css
        cat > "$HOME/.config/swayosd/style.css" << EOF
@define-color background-color $bg_color;
@define-color border-color $border_color;
@define-color label $label_color;
@define-color image $image_color;
@define-color progress $progress_color;

window {
    border-radius: 0;
    opacity: 0.97;
    border: 2px solid @border-color;
    background-color: @background-color;
}

label {
    font-family: 'JetBrainsMono Nerd Font Propo', sans-serif;
    font-size: 11pt;
    color: @label;
}

image {
    color: @image;
}

progressbar {
    border-radius: 0;
}

progress {
    background-color: @progress;
}
EOF
        # Restart swayosd to apply new theme
        pkill swayosd 2>/dev/null || true
        sleep 0.5
        uwsm app -- swayosd-server >/dev/null 2>&1 &
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
            # Update hyprpaper config
            cat > "$HOME/.config/hypr/hyprpaper.conf" << EOF
preload = $wallpaper
wallpaper = ,$wallpaper

# Disable splash text
splash = false
EOF
            
            # Reload hyprpaper
            hyprctl hyprpaper preload "$wallpaper" 2>/dev/null || true
            hyprctl hyprpaper wallpaper ",$wallpaper" 2>/dev/null || true
            
            # Reset wallpaper cycle state to start from first wallpaper
            echo "0" > "$HOME/.cache/wallpaper-cycle-state"
        fi
    fi
}

apply_hyprland_theme() {
    local theme_path="$1"
    
    # Apply hyprland theme colors if hyprland.conf exists
    if [ -f "$theme_path/hyprland.conf" ]; then
        echo "Applying Hyprland theme..."
        # Update the colors import in your hyprland config
        # This assumes you have a line that sources theme colors
        if grep -q "source.*themes.*theme.*hyprland" "$HOME/dotfiles/.config/hypr/hyprland.conf"; then
            sed -i "s|source.*themes.*theme.*hyprland.*|source = $theme_path/hyprland.conf|" "$HOME/dotfiles/.config/hypr/hyprland.conf"
        else
            # Add the source line if it doesn't exist
            sed -i "2i source = $theme_path/hyprland.conf" "$HOME/dotfiles/.config/hypr/hyprland.conf"
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
    apply_hyprland_theme "$theme_path"
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