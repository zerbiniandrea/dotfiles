#!/usr/bin/env bash
# Compress a video to fit under Discord's ~10 MB cap (video only, no audio).
# Two-pass libx264 at a bitrate computed from the clip duration.
#   usage: discord-compress.sh <input> [output]
# Default output is <input-basename>-discord.mp4 next to the input.
set -euo pipefail

TARGET_MIB=9.5 # stay safely under Discord's 10 MB cap

in="${1:?usage: discord-compress.sh <input> [output]}"
[[ -f "$in" ]] || {
	echo "File not found: $in" >&2
	exit 1
}
out="${2:-${in%.*}-discord.mp4}"

target_bytes="$(awk -v m="$TARGET_MIB" 'BEGIN { printf "%d", m * 1024 * 1024 }')"
in_bytes="$(stat -c %s "$in")"

if ((in_bytes <= target_bytes)); then
	# Already under the cap — just strip audio and remux, no quality loss.
	ffmpeg -y -i "$in" -c:v copy -an -movflags +faststart "$out"
	mode="copied"
else
	# bitrate = target_bits / duration (video only).
	dur="$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$in")"
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
	ffmpeg -y -i "$in" "${vf[@]}" -c:v libx264 -b:v "${bitrate}k" -preset medium \
		-passlogfile "$passlog" -pass 1 -an -f null /dev/null
	ffmpeg -y -i "$in" "${vf[@]}" -c:v libx264 -b:v "${bitrate}k" -preset medium \
		-passlogfile "$passlog" -pass 2 -an -movflags +faststart "$out"
	rm -f "$passlog"-0.log "$passlog"-0.log.mbtree
fi

echo "$out ($mode · $(du -h "$out" | cut -f1))"
