#!/bin/bash

# Webcam privacy status indicator for the wayle bar.
#
# States:
#   - "active"   : a process is reading from /dev/video* (red camera icon)
#   - "disabled" : uvcvideo has no bound USB interfaces (privacy mode on)
#   - "inactive" : present but idle (hidden)

driver=/sys/bus/usb/drivers/uvcvideo

shopt -s nullglob
bound=("$driver"/*-*)
devices=(/dev/video*)
shopt -u nullglob

emit_disabled() {
    printf '{"alt": "disabled", "tooltip": "Webcam disabled (privacy mode)"}\n'
}

emit_active() {
    printf '{"alt": "active", "tooltip": "Webcam in use: %s"}\n' "$1"
}

emit_inactive() {
    echo
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
