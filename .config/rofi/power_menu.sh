#!/bin/bash

options="Shutdown\nRestart\nLogout\nSleep"

chosen=$(echo -e "$options" | rofi -dmenu -i -p "Power Menu" -theme-str 'window {width: 300px;}')

case $chosen in
    "Shutdown")
        systemctl poweroff
        ;;
    "Restart")
        systemctl reboot
        ;;
    "Logout")
        hyprctl dispatch exit
        ;;
    "Sleep")
        systemctl suspend
        ;;
esac