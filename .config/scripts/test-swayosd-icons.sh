#!/bin/bash

echo "Testing SwayOSD icons..."
echo "========================"

# Test various icon names
icons=(
    "notifications"
    "notification"
    "dialog-information"
    "dialog-warning"
    "info"
    "audio-volume-high"
    "microphone-sensitivity-high"
    "preferences-system-notifications"
    "bell"
    "alarm"
)

for icon in "${icons[@]}"; do
    echo "Testing icon: $icon"
    swayosd-client --custom-message "Testing: $icon" --custom-icon "$icon"
    sleep 2
done

echo ""
echo "Now let's check what icon themes are available:"
ls -d /usr/share/icons/*/ | xargs -I {} basename {}

echo ""
echo "Checking current icon theme in GTK settings:"
gsettings get org.gnome.desktop.interface icon-theme 2>/dev/null || echo "GTK settings not available"

echo ""
echo "Checking if notifications icons exist in common locations:"
for theme in Papirus Adwaita breeze hicolor; do
    echo "Theme: $theme"
    find /usr/share/icons/$theme -name "*notification*" -type f 2>/dev/null | head -3
    echo "---"
done