#!/bin/sh
cp config ~/.config/waybar/ && cp style.css ~/.config/waybar/ && cp supra-wifi-* ~/.local/bin/ && chmod +x ~/.local/bin/* && pkill waybar; sleep 1; waybar >/dev/null 2>&1 &
