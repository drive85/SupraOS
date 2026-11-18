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

## Session log — top bar mod (Nov 17 2026)

DONE (live on machine, NOT yet pushed to repo — push at end of session):
- Waybar icons: Font Awesome 7 glyphs on clock/wifi/battery, FA7 added to
  font-family in style.css, monochrome theme kept
- Clock hover: themed calendar tooltip (black box, 2px off-white border),
  CSS margin-top 28px to pop it below the bar
- Battery click: info popup (%, state, V/A/W, AC status, cycle count)
  via ~/.local/bin/supra-battery-info
- Wi-Fi click: network picker via fuzzel + wpa_cli
  (~/.local/bin/supra-wifi-picker): scan, connect to saved, PSK prompt for new,
  open-network support, save_config persistence
- Battery low-battery alert: red text below 25%, blinking below 12% (charging exempt)
- Wi-Fi module rebuilt as custom/wifi (~/.local/bin/supra-wifi-status, 5s poll):
  phone-style signal bars ▂▄▆█ from /proc/net/wireless dBm (-55/-67/-72/-80
  thresholds), dim ghost bars via pango spans, percentage kept, tooltip shows
  essid/ip/dBm, click still opens the picker. Old network module removed.
- Wi-Fi final (reverted after drawer + fzf-popup experiments, both scrapped:
  drawer expanded horizontally off the 1366px screen; fzf popup too buggy):
  hover bars = tooltip list of networks (<tt>, bars glyphs, connected = check,
  scroll = move inverted selection row via ~/.cache/supra-wifi/idx, click =
  supra-wifi-connect (saved=select, new=fuzzel password box, open=NONE),
  right-click = supra-wifi-rescan (cache ~/.cache/supra-wifi/networks, 180s
  auto-refresh). supra-wifi-status/scroll/connect/rescan; picker + row + menu
  deleted. GTK tooltips can't be hovered = hard limit, do not retry.
- State saved locally (Nov 17 2026, approved by user): bootstrap payload
  rebuilt from live home — includes the good wifi flow (waybar config+style)
  AND ~/.local/bin supra-* scripts (wifi-status/scroll/connect/rescan,
  battery-info, wifi-fix.sh) so restores are complete. Roundtrip verified
  (extract == staging). fzf NOT in payload/list (experiment scrapped).
  Known-good snapshot: ~/opencode/build-backups/waybar-good-*. Not committed
  or pushed yet — user said save locally only.
- Dev environment packed into repo under dev/ (Nov 17 2026): setup-dev.sh
  (one-shot idempotent env setup), skill/supraos-dev/SKILL.md (enforces
  Omarchy/upstream research-first, minimal, auto-backup rules), build-backups/
  (all waybar snapshots moved from ~/opencode/build-backups, live path is now
  a symlink into the repo), opencode.jsonc, README.md. Live paths are
  symlinks into the clone so work on any PC = clone + setup-dev.sh.
  supra-bootstrap.day1.bak.sh now tracked. New PC flow: clone, ./dev/setup-dev.sh,
  restart opencode; full desktop restore = ./supra-bootstrap.sh.
- Wi-Fi popup app (Nov 17 2026, chosen over nm-applet/NM stack and over static
  waybar menus): dev/wifi-app/wifi-app.c — GTK3 + gtk-layer-shell layer window
  anchored under the bars top-right (runtime lib already present via waybar;
  one-time build deps via ~/.local/bin/supra-dev-deps.sh). Styled like the clock
  tooltip: black, 2px #e8e6df frame, invert-on-hover rows, 12px mono. Connected
  network pinned first, then strongest-to-weakest. Click/Enter on a row = the
  network's action: connected → info view (ip/freq/signal + back/disconnect),
  saved/open → connect, locked new → inline PSK entry ("Password" placeholder).
  No bottom buttons; ESC closes. Bar module on-click runs supra-wifi-toggle
  (pidfile ~/.cache/supra-wifi/app.pid). Click-outside dismisses: a transparent
  fullscreen TOP-layer backdrop window sits under the popup (OVERLAY layer) and
  quits on any button press — Wayland gives layer surfaces no pointer grab, so
  this is the standard menu trick; the dismiss click is swallowed (menu-like).
  List caps at 8 rows (22px each) and scrolls beyond. Hover cannot open the app: waybar
  custom modules have no on-hover event (checked v0.15.0 binary) — its only
  hover surface was the GTK tooltip, now removed from the status script.
- GTK/layer-shell layout gotchas (Nov 18 2026): a `border` on the `window` CSS
  node is not painted on layer-shell windows — draw it on an inner box (set a
  widget name, style #frame). Layer TOP surfaces are placed inside the top
  layer's exclusive zone in sway, so gtk-layer-shell margin-top stacks on the
  bar height (margin 4 → 4px visual gap under the 30px bar). View switches
  (list/psk/info) need gtk_window_resize(win, 1, 1) or GTK keeps the old
  configure size. GTK3 has no gtk_list_box_append — use insert(..., -1).
- BusyBox pgrep/pkill (Alpine default) match the full argv[0] with -x, so
  `pkill -x supra-wifi-app` never matches — use pidfiles (or plain substring
  pkill, which also matches the invoking shell: avoid). `pkill -ef` kills the
  calling shell too.
- Brightness persistence (Nov 17 2026): brightnessctl's own -s/-r useless here —
  it saves the PREVIOUS state and stores it in /tmp (tmpfs, dies at reboot).
  So: sway brightness binds now append `&& brightnessctl get >
  ~/.cache/supra-brightness` (saves latest absolute level), and
  /etc/local.d/brightness.start (root, one-time install via
  ~/.local/bin/supra-brightness-fix.sh, `rc-update add local default`) restores
  it clamped to max on boot. Also baked into the bootstrap su block
  (TARGET_USER interpolated). Tested: save 60% -> set 10% -> restore = 60%.
- One-time root fix for Wi-Fi picker prepared: ~/.local/bin/supra-wifi-fix.sh
  (adds ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=wheel + update_config=1,
  restarts wpa_supplicant) — user must run `su -c ~/.local/bin/supra-wifi-fix.sh` once
- Clock click terminal popup: implemented, then REMOVED (redundant with hover
  tooltip + buggy) — hover tooltip is the final calendar UX
- Centered-calendar experiment (full-width tooltip clamp + foot popup) REVERTED
  Nov 17: tooltip position is GTK cursor-anchored, not pinnable. Final state =
  themed hover tooltip tight under the bar (no margin), no clock click handler,
  supra-calendar script deleted. Backups: build-backups/waybar-good-20261117-070546
- Backup: ~/opencode/build-backups/waybar-20261117-064751/ (pre-mod config + restore.sh)

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
