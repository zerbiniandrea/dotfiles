#!/bin/bash

# Check if special:games workspace is visible
if hyprctl workspaces | grep -q "special:games"; then
    echo "󰊴"
else
    echo ""
fi