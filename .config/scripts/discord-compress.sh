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
	# bitrate = target_bits / duration (video only). Two-pass ABR can overshoot
	# the average by 10%+ on short clips, so aim 5% below the budget and
	# hard-cap the stream at the full budget with maxrate/bufsize.
	dur="$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$in")"
	maxrate="$(awk -v m="$TARGET_MIB" -v d="$dur" 'BEGIN { printf "%d", m * 1024 * 1024 * 8 / d / 1000 }')"
	bitrate=$((maxrate * 95 / 100))

	# When the bitrate gets starved, native res just looks blocky — spend the
	# bits on a clean 1080p30 instead (scale never upscales, fps never speeds up).
	# libx264 (yuv420p) requires even dimensions, so always round to even.
	if ((bitrate < 5000)); then
		vf=(-vf "scale=-2:trunc(min(1080\,ih)/2)*2,fps=30")
		mode="1080p30"
	else
		vf=(-vf "scale=trunc(iw/2)*2:trunc(ih/2)*2")
		mode="native"
	fi

	# ABR accuracy degrades on short clips (10%+ overshoot is normal), so
	# verify the result and re-encode at a rescaled bitrate until it fits.
	passlog="$(mktemp -u)"
	for attempt in 1 2 3; do
		ffmpeg -y -i "$in" "${vf[@]}" -c:v libx264 -b:v "${bitrate}k" \
			-maxrate "${maxrate}k" -bufsize "${maxrate}k" -preset medium \
			-passlogfile "$passlog" -pass 1 -an -f null /dev/null
		ffmpeg -y -i "$in" "${vf[@]}" -c:v libx264 -b:v "${bitrate}k" \
			-maxrate "${maxrate}k" -bufsize "${maxrate}k" -preset medium \
			-passlogfile "$passlog" -pass 2 -an -movflags +faststart "$out"
		out_bytes="$(stat -c %s "$out")"
		((out_bytes <= target_bytes)) && break
		if ((attempt == 3)); then
			echo "Could not fit $out under ${TARGET_MIB} MiB (got ${out_bytes} bytes)" >&2
			exit 1
		fi
		# Scale by the measured overshoot, then take 5% extra off.
		bitrate=$((bitrate * target_bytes / out_bytes * 95 / 100))
	done
	rm -f "$passlog"-0.log "$passlog"-0.log.mbtree
	mode="$mode @ ${bitrate}k"
fi

echo "$out ($mode · $(du -h "$out" | cut -f1))"
