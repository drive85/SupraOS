#!/bin/sh
# build + install the wifi popup app (needs: gcc musl-dev pkgconf gtk+3.0-dev gtk-layer-shell-dev)
cd "$(dirname "$0")"
PKGS="gtk+-3.0 gtk-layer-shell-0"
cc $(pkg-config --cflags $PKGS) -O2 -Wall -o supra-wifi-app wifi-app.c $(pkg-config --libs $PKGS) || exit 1
install -m 755 supra-wifi-app ~/.local/bin/
echo "installed ~/.local/bin/supra-wifi-app"
