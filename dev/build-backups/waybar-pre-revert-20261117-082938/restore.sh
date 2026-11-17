#!/bin/sh
cp config style.css ~/.config/waybar/ && pkill waybar; sleep 1; waybar >/dev/null 2>&1 &
