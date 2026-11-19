# AGENTS.md — instructions for AI assistants

If you are an LLM (or any automation) helping configure, audit, or run this
project, read this first.

## Tone

- Be friendly, patient, and encouraging. The human here is a hobbyist learning
  by building — not a corporation, not a target for condescension.
- Never be hostile, snarky, or dismissive. Explain trade-offs instead of judging.
- Explain what you are about to run before running it, and confirm before
  anything destructive or system-wide.

## What SupraOS is

SupraOS is a personal Alpine Linux desktop mod inspired by Omarchy, stripped
down for very weak hardware (a Dell Chromebook 12, 2-core Celeron, 4 GB RAM).
The entire OS setup is captured in one POSIX sh script: `supra-bootstrap.sh`.
Running it on a fresh Alpine install restores: packages, OpenRC services, user
groups, and every desktop config file (embedded in the script as a base64 gzip
tarball).

## Environment facts (get these right)

- Shell is BusyBox ash (`/bin/sh`). No bashisms in the script. No GNU flags in
  the commands it uses (BusyBox `diff` has no `-x`, `apk info` has no `-m`).
- Init system is OpenRC, not systemd. Services: `rc-update add <svc> default`,
  `rc-service <svc> start`.
- Root is used via `su -c "..."` with the root password (there is no sudo).
- Package manager is `apk`. The authoritative "what should be installed" list
  is `/etc/apk/world`, and it is kept in sync with the script's `apk add` line.
- Display is Sway on tty1, started from `~/.profile` via `dbus-run-session`.

## How to run the script

1. On a fresh Alpine install, after `setup-alpine`:
   `chmod +x supra-bootstrap.sh && ./supra-bootstrap.sh`
2. It asks two questions (Firefox? default yes. OpenCode? default no), then
   calls `su` once (root password needed), then extracts configs to `~/`.
3. Reboot or log out and back in. Sway starts on tty1.

The script is safe to re-run: every `rc-update`/`addgroup` is `|| true`-guarded
and `apk add` is idempotent. Do NOT run it on non-Alpine systems.

## Editing configs

User-side configs live in `$HOME/.config/`: `sway/`, `waybar/`, `foot/`,
`fuzzel/`, `pcmanfm/`, `libfm/`, `gtk-3.0/`, `xdg-desktop-portal/`,
`environment.d/`, plus `~/.profile` (tty1 sway autostart) and
`~/.local/share/applications/supra-*.desktop` (the fuzzel menu entries).

If you change any of those, refresh the embedded tarball in the script or the
change will be lost on the next restore:

```sh
# rebuild payload from the staged copy, then splice between the
# "base64 -d << 'ARCHIVE'" and "ARCHIVE" markers in supra-bootstrap.sh
tar -C <staging-dir> -czf - . | base64 > payload.b64
```

Deliberately NOT in the tarball (volatile or personal): `~/.config/mozilla`
(Firefox profile), `~/.config/opencode` except `opencode.jsonc`, gvfs metadata,
recent-files. Root-side state (Wi-Fi PSKs, hostname, timezone) is not captured.

## Current state (Nov 2026)

- Audio works: PipeWire/WirePlumber, volume keys via `wpctl` (capped at 100%).
- Wi-Fi is plain `wpa_supplicant` + shell scripts (no NetworkManager).
- keyd owns the Chromebook top row and the ACPI power button (`power = f13`).
- Power button opens `~/.local/bin/supra-power-menu`; lid close locks; elogind
  ignores power/lid (see NOTES.md).
- Lock screen is `~/.local/bin/supra-lock` (patched gtklock 4.0.0), Super+L.
  It needs the runtime package `linux-pam` (in the bootstrap apk list).
- Build toolchain (gcc, meson, ninja, -dev headers) is NOT installed by
  default to keep the PC lean: `su -c ./dev/deps.sh` before rebuilds.
- acpid is not used: the power button goes through keyd, so no acpid service.
- See `NOTES.md` for the full audit history and decisions.

## Roadmap upkeep

- Keep the README.md Roadmap table current: update percentages and add/remove
  features in the same session as the work that changes them.
