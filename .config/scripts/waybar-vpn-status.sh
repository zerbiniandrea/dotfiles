#!/bin/bash

# Waybar VPN status script
# Shows a shield icon when a VPN is active. Detects:
#   - NetworkManager connections of type `vpn` (OpenVPN, etc.) or `wireguard`
#     (covers `nmcli` wireguard and the ProtonVPN GTK app)
#   - tun*/wg*/proton* interfaces in UP state (covers legacy protonvpn-cli
#     or wg-quick managed outside NetworkManager)

vpn_name=""

if command -v nmcli >/dev/null 2>&1; then
    vpn_name=$(nmcli -t -f NAME,TYPE,STATE connection show --active 2>/dev/null \
        | awk -F: '$2 == "vpn" || $2 == "wireguard" {print $1; exit}')
fi

if [ -z "$vpn_name" ]; then
    vpn_name=$(ip -br link show 2>/dev/null \
        | awk '/^(tun|wg|proton)[A-Za-z0-9_-]* / && /[<,]UP[,>]/ {print $1; exit}')
fi

if [ -n "$vpn_name" ]; then
    printf '{"text": "󰦝", "tooltip": "VPN: %s", "class": "connected"}\n' "$vpn_name"
else
    printf '{"text": "", "tooltip": "", "class": "disconnected"}\n'
fi
