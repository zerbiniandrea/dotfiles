#!/bin/bash

# VPN indicator for the wayle bar (indicator only; use nmcli to connect).
# Prints wayle custom-module JSON when a NetworkManager connection of type
# vpn or wireguard is active. Prints nothing otherwise, which hides the
# module (hide-if-empty).

name=$(nmcli -t -f NAME,TYPE connection show --active 2>/dev/null |
    awk -F: '$2 == "vpn" || $2 == "wireguard" { print $1; exit }')

[ -n "$name" ] && printf '{"tooltip": "VPN on: %s"}\n' "$name"
