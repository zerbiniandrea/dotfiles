#!/bin/bash

# Toggle every USB webcam on/off at the kernel-driver level.
# Unbinds/binds each uvcvideo USB interface via sysfs.
# Apps using the camera see it "disconnect" but are not killed.
# Requires the udev rule at ~/.config/udev/rules.d/99-uvcvideo-toggle.rules
# to give the `video` group write access to the bind/unbind handles.

driver=/sys/bus/usb/drivers/uvcvideo
state_file=/tmp/webcam-toggle.state

fail() {
    notify-send -u critical "Webcam" "$1"
    exit 1
}

if ! [ -d "$driver" ]; then
    fail "uvcvideo driver not loaded"
fi

if ! [ -w "$driver/bind" ] || ! [ -w "$driver/unbind" ]; then
    fail "No write access to $driver/{bind,unbind}. Install ~/dotfiles/.config/udev/rules.d/99-uvcvideo-toggle.rules then: sudo udevadm control --reload && sudo udevadm trigger --subsystem-match=usb --action=add"
fi

write_sysfs() {
    printf '%s' "$2" | tee "$1" >/dev/null 2>&1
}

shopt -s nullglob
bound=("$driver"/*-*)
shopt -u nullglob

if [ ${#bound[@]} -gt 0 ]; then
    : > "$state_file"
    for path in "${bound[@]}"; do
        id=$(basename "$path")
        printf '%s\n' "$id" >> "$state_file"
        # uvcvideo may auto-unbind sibling interfaces; skip if already gone.
        [ ! -e "$driver/$id" ] && continue
        if ! write_sysfs "$driver/unbind" "$id"; then
            rm -f "$state_file"
            fail "Failed to unbind $id (kernel rejected write)"
        fi
    done
    notify-send "Webcam" "Disabled (privacy mode on)"
else
    if [ -s "$state_file" ]; then
        while read -r id; do
            [ -z "$id" ] && continue
            # uvcvideo may auto-bind sibling interfaces; skip if already bound.
            [ -e "$driver/$id" ] && continue
            write_sysfs "$driver/bind" "$id" || fail "Failed to rebind $id"
        done < "$state_file"
        rm -f "$state_file"
        notify-send "Webcam" "Re-enabled"
    else
        notify-send "Webcam" "No previously-disabled camera to restore"
    fi
fi

pkill -RTMIN+11 waybar
