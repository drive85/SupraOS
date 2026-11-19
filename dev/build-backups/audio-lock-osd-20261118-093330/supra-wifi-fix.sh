#!/bin/sh
# one-time root setup: let the wheel group talk to wpa_supplicant
# (needed by ~/.local/bin/supra-wifi-picker). run as:  su -c ~/supra-wifi-fix.sh
C=/etc/wpa_supplicant/wpa_supplicant.conf
[ -f "$C" ] || { mkdir -p /etc/wpa_supplicant; touch "$C"; }
if ! grep -q '^ctrl_interface=' "$C"; then
  tmp=$(mktemp)
  { echo 'ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=wheel'
    echo 'update_config=1'
    grep -vE '^(ctrl_interface|update_config)=' "$C"
  } > "$tmp" && cat "$tmp" > "$C" && rm -f "$tmp"
fi
chmod 660 "$C"
rc-service wpa_supplicant restart
echo "Wi-Fi control socket ready. Click the Wi-Fi text on the bar to pick a network."
