#!/bin/bash

# Waybar webcam status:
#   - "active"   : a process is reading from /dev/video* (red camera icon)
#   - "disabled" : uvcvideo has no bound USB interfaces (privacy mode on)
#   - "inactive" : present but idle (hidden)

driver=/sys/bus/usb/drivers/uvcvideo

shopt -s nullglob
bound=("$driver"/*-*)
devices=(/dev/video*)
shopt -u nullglob

if [ ${#bound[@]} -eq 0 ] && [ -e "$driver" ]; then
    printf '{"text": "󰗟", "tooltip": "Webcam disabled (privacy mode)", "class": "disabled"}\n'
    exit 0
fi

if [ ${#devices[@]} -eq 0 ]; then
    printf '{"text": "", "tooltip": "", "class": "inactive"}\n'
    exit 0
fi

pids=$(fuser "${devices[@]}" 2>/dev/null | tr -s ' ' '\n' | sort -u | grep -v '^$')

if [ -n "$pids" ]; then
    procs=$(ps -o comm= -p $pids 2>/dev/null | sort -u | paste -sd ',' -)
    printf '{"text": "󰄀", "tooltip": "Webcam in use: %s", "class": "active"}\n' "${procs:-unknown}"
else
    printf '{"text": "", "tooltip": "", "class": "inactive"}\n'
fi
