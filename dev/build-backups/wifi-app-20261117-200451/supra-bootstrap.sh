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
