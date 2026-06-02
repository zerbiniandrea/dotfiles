#!/usr/bin/env bash
# Toggle screen recording with wf-recorder (VAAPI hardware encoding on AMD).
# Captures desktop audio only (no mic — use OBS for anything fancier).
#   first press : select a region (slurp) and start recording
#   second press: stop cleanly and save
#   arg "screen": record the focused monitor instead of a region
set -euo pipefail

VIDEO_DIR="$HOME/Videos"
VAAPI_DEVICE=/dev/dri/renderD128 # RX 9070 XT (dGPU) render node

# Already recording? SIGINT finalizes the file. Stop and exit.
if pkill -INT -x wf-recorder; then
	notify-send -t 2000 -a wf-recorder "Recording stopped" "Saved to ${VIDEO_DIR/#$HOME/~}"
	exit 0
fi

mkdir -p "$VIDEO_DIR"
file="$VIDEO_DIR/$(date +%Y-%m-%d_%H-%M-%S).mp4"

if [[ "${1:-}" == "screen" ]]; then
	target=(-o "$(hyprctl monitors -j | jq -r '.[] | select(.focused).name')")
	what="monitor"
else
	geom="$(slurp)" || exit 0 # selection cancelled
	target=(-g "$geom")
	what="region"
fi

notify-send -t 2000 -a wf-recorder "Recording started ($what)" "$(basename "$file")"
exec wf-recorder "${target[@]}" -c h264_vaapi -d "$VAAPI_DEVICE" \
	--audio="$(pactl get-default-sink).monitor" -f "$file"
