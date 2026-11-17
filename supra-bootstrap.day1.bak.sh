#!/bin/sh
set -e
TARGET_USER="$USER"
su -c "
  sed -i 's/^#\(.*community\)/\1/' /etc/apk/repositories
  apk update
  apk add adwaita-icon-theme alpine-base alsa-ucm-conf bash brightnessctl busybox-mdev-openrc dbus doas dosfstools e2fsprogs elogind eudev firefox font-awesome font-dejavu foot fuzzel gdk-pixbuf git grim grub-efi gtk+3.0 gvfs iw keyd linux-firmware linux-firmware-i915 linux-firmware-intel linux-firmware-mediatek linux-firmware-other linux-firmware-rtl_bt linux-lts mesa-dri-gallium openssh openssl pcmanfm polkit-elogind seatd seatd-openrc slurp sway udev-init-scripts udev-init-scripts-openrc waybar wireless-regdb wl-clipboard wpa_supplicant 
  mkdir -p /etc/keyd
  cat << 'KEYD' > /etc/keyd/default.conf
KEYD
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
14zHVFJJJZV9yb/HrHuFAJYBAA==
ARCHIVE
chmod +x ~/.local/bin/* 2>/dev/null || true
echo "supraOS restored! Reboot or log out and back in."
