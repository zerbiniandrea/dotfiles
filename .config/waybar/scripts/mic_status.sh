#!/bin/bash

# Get microphone mute status
mute_status=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | grep -o "MUTED" || echo "")

if [[ "$mute_status" == "MUTED" ]]; then
    echo '{"text": "󰍭", "class": "muted", "tooltip": "Microphone is muted"}'
else
    echo '{"text": "󰍬", "class": "unmuted", "tooltip": "Microphone is active"}'
fi