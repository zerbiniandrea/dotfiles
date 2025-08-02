#!/bin/bash

# Get current power profile
get_current_profile() {
    powerprofilesctl | grep -E '^\*' | awk '{print $2}' | tr -d ':'
}

# Show rofi menu for power profile selection
show_menu() {
    current=$(get_current_profile)
    
    # Create menu options with current selection marked
    options=""
    if [[ "$current" == "performance" ]]; then
        options="󰠠 Performance (active)\n󰾅 Balanced\n󱤅 Power Saver"
    elif [[ "$current" == "power-saver" ]]; then
        options="󰠠 Performance\n󰾅 Balanced\n󱤅 Power Saver (active)"
    else
        options="󰠠 Performance\n󰾅 Balanced (active)\n󱤅 Power Saver"
    fi
    
    # Show rofi menu
    choice=$(echo -e "$options" | rofi -dmenu -p "Power Profile" -theme-str "window {width: 300px;}")
    
    # Set power profile based on choice
    case "$choice" in
        *"Performance"*)
            powerprofilesctl set performance
            notify-send "Power Profile" "Set to Performance Mode" -i battery-full
            pkill -RTMIN+9 waybar  # Signal waybar to update
            ;;
        *"Balanced"*)
            powerprofilesctl set balanced
            notify-send "Power Profile" "Set to Balanced Mode" -i battery-good
            pkill -RTMIN+9 waybar  # Signal waybar to update
            ;;
        *"Power Saver"*)
            powerprofilesctl set power-saver
            notify-send "Power Profile" "Set to Power Saver Mode" -i battery-low
            pkill -RTMIN+9 waybar  # Signal waybar to update
            ;;
    esac
}

# Get icon for waybar (only show for non-balanced modes)
get_waybar_display() {
    profile=$(get_current_profile)
    case $profile in
        "performance")
            echo "󰠠"
            ;;
        "power-saver")
            echo "󱤅"
            ;;
        *)
            # Return nothing to hide the module completely
            exit 1
            ;;
    esac
}

# Handle different actions
case $1 in
    "menu")
        show_menu
        ;;
    "display")
        get_waybar_display
        ;;
    *)
        get_waybar_display
        ;;
esac