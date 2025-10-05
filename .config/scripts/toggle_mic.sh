#!/bin/bash

# Toggle microphone mute
wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle

# Check if muted after toggle and play sound
if wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | grep -q "MUTED"; then
    # Muted - play unplug sound
    paplay /usr/share/sounds/freedesktop/stereo/power-unplug.oga &
else
    # Unmuted - play plug sound
    paplay /usr/share/sounds/freedesktop/stereo/power-plug.oga &
fi

# Signal waybar to refresh the microphone module
pkill -RTMIN+8 waybar