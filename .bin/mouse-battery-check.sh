#!/bin/bash

# Mouse battery check script
# Sends a notification when battery is low.
#
# Reads the level passively from the kernel power_supply class (hid-logitech
# driver) instead of querying the device with `solaar show`. An active
# `solaar show` floods the device with HID++ requests, which disrupts mouse
# input (e.g. the pointer goes wild in games); reading sysfs touches nothing.

THRESHOLD=20
MODEL_MATCH="G502"

battery=""
status=""
fallback_battery=""
fallback_status=""

for dev in /sys/class/power_supply/hidpp_battery_*; do
    [[ -e "$dev/capacity" ]] || continue
    cap=$(<"$dev/capacity")
    stat=$(<"$dev/status")
    model=$(<"$dev/model_name")

    # Remember the first hidpp battery in case nothing matches the model.
    if [[ -z "$fallback_battery" ]]; then
        fallback_battery="$cap"
        fallback_status="$stat"
    fi

    if [[ "$model" == *"$MODEL_MATCH"* ]]; then
        battery="$cap"
        status="$stat"
        break
    fi
done

if [[ -z "$battery" ]]; then
    battery="$fallback_battery"
    status="$fallback_status"
fi

if [[ -z "$battery" ]]; then
    exit 1
fi

# Don't nag while it's charging or topped off.
if [[ "$status" == "Charging" || "$status" == "Full" ]]; then
    exit 0
fi

if [[ "$battery" -le "$THRESHOLD" ]]; then
    notify-send "Mouse Battery Low" "G502 X PLUS battery at ${battery}%"
fi
