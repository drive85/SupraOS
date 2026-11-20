#!/bin/sh
# Install build dependencies for dev/wifi-app and dev/lock-app.
# Run as root:  su -c ./dev/deps.sh
set -e
apk add gcc musl-dev pkgconf meson ninja glib-dev gtk+3.0-dev \
  gtk-layer-shell-dev wayland-dev wayland-protocols linux-pam-dev
