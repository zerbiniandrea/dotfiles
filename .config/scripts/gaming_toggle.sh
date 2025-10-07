#!/bin/bash

GAMING_WS=10
STATE_FILE="/tmp/gaming_toggle_state"

# Get current workspace
current_ws=$(hyprctl activeworkspace -j | jq -r '.id')

if [ "$current_ws" -eq "$GAMING_WS" ]; then
    # We're on gaming workspace, go back to previous
    if [ -f "$STATE_FILE" ]; then
        prev_ws=$(cat "$STATE_FILE")
        hyprctl dispatch workspace "$prev_ws"
    else
        # Fallback to workspace 1 if no previous state
        hyprctl dispatch workspace 1
    fi
else
    # We're not on gaming workspace, save current and go to gaming
    echo "$current_ws" > "$STATE_FILE"
    hyprctl dispatch workspace "$GAMING_WS"
fi