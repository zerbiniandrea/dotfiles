#!/bin/bash
# Control the currently selected player
action="$1"
player_name_file="/tmp/waybar_current_player_name"

# Get the current player name from the Python script
if [ -f "$player_name_file" ]; then
    current_player=$(cat "$player_name_file" 2>/dev/null)
    if [ -n "$current_player" ]; then
        playerctl --player="$current_player" "$action"
        exit 0
    fi
fi

# Fallback to first player if no selection found
first_player=$(playerctl --list-all | head -1)
if [ -n "$first_player" ]; then
    playerctl --player="$first_player" "$action"
fi