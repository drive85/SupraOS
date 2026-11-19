#!/bin/sh
# Build SupraOS lockscreen: gtklock 4.0.0 + gtk-session-lock (static) + our patch.
# Everything builds as the user; only /etc/pam.d/gtklock needs root (bootstrap does it).
# Needs: meson ninja gcc musl-dev pkgconf gtk+3.0-dev gtk-layer-shell-dev
#        wayland-dev wayland-protocols linux-pam-dev glib-dev
set -e
cd "$(dirname "$0")" || exit 1
PREFIX=${PREFIX:-/tmp/supra-lock-prefix}
rm -rf build "$PREFIX"
mkdir -p build
tar -xzf upstream/gtk-session-lock-master.tar.gz -C build
tar -xzf upstream/gtklock-4.0.0.tar.gz -C build
mv build/gtk-session-lock-master build/gsl
mv build/gtklock-4.0.0 build/gtklock
patch -d build/gtklock -p1 -i "$PWD/supra-lock.patch"
meson setup build/gsl-build build/gsl \
  -Dintrospection=false -Dvapi=false -Ddefault_library=static --prefix="$PREFIX" >/dev/null
ninja -C build/gsl-build
ninja -C build/gsl-build install
PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig" \
  meson setup build/gtklock-build build/gtklock --prefix="$PREFIX" >/dev/null
ninja -C build/gtklock-build
strip -s build/gtklock-build/gtklock
install -m 755 build/gtklock-build/gtklock ~/.local/bin/supra-lock
echo "installed ~/.local/bin/supra-lock"
