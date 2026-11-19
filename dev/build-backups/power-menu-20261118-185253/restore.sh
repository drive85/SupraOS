#!/bin/sh
# rollback for power-menu batch
B=$(dirname "$0")
cp "$B/sway-config" ~/.config/sway/config
cp "$B/waybar-config" ~/.config/waybar/config
cp "$B/waybar-style.css" ~/.config/waybar/style.css
cp "$B/supra-wifi-fix.sh" ~/.local/bin/supra-wifi-fix.sh
cp "$B/applications/"*.desktop ~/.local/share/applications/
su -c "cp '$B/doas.conf' /etc/doas.conf; cp '$B/logind.conf' /etc/elogind/logind.conf; rm -f /usr/local/bin/supra-session-action"
swaymsg reload
