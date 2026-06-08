#!/usr/bin/env bash
# Toggle screen recording with wf-recorder (VAAPI hardware encoding on AMD).
# Video only, no audio. On stop the clip is compressed to fit under ~10 MB so
# it drops straight into Discord (use OBS for anything fancier).
#   first press : select a region (slurp) and start recording
#   second press: stop, compress to target size, and save
#   arg "screen": record the focused monitor instead of a region
set -euo pipefail

# Log everything (stdout+stderr) for debugging keybind launches.
LOG=/tmp/record-toggle.log
exec >>"$LOG" 2>&1
echo "=== $(date '+%F %T') invoked: pid=$$ args=[$*] ==="

VIDEO_DIR="$HOME/Videos"
VAAPI_DEVICE=/dev/dri/renderD128 # RX 9070 XT (dGPU) render node
TARGET_MIB=9.5                   # stay safely under Discord's 10 MB cap

# Already recording? SIGINT finalizes the raw file; the recording process then
# compresses it. Here we just signal and exit.
if pkill -INT -x wf-recorder; then
	notify-send -t 2000 -a wf-recorder "Recording stopped" "Compressing…"
	exit 0
fi

mkdir -p "$VIDEO_DIR"
stamp="$(date +%Y-%m-%d_%H-%M-%S)"
raw="$(mktemp -u --tmpdir "rec-${stamp}-XXXX.mkv")" # -u: name only, wf-recorder creates it
file="$VIDEO_DIR/$stamp.mp4"

if [[ "${1:-}" == "screen" ]]; then
	target=(-o "$(hyprctl monitors -j | jq -r '.[] | select(.focused).name')")
	what="monitor"
else
	geom="$(slurp)" || exit 0 # selection cancelled
	target=(-g "$geom")
	what="region"
fi

notify-send -t 2000 -a wf-recorder "Recording started ($what)" "$(basename "$file")"

# Record raw at full quality; wf-recorder exits 0 when it catches SIGINT.
wf-recorder "${target[@]}" -c h264_vaapi -d "$VAAPI_DEVICE" -f "$raw"

target_bytes="$(awk -v m="$TARGET_MIB" 'BEGIN { printf "%d", m * 1024 * 1024 }')"
raw_bytes="$(stat -c %s "$raw")"

if ((raw_bytes <= target_bytes)); then
	# Already under the cap — just remux to mp4, no re-encode, no quality loss.
	ffmpeg -y -i "$raw" -c copy -movflags +faststart "$file"
	mode="copied"
else
	# Compress to TARGET_MIB: bitrate = target_bits / duration (video only).
	dur="$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$raw")"
	bitrate="$(awk -v m="$TARGET_MIB" -v d="$dur" 'BEGIN { printf "%d", m * 1024 * 1024 * 8 / d / 1000 }')"

	# When the bitrate gets starved, native res just looks blocky — spend the
	# bits on a clean 1080p30 instead (scale never upscales, fps never speeds up).
	if ((bitrate < 5000)); then
		vf=(-vf "scale=-2:min(1080\,ih),fps=30")
		mode="1080p30 @ ${bitrate}k"
	else
		vf=()
		mode="native @ ${bitrate}k"
	fi

	passlog="$(mktemp -u)"
	ffmpeg -y -i "$raw" "${vf[@]}" -c:v libx264 -b:v "${bitrate}k" -preset medium \
		-passlogfile "$passlog" -pass 1 -an -f null /dev/null
	ffmpeg -y -i "$raw" "${vf[@]}" -c:v libx264 -b:v "${bitrate}k" -preset medium \
		-passlogfile "$passlog" -pass 2 -an -movflags +faststart "$file"
	rm -f "$passlog"-0.log "$passlog"-0.log.mbtree
fi

rm -f "$raw"
notify-send -t 3000 -a wf-recorder "Recording saved ($mode)" "$(basename "$file") · $(du -h "$file" | cut -f1)"
