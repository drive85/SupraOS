#!/bin/sh
# restores this waybar snapshot over the live config
d="$(cd "$(dirname "$0")" && pwd)"
cp "$d/config" "$d/style.css" ~/.config/waybar/
pkill waybar 2>/dev/null; sleep 0.5; (waybar &) 2>/dev/null
echo "waybar restored from $d"
