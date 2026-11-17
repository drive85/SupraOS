#!/bin/sh
d="$(cd "$(dirname "$0")" && pwd)"
cp "$d/config" "$d/style.css" ~/.config/waybar/
cp "$d/supra-wifi-status" ~/.local/bin/
pkill waybar 2>/dev/null; sleep 0.5; (waybar &) 2>/dev/null
echo restored
