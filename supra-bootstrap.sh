#!/bin/sh
set -e
TARGET_USER="${USER:-$(id -un)}"

printf "Install Firefox browser? [Y/n] "
read FIREFOX_ANS
case "$FIREFOX_ANS" in n*|N*) FIREFOX_PKG="" ;; *) FIREFOX_PKG="firefox" ;; esac
printf "Install OpenCode AI CLI? [y/N] "
read OPENCODE_ANS
case "$OPENCODE_ANS" in y*|Y*) OPENCODE_WANT=1 ;; *) OPENCODE_WANT=0 ;; esac
su -c "
  sed -i 's/^#\(.*community\)/\1/' /etc/apk/repositories
  apk update
  apk add adwaita-icon-theme alpine-base alsa-ucm-conf alsa-utils bash brightnessctl busybox-mdev-openrc dbus doas dosfstools e2fsprogs elogind eudev $FIREFOX_PKG font-awesome font-dejavu foot fuzzel gdk-pixbuf git grim grub-efi gtk+3.0 gvfs iw keyd linux-firmware linux-firmware-i915 linux-firmware-intel linux-firmware-mediatek linux-firmware-other linux-firmware-rtl_bt linux-lts mesa-dri-gallium openssh openssl pcmanfm pipewire pipewire-alsa pipewire-pulse polkit-elogind seatd seatd-openrc slurp sway swayidle swaylock udev-init-scripts udev-init-scripts-openrc waybar wireless-regdb wireplumber wl-clipboard wpa_supplicant 
  mkdir -p /etc/keyd
  cat << 'KEYD' > /etc/keyd/cros.conf
[ids]
k:18d1:5050
k:0000:0000
k:18d1:503c
k:18d1:5030
k:18d1:503d
k:18d1:5057
k:18d1:502b
k:18d1:504c
k:18d1:5052
k:18d1:5044
k:18d1:5061
k:18d1:505b
k:0001:0001
k:0000:0001

[main]
f1 = back
f2 = forward
f3 = refresh
f4 = f11
f5 = scale
f6 = brightnessdown
f7 = brightnessup
f8 = mute
f9 = volumedown
f10 = volumeup

back = back
forward = forward
refresh = refresh
zoom = f11
scale = scale
brightnessdown = brightnessdown
brightnessup = brightnessup
mute = mute
volumedown = volumedown
volumeup = volumeup
power = f13

f13=coffee
sleep=coffee

[meta]
f1 = f1
f2 = f2
f3 = f3
f4 = f4
f5 = f5
f6 = f6
f7 = f7
f8 = f8
f9 = f9
f10 = f10

back = f1
forward = f2
refresh = f3
zoom = f4
scale = f5
brightnessdown = f6
brightnessup = f7
mute = f8
volumedown = f9
volumeup = f10


[alt]
backspace = delete
brightnessdown = kbdillumdown
brightnessup = kbdillumup
f6 = kbdillumdown
f7 = kbdillumup

[control]
f5 = sysrq
scale = sysrq

[altgr]
backspace = delete
left = home
right = end
up = pageup
down = pagedown

[control+alt]
backspace = C-A-delete
f1 = C-A-f1
f2 = C-A-f2
f3 = C-A-f3
f4 = C-A-f4
f5 = C-A-f5
f6 = C-A-f6
f7 = C-A-f7
f8 = C-A-f8
f9 = C-A-f9
f10 = C-A-f10
back = C-A-f1
forward = C-A-f2
refresh = C-A-f3
zoom = C-A-f4
scale = C-A-f5
brightnessdown = C-A-f6
brightnessup = C-A-f7
mute = C-A-f8
volumedown = C-A-f9
volumeup = C-A-f10
KEYD
  C=/etc/wpa_supplicant/wpa_supplicant.conf
  mkdir -p /etc/wpa_supplicant
  [ -f \"\$C\" ] || touch \"\$C\"
  grep -q '^ctrl_interface=' \"\$C\" || printf 'ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=wheel\n' >> \"\$C\"
  grep -q '^update_config=' \"\$C\" || printf 'update_config=1\n' >> \"\$C\"
  chmod 660 \"\$C\"
  cat << 'SA' > /usr/local/bin/supra-session-action
#!/bin/sh
# SupraOS: fixed, whitelisted root actions for the power menu (called via doas nopass).
case \"\$1\" in
  suspend) exec sh -c 'echo mem > /sys/power/state' ;;
  reboot) exec reboot ;;
  poweroff) exec poweroff ;;
  *) echo \"usage: \$0 suspend|reboot|poweroff\" >&2; exit 2 ;;
