#!/bin/sh
cp config style.css ~/.config/waybar/ && cp supra-* ~/.local/bin/ && chmod +x ~/.local/bin/* && pkill waybar; sleep 1; waybar >/dev/null 2>&1 &
