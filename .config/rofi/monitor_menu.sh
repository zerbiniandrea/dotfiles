#!/bin/bash

# Monitor menu script for Rofi

# Monitor names
LAPTOP_MONITOR="eDP-1"
EXTERNAL_MONITOR="HDMI-A-1"

options="󰍹 External Only\n󰍺 Dual Monitors\n󰌢 Laptop Only"

chosen=$(echo -e "$options" | rofi -dmenu -i -l 3 -p "Monitor Setup" -theme-str 'window {width: 300px;}')

case $chosen in
"󰍹 External Only")
    hyprctl keyword monitor "$LAPTOP_MONITOR,disable"
    hyprctl keyword monitor "$EXTERNAL_MONITOR,1920x1080@74.97,0x0,1"
    notify-send "Monitor Setup" "External monitor only"
    ;;
"󰍺 Dual Monitors")
    hyprctl keyword monitor "$LAPTOP_MONITOR,1920x1080@144,1920x0,1"
    hyprctl keyword monitor "$EXTERNAL_MONITOR,1920x1080@74.97,0x0,1"
    notify-send "Monitor Setup" "Dual monitor mode enabled"
    ;;
"󰌢 Laptop Only")
    hyprctl keyword monitor "$LAPTOP_MONITOR,1920x1080@144,0x0,1"
    hyprctl keyword monitor "$EXTERNAL_MONITOR,disable"
    notify-send "Monitor Setup" "Laptop monitor only"
    ;;
esac