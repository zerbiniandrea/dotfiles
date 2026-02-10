#!/bin/bash
# Screen recording script for Hyprland using wf-recorder
# Outputs MP4 format compatible with Discord and other platforms

RECORDING_DIR="$HOME/Videos/Recordings"
PID_FILE="/tmp/wf-recorder.pid"
RECORDING_FILE="/tmp/current_recording.txt"
LOG_FILE="/tmp/wf-recorder.log"

# Create recordings directory if it doesn't exist
mkdir -p "$RECORDING_DIR"

# Clean up stale PID file if process is dead
if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    if ! kill -0 "$PID" 2>/dev/null; then
        rm -f "$PID_FILE" "$RECORDING_FILE"
    fi
fi

# Check if already recording
if [ -f "$PID_FILE" ]; then
    # Stop recording
    PID=$(cat "$PID_FILE")
    kill -SIGINT "$PID" 2>/dev/null
    # Wait for wf-recorder to finalize the file
    tail --pid="$PID" -f /dev/null 2>/dev/null
    rm -f "$PID_FILE"

    if [ -f "$RECORDING_FILE" ]; then
        FILENAME=$(cat "$RECORDING_FILE")
        rm "$RECORDING_FILE"
        if [ -f "$FILENAME" ] && [ "$(stat -c%s "$FILENAME")" -gt 1000 ]; then
            SIZE=$(du -h "$FILENAME" | cut -f1)
            notify-send "Screen Recording" "Saved ($SIZE): $FILENAME" -i video-x-generic
        else
            rm -f "$FILENAME"
            notify-send "Screen Recording" "Recording failed - check $LOG_FILE" -i dialog-error
        fi
    fi
    exit 0
fi

# Start recording
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
FILENAME="$RECORDING_DIR/recording_${TIMESTAMP}.mp4"

# Store the filename for later
echo "$FILENAME" > "$RECORDING_FILE"

# Check mode: region or full screen
MODE="${1:-region}"

if [ "$MODE" = "region" ]; then
    GEOMETRY=$(slurp)
    if [ -z "$GEOMETRY" ]; then
        rm "$RECORDING_FILE"
        exit 1
    fi
    notify-send "Screen Recording" "Recording region... Press again to stop" -i video-x-generic
    wf-recorder -g "$GEOMETRY" -c libx264 -p crf=32 -p preset=fast -F "scale=trunc(iw/4)*2:trunc(ih/4)*2,format=yuv420p" -r 24 -f "$FILENAME" > "$LOG_FILE" 2>&1 &
    echo $! > "$PID_FILE"
else
    MONITOR=$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .name')
    notify-send "Screen Recording" "Recording monitor $MONITOR... Press again to stop" -i video-x-generic
    wf-recorder -o "$MONITOR" -c libx264 -p crf=32 -p preset=fast -F "scale=trunc(iw/4)*2:trunc(ih/4)*2,format=yuv420p" -r 24 -f "$FILENAME" > "$LOG_FILE" 2>&1 &
    echo $! > "$PID_FILE"
fi

# Check if wf-recorder actually started
sleep 0.5
if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    if ! kill -0 "$PID" 2>/dev/null; then
        rm -f "$PID_FILE" "$RECORDING_FILE"
        notify-send "Screen Recording" "Failed to start - check $LOG_FILE" -i dialog-error
    fi
fi
