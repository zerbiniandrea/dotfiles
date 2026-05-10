#!/bin/bash

# Webcam privacy status indicator.
# First arg picks the consumer's output convention: "wayle" (default) or "waybar".
#
# States:
#   - "active"   : a process is reading from /dev/video* (red camera icon)
#   - "disabled" : uvcvideo has no bound USB interfaces (privacy mode on)
#   - "inactive" : present but idle (hidden)

mode="${1:-wayle}"
driver=/sys/bus/usb/drivers/uvcvideo

shopt -s nullglob
bound=("$driver"/*-*)
devices=(/dev/video*)
shopt -u nullglob

emit_disabled() {
    if [ "$mode" = "waybar" ]; then
        printf '{"text": "󰗟", "tooltip": "Webcam disabled (privacy mode)", "class": "disabled"}\n'
    else
        printf '{"alt": "disabled", "tooltip": "Webcam disabled (privacy mode)"}\n'
    fi
}

emit_active() {
    if [ "$mode" = "waybar" ]; then
        printf '{"text": "󰄀", "tooltip": "Webcam in use: %s", "class": "active"}\n' "$1"
    else
        printf '{"alt": "active", "tooltip": "Webcam in use: %s"}\n' "$1"
    fi
}

emit_inactive() {
    if [ "$mode" = "waybar" ]; then
        printf '{"text": "", "tooltip": "", "class": "inactive"}\n'
    else
        echo
    fi
}

if [ ${#bound[@]} -eq 0 ] && [ -e "$driver" ]; then
    emit_disabled
    exit 0
fi

if [ ${#devices[@]} -eq 0 ]; then
    emit_inactive
    exit 0
fi

pids=$(fuser "${devices[@]}" 2>/dev/null | tr -s ' ' '\n' | sort -u | grep -v '^$')

if [ -n "$pids" ]; then
    procs=$(ps -o comm= -p $pids 2>/dev/null | sort -u | paste -sd ',' -)
    emit_active "${procs:-unknown}"
else
    emit_inactive
fi
