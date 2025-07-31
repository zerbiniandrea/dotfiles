#!/bin/bash

SPOTIFY_WS=9
STATE_FILE="/tmp/spotify_toggle_state"

# Get current workspace
current_ws=$(hyprctl activeworkspace -j | jq -r '.id')

# Check if Spotify is running
if pgrep -x "spotify" >/dev/null; then
    # Spotify is running
    if [ "$current_ws" -eq "$SPOTIFY_WS" ]; then
        # We're on Spotify workspace, go back to previous
        if [ -f "$STATE_FILE" ]; then
            prev_ws=$(cat "$STATE_FILE")
            hyprctl dispatch workspace "$prev_ws"
        else
            # Fallback to workspace 1 if no previous state
            hyprctl dispatch workspace 1
        fi
    else
        # We're not on Spotify workspace, save current and go to Spotify
        echo "$current_ws" >"$STATE_FILE"
        hyprctl dispatch workspace "$SPOTIFY_WS"
    fi
else
    # Spotify is not running, launch it and go to workspace 9
    echo "$current_ws" >"$STATE_FILE"
    uwsm app -- spotify-launcher &
    hyprctl dispatch workspace "$SPOTIFY_WS"
fi

