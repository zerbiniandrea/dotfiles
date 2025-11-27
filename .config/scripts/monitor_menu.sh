#!/bin/bash

# Monitor menu script for Rofi

# Monitor names
LAPTOP_MONITOR="eDP-1"
EXTERNAL_MONITOR="HDMI-A-1"

options="󰍹 External Only\n󰍺 Dual Monitors\n󰌢 Laptop Only"

chosen=$(echo -e "$options" | rofi -dmenu -i -l 3 -p "Monitor Setup" -theme-str 'window {width: 300px;}')

case $chosen in
"󰍹 External Only")
    # Enable external monitor first at safe position (in case it was disabled)
    hyprctl keyword monitor "$EXTERNAL_MONITOR,2560x1440@120,1920x0,1.25"
    # Move all workspaces from laptop to external monitor
    for ws in $(hyprctl workspaces -j | jq -r ".[] | select(.monitor == \"$LAPTOP_MONITOR\") | .id"); do
        hyprctl dispatch moveworkspacetomonitor "$ws" "$EXTERNAL_MONITOR"
    done
    # Then disable laptop monitor
    hyprctl keyword monitor "$LAPTOP_MONITOR,disable"
    notify-send "Monitor Setup" "External monitor only"
    ;;
"󰍺 Dual Monitors")
    hyprctl keyword monitor "$LAPTOP_MONITOR,1920x1080@144,0x0,1"
    hyprctl keyword monitor "$EXTERNAL_MONITOR,2560x1440@120,1920x0,1.25"
    notify-send "Monitor Setup" "Dual monitor mode enabled"
    ;;
"󰌢 Laptop Only")
    # Enable laptop monitor first (in case it was disabled)
    hyprctl keyword monitor "$LAPTOP_MONITOR,1920x1080@144,0x0,1"
    # Move all workspaces from external to laptop monitor
    for ws in $(hyprctl workspaces -j | jq -r ".[] | select(.monitor == \"$EXTERNAL_MONITOR\") | .id"); do
        hyprctl dispatch moveworkspacetomonitor "$ws" "$LAPTOP_MONITOR"
    done
    # Then disable external monitor
    hyprctl keyword monitor "$EXTERNAL_MONITOR,disable"
    notify-send "Monitor Setup" "Laptop monitor only"
    ;;
esac
