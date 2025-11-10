#!/bin/bash

options="󰐥 Power Off\n Reboot\n󰤄 Suspend\n󰌾 Lock"

chosen=$(echo -e "$options" | rofi -dmenu -i -l 4 -p "Power Menu" -theme-str 'window {width: 300px;}')

case $chosen in
"󰐥 Power Off")
    systemctl poweroff
    ;;
" Reboot")
    systemctl reboot
    ;;
"󰤄 Suspend")
    systemctl suspend
    ;;
"󰌾 Lock")
    hyprlock
    ;;
esac