esac
SA
  chmod 755 /usr/local/bin/supra-session-action
  printf 'permit nopass %s cmd /usr/local/bin/supra-session-action\n' \"$TARGET_USER\" > /etc/doas.d/99-supra-session.conf
  sed -i 's/^#\?HandlePowerKey=.*/HandlePowerKey=ignore/; s/^#\?HandleLidSwitch=.*/HandleLidSwitch=ignore/; s/^#\?HandleLidSwitchExternalPower=.*/HandleLidSwitchExternalPower=ignore/' /etc/elogind/logind.conf
  mkdir -p /etc/local.d
  cat << 'BR' > /etc/local.d/brightness.start
#!/bin/sh
# SupraOS: restore last saved screen brightness (saved by the brightness keys)
b=\$(cat /home/$TARGET_USER/.cache/supra-brightness 2>/dev/null) || exit 0
max=\$(brightnessctl max) || exit 0
[ \"\$b\" -gt \"\$max\" ] && b=\$max
brightnessctl set \"\$b\" >/dev/null
BR
  chmod +x /etc/local.d/brightness.start
  rc-update add local default 2>/dev/null || true
  rc-update add devfs sysinit 2>/dev/null || true
  rc-update add dmesg sysinit 2>/dev/null || true
  rc-update add udev sysinit 2>/dev/null || true
  rc-update add udev-settle sysinit 2>/dev/null || true
  rc-update add udev-trigger sysinit 2>/dev/null || true
  rc-update add bootmisc boot 2>/dev/null || true
  rc-update add hostname boot 2>/dev/null || true
  rc-update add hwclock boot 2>/dev/null || true
  rc-update add modules boot 2>/dev/null || true
  rc-update add networking boot 2>/dev/null || true
  rc-update add seedrng boot 2>/dev/null || true
  rc-update add swap boot 2>/dev/null || true
  rc-update add sysctl boot 2>/dev/null || true
  rc-update add syslog boot 2>/dev/null || true
  rc-update add wpa_supplicant boot 2>/dev/null || true
  rc-update add acpid default 2>/dev/null || true
  rc-update add cgroups default 2>/dev/null || true
  rc-update add crond default 2>/dev/null || true
  rc-update add dbus default 2>/dev/null || true
  rc-update add keyd default 2>/dev/null || true
  rc-update add ntpd default 2>/dev/null || true
  rc-update add seatd default 2>/dev/null || true
  rc-update add sshd default 2>/dev/null || true
  rc-update add udev-postmount default 2>/dev/null || true
  addgroup $TARGET_USER seat 2>/dev/null || true
  addgroup $TARGET_USER video 2>/dev/null || true
  addgroup $TARGET_USER input 2>/dev/null || true
  addgroup $TARGET_USER audio 2>/dev/null || true
"
base64 -d << 'ARCHIVE' | tar -xzf - -C ~/ 
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
ARCHIVE
chmod +x ~/.local/bin/* 2>/dev/null || true
if [ "$OPENCODE_WANT" = 1 ]; then
  echo "Installing OpenCode..."
  su -c "apk add curl" || echo "warning: could not install curl"
  if curl -fsSL https://opencode.ai/install | bash; then
    if [ ! -x "$HOME/.local/bin/opencode" ] && [ -x "$HOME/.opencode/bin/opencode" ]; then
      mkdir -p "$HOME/.local/bin"
      ln -sf "$HOME/.opencode/bin/opencode" "$HOME/.local/bin/opencode"
    fi
  else
    echo "warning: opencode install failed"
  fi
fi
echo "supraOS restored! Reboot or log out and back in."
