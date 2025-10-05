#!/bin/bash

# Notification toggle script - just toggle mako DND mode
# Status is shown in waybar, not via SwayOSD

# Get current mako mode
current_mode=$(makoctl mode)

if echo "$current_mode" | grep -q "do-not-disturb"; then
    # Currently in DND, enable notifications
    makoctl mode -r do-not-disturb
    makoctl dismiss -a
else
    # Currently enabled, disable notifications
    makoctl mode -a do-not-disturb
fi

# Signal waybar to refresh (if you have a custom module for this)
pkill -RTMIN+10 waybar 2>/dev/null || true
