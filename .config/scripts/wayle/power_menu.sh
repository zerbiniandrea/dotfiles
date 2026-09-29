#!/bin/bash

if [ -n "$(~/.config/scripts/wayle/caffeine.sh status)" ]; then
    caffeine="󰅶 Caffeine: On"
else
    caffeine="󰅶 Caffeine: Off"
fi

options="󰐥 Power Off\n Reboot\n󰤄 Suspend\n󰌾 Lock\n$caffeine"

chosen=$(echo -e "$options" | rofi -dmenu -i -l 5 -p "Power Menu" -theme-str 'window {width: 300px;}')

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
    loginctl lock-session
    ;;
"󰅶 Caffeine: "*)
    ~/.config/scripts/wayle/caffeine.sh toggle
    ;;
esac
