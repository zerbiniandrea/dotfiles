#!/bin/bash

# Waybar microphone status:
#   - "active"   : a process is recording from a real (non-monitor) source (red mic icon)
#   - "disabled" : default source is muted (privacy on)
#   - "inactive" : present but idle (hidden)

if ! command -v pactl >/dev/null 2>&1; then
    printf '{"text": "", "tooltip": "", "class": "inactive"}\n'
    exit 0
fi

if wpctl get-volume @DEFAULT_AUDIO_SOURCE@ 2>/dev/null | grep -q MUTED; then
    printf '{"text": "󰍭", "tooltip": "Microphone muted", "class": "disabled"}\n'
    exit 0
fi

# Build set of monitor source IDs — recording from a sink monitor is not mic use.
monitor_ids=$(pactl list short sources 2>/dev/null | awk '$2 ~ /\.monitor$/ {print $1}' | tr '\n' ' ')

apps=$(pactl list source-outputs 2>/dev/null | awk -v monitors="$monitor_ids" '
    BEGIN { n=split(monitors, m, " "); for (i=1; i<=n; i++) mon[m[i]]=1 }
    /^Source Output #/ { src=""; app=""; next }
    /^\tSource: / { src=$2; next }
    /application\.name = / {
        s=$0
        sub(/.*= "/, "", s)
        sub(/"$/, "", s)
        app=s
    }
    /^$/ {
        if (src != "" && !(src in mon) && app != "") print app
        src=""; app=""
    }
    END {
        if (src != "" && !(src in mon) && app != "") print app
    }
' | sort -u | paste -sd ',' -)

if [ -n "$apps" ]; then
    printf '{"text": "󰍬", "tooltip": "Microphone in use: %s", "class": "active"}\n' "$apps"
else
    printf '{"text": "", "tooltip": "", "class": "inactive"}\n'
fi
