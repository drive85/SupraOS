# supra-lock

The SupraOS lockscreen: [gtklock](https://github.com/jovanlanik/gtklock) 4.0.0
(GPL-3.0) on top of [gtk-session-lock](https://github.com/Cu3PO42/gtk-session-lock)
(GPL-3.0), statically linked, with a small patch. Both upstream release/snapshot
tarballs are vendored in `upstream/` so the binary in the bootstrap payload has
its complete corresponding source next to it.

Why gtklock instead of swaylock: swaylock only draws its ring indicator. We
wanted Omarchy's look — pure black, a box that appears when you start typing,
password dots, and an eye you hold to reveal the password. gtklock uses
`ext-session-lock-v1`, so the lock is as real as swaylock's (no dismissable
overlay), and its entry already renders dots.

`supra-lock.patch` changes:

- eye icon is press-and-hold: press shows the password, release hides it
  (upstream toggles on click).
- clicking anywhere else in the lock window hides the password again.
- "Password:" label and Unlock button removed (Enter submits, like Omarchy).
- `_DEFAULT_SOURCE` so musl exposes `kill()`, and `export_dynamic` so GtkBuilder
  can resolve the new signal handlers.

Look and behavior live in `~/.config/gtklock/config.ini` and `style.css`
(both in the bootstrap payload): black background, DejaVu Sans Mono, 2px square
border, `start-hidden` so the box only shows while typing, 15s idle hide.

Build: `./build.sh` (installs to `~/.local/bin/supra-lock`). The PAM service
file `/etc/pam.d/gtklock` is created by `supra-bootstrap.sh`:

```
auth required pam_unix.so
account required pam_unix.so
```
