#!/bin/bash

# Check if gaming workspace exists
if hyprctl workspaces | grep -q "special:games"; then
    # Check if special:games workspace is currently visible by checking monitors
    if hyprctl monitors -j | jq -r '.[].specialWorkspace.name' | grep -q "special:games"; then
        echo '{"text": "󰊴", "class": "active"}'
    else
        echo '{"text": "󰊴", "class": "inactive"}'
    fi
else
    echo '{"text": "", "class": "empty"}'
fi