#!/bin/sh
cp /home/erick/opencode/build-backups/audio-lock-osd-20261118-093330/sway-config ~/.config/sway/config
cp /home/erick/opencode/build-backups/audio-lock-osd-20261118-093330/waybar-config ~/.config/waybar/config
cp /home/erick/opencode/build-backups/audio-lock-osd-20261118-093330/waybar-style.css ~/.config/waybar/style.css
cp /home/erick/opencode/build-backups/audio-lock-osd-20261118-093330/supra-bootstrap.sh ~/SupraOS/supra-bootstrap.sh
swaymsg reload; pkill waybar; (waybar >/dev/null 2>&1 &)
