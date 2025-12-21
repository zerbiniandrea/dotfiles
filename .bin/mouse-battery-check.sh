#!/bin/bash

# Mouse battery check script
# Sends a notification when battery is low

THRESHOLD=20

# Get battery level from solaar
battery=$(solaar show 2>/dev/null | grep -oP 'Battery: \K[0-9]+' | head -1)

if [[ -z "$battery" ]]; then
    notify-send -u warning "Mouse Battery Check Failed" "Could not read battery level from solaar"
    exit 1
fi

if [[ "$battery" -le "$THRESHOLD" ]]; then
    notify-send "Mouse Battery Low" "G502 X PLUS battery at ${battery}%"
fi
