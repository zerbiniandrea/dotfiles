#!/bin/bash

# Waybar notification status script
# Only shows when DND is active

# Get current mako mode
current_mode=$(makoctl mode)

if echo "$current_mode" | grep -q "do-not-disturb"; then
    # DND is active - show DND bell
    echo '{"text": "󰂛", "class": "dnd-active"}'
else
    # Notifications enabled - show normal bell
    echo '{"text": "󰂚", "class": "dnd-inactive"}'
fi