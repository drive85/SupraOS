# SupraOS — Review Notes

Reviewed: Nov 16 2026 (day 1 build, running on Dell Chromebook 12)

## What it is

Alpine Linux mod inspired by Omarchy, stripped down for low-end hardware.
Single-file bootstrap (`~/supra-bootstrap.sh`): apk install + OpenRC services +
base64 tarball payload that self-extracts desktop configs into `~/`.

## Stack

- Sway (Wayland compositor)
- Waybar (top bar)
- foot (terminal)
- fuzzel (launcher)
- mako (notifications)
- pcmanfm (file manager)
- Firefox
- keyd (key remapping, service enabled)
- OpenRC + seatd + elogind + dbus

## Theme (consistent across everything)

- Background: `#000000`, text: `#e8e6df` (warm off-white), alt: `#1c1c1c`
- Urgent: `#f7768e`
- 2px pixel borders, radius 0, gaps 0, solid color wallpaper
- DejaVu Sans Mono 10 everywhere (foot, fuzzel, mako, waybar, sway)

## Foolproof audit (Nov 16 2026)

Verified:
- `/etc/apk/world` == script's `apk add` list (47 pkgs, zero drift)
- Payload == live home for all tracked files (.config, .profile, desktop entries)
- `TARGET_USER` hardened to `"${USER:-$(id -un)}"`
- Added `.config/opencode/opencode.jsonc` to payload
- sh -n syntax OK, round-trip extraction verified

Decisions applied (Nov 16 2026):
- mako: deleted (never installed; config removed from home + payload)
- Firefox: now an interactive prompt on restore, default Y (`$FIREFOX_PKG` in apk line)
- OpenCode: now an interactive prompt, default N — installs via official
  installer (curl fetched on demand), symlinks into ~/.local/bin

Decided — leave as-is (Nov 16 2026):
- supra-setup menu "Wi-Fi (nmtui)" / "Audio Mixer (alsamixer)": packages not
  installed, menu options fail when clicked — INTENTIONAL for now
- Volume keys bind wpctl but pipewire/wireplumber not installed → dead keys,
  no sound — INTENTIONAL for now

Not restorable by this script (by design / needs separate decision):
- opencode binary (221 MB) — add installer line or re-download manually
- Firefox profile (176 MB) — bookmarks/passwords lost on restore
- Wi-Fi credentials (/etc/wpa_supplicant/wpa_supplicant.conf, root-owned, PSK plaintext)
- nmtui + alsamixer menu entries in supra-setup.desktop: packages not installed,
  so those menu options are dead now AND after restore
- wpctl volume keys: dead until pipewire/wireplumber installed (see TODO #2)
- hostname/timezone/keymap/locale — handled by setup-alpine on target

## Bootstrap payload refresh (Nov 16 2026)

- `~/supra-bootstrap.sh` rebuilt with current configs (was stale: missing
  `.profile` PATH line, `opencode.desktop`, latest waybar/pcmanfm state)
- Dropped from payload: `.local/share/gvfs-metadata/*`, `recently-used.xbel`
  (volatile session state, caused churn every rebuild)
- Day-1 original kept as `~/SupraOS/supra-bootstrap.day1.bak.sh`

## Findings / TODO

1. **Mako never starts** — no `exec mako` in sway config. Notifications silently dropped.
   Fix: add `exec mako` to `~/.config/sway/config`
2. **Volume keys dead** — sway binds `wpctl` but pipewire/wireplumber not installed.
   Fix: add packages `pipewire pipewire-pulse wireplumber`, enable services
   (`rc-update add pipewire default` etc. / socket activation via dbus), or drop binds.
3. **keyd runs with empty config** — bootstrap writes blank `/etc/keyd/default.conf`
   (bootstrap lines 8-10) and starts the service. Disable or fill it.
4. **Duplicate touchpad block in sway config** — lines 20-23 and 106-111 overlap;
   second block wins. Merge into one.
5. **foot palette 100% grayscale** — all ANSI colors mapped to `#e8e6df`, so vim syntax,
   `ls`, diffs, TUIs render flat. Intentional or not? If not, define real colors.
6. Minor: `for_window [class=".*"]` is X11-only (no XWayland apps in use) — harmless.
7. Minor: no file manager daemon / gvfs services enabled — pcmanfm may lack
   trash/mount features without gvfs backends running.

## Key bindings (current)

- Super+Return: foot | Super+Space: fuzzel | Super+W: kill | Super+F: fullscreen
- Super+B: firefox | Super+E: pcmanfm | Super+S/Shift+S: grim+slurp screenshot + wl-copy
- Alt+Tab / Alt+Shift+Tab: focus cycle
- Super+HJKL / arrows: focus, +Shift: move, Super+V: splitv
- Workspaces 1-9, move with Shift
- XF86 keys: volume (wpctl — nonfunctional, see #2), brightness (brightnessctl)

## Ideas for later

- Replace wpctl binds with pamixer or fix pipewire
- Add swaylock/swayidle (nothing locks the screen currently)
- Consider a brightness/volume indicator module in waybar
- Network: wpa_supplicant on boot, but no tray applet — consider nmtui wrapper or
  waybar network click action
- Bootstrap script: could validate that extraction succeeded (currently just `|| true`)
