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
  apk add adwaita-icon-theme alpine-base alsa-ucm-conf bash brightnessctl busybox-mdev-openrc dbus doas dosfstools e2fsprogs elogind eudev $FIREFOX_PKG font-awesome font-dejavu foot fuzzel gdk-pixbuf git grim grub-efi gtk+3.0 gvfs iw keyd linux-firmware linux-firmware-i915 linux-firmware-intel linux-firmware-mediatek linux-firmware-other linux-firmware-rtl_bt linux-lts mesa-dri-gallium openssh openssl pcmanfm polkit-elogind seatd seatd-openrc slurp sway udev-init-scripts udev-init-scripts-openrc waybar wireless-regdb wl-clipboard wpa_supplicant 
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
