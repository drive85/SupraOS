# SupraOS — Review Notes

Reviewed: Nov 16 2026 (day 1 build, running on Dell Chromebook 12)

## Sway config warning fixed (Nov 18 2026)

- The bar showed "There are errors in your config file": Mod4+l was bound twice.
  The vim focus variables set $right=l, so `$mod+$right focus right` collided
  with the new `$mod+l` lock. `sway -C` does not flag duplicate binds — only the
  runtime reload does. Fix: vim "right" focus moved to `$mod+semicolon`
  (Super+HJ K; on this layout); arrows unchanged. Verified with a bar
  screenshot after `swaymsg reload` (banner gone).

## Lockscreen (Nov 18 2026)

- swaylock was replaced: its only indicator is the ring ("round colored thing"),
  and it cannot draw dots or an eye. New lockscreen = gtklock 4.0.0 +
  gtk-session-lock (static), built from vendored sources in dev/lock-app/ with
  a 3-file patch: eye is press-and-hold (release hides), clicking elsewhere
  hides, "Password:" label and Unlock button removed, musl/-D_DEFAULT_SOURCE
  and export_dynamic fixes. Binary in the payload (stripped, 253K); complete
  sources kept in the repo next to it.
- PAM: /etc/pam.d/gtklock = pam_unix auth+account (Alpine has no base-auth
  stack; swaylock's packaged file pointed at a missing file, so neither locker
  could actually authenticate before this). pam_unix works for a user process
  through setgid unix_chkpwd.
- Config: ~/.config/gtklock/{config.ini,style.css} — black, mono, 2px square
  border, start-hidden + 15s idle hide (box only while typing), clock+date.
- Super+L locks (was Super+Escape). Lid, 10-min idle and before-sleep all call
  supra-lock. swaylock package and pam file removed.
- Testing trick: wtype sends letters fine but its Return never triggers
  GtkEntry::activate here; synthetic /dev/uinput key events (tiny C injector,
  KEY_ENTER=28) do. Useful when a UI needs a "real" key.
- Keyd note: reload does not pick up newly added [ids] devices — the power
  button only started mapping to F13 after `rc-service keyd restart`.

## Power menu, keyd, cleanup (Nov 18 2026)

- Power button on this Chromebook is an ACPI "Power Button" input device
  (LNXPWRBN), not a key on the keyboard matrix. libinput/compositors ignore
  pure power-button devices, elogind only watches it, and Alpine's BusyBox
  acpid listens to the long-gone /proc/acpi/event — so the button did nothing.
  Fix: keyd now owns that device too (`k:0000:0001`) and maps `power = f13`;
  sway binds F13 and XF86PowerOff to `~/.local/bin/supra-power-menu`.
  Long-press still hard-cuts power at the EC level. HandlePowerKey=ignore and
  HandleLidSwitch*=ignore in /etc/elogind/logind.conf so elogind never steals
  the button or fights the lid bind. Lid close locks via `bindswitch lid:on`.
- Power menu (fuzzel dmenu): Lock, Suspend, Logout, Reboot, Shutdown.
  Actions needing root go through /usr/local/bin/supra-session-action (fixed
  whitelist: suspend/reboot/poweroff) with a doas nopass rule. doas quirk:
  rules in /etc/doas.d are evaluated so the *last* matching rule wins, so the
  rule lives in 99-supra-session.conf (20-wheel.conf would otherwise win and
  ask for a password); `doas -n` skips the tty requirement fuzzel can't give.
- Cleanup: "Setup" menu lost its dead Wi-Fi (nmtui) entry; System menu became
  "Power" and launches the power menu; `supra-wifi-fix.sh` deleted — bootstrap
  now sets wpa_supplicant `ctrl_interface=...GROUP=wheel` and `update_config=1`
  itself. Bootstrap also ships the real keyd cros.conf (it used to write an
  empty placeholder) and the session-action helper + doas/logind tweaks.
- keyd is not a placeholder: /etc/keyd/cros.conf remaps the Chromebook top row
  (f6/f7 brightness, f9/f10 volume, f8 mute, f4 f11, etc.) for the internal
  keyboard IDs.
- Brightness keeps landing on 5%: the keys save to ~/.cache/supra-brightness
  on every press, so a held/accidental brightness-down at the top row makes
  the next boot dim too. Reset with brightnessctl set 60% and update the cache.

## Audio, lock/idle, OSD (Nov 18 2026)

- Audio = stock PipeWire + WirePlumber + pipewire-pulse + ALSA utils, same
  stack Omarchy uses (their extra sof-firmware hook is Intel-DSP only; this
  Chromebook is chtmax98090 and already has alsa-ucm-conf). Packages added to
  bootstrap: alsa-utils pipewire pipewire-alsa pipewire-pulse wireplumber.
  Alpine ships no init scripts for these, so sway execs `pipewire`,
  `pipewire-pulse`, `wireplumber` at session start (dbus session already
  running via .profile). Works: one sink "Built-in Audio Speaker", mic source,
  55% default; RTKit warnings are harmless (no rtkit daemon on Alpine).
  Volume keys add `-l 1.0` so they cannot exceed 100%.
- Lock/idle: swaylock (PAM file shipped by the package; `-f -c 000000` black)
  + swayidle: dpms off at 5 min, lock at 10 min, lock before sleep. Bind
  Super+Escape. Verified: dpms off/on via swaymsg, swaylock starts and is
  killable; real lock intentionally not left on during work.
- OSD decision: NO SwayOSD (Omarchy's choice) — Rust + GTK4 + libinput daemon
  is wrong for a 2-core Celeron. Feedback instead comes from waybar's native
  `pulseaudio` and `backlight` modules (event-driven, no extra processes).
  Icons must be written as JSON `\u` escapes: literal Font Awesome PUA
  characters get stripped when the file passes through tooling (silent blank
  icons), so use "\uf026"/"\uf027"/"\uf028" and "\uf185".
- Mako is NOT installed despite older notes; no notification daemon exists.
- Nov 18 2026: machine hit a full-screen red crash (looks like an i915 GPU
  hang — nothing in logs, no OOM). Configs survived; apps and daemons restart
  cleanly. Unknown trigger, watch for repeats.
- Brightness cache can drift to accidental values (found 5%/391): the keys
  save on every press, so a few stray presses make the next boot very dim.
  `brightnessctl set 60% && brightnessctl get > ~/.cache/supra-brightness`
  resets it.

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

8. **USB drive support** — added `exfatprogs` and `ntfs-3g` packages for
   exFAT/NTFS filesystem support, and polkit rule `/etc/polkit-1/localauthority/50-local.d/00-supra-usb.pkla`
   allowing user erick to mount/unmount/eject removable drives via GVFS/udisks2.
   pcmanfm is configured with `mount_removable=1` and `autorun=1`. Volume keys
   and device handling are now functional when a USB drive is connected.

## Key bindings (current)

- Super+Return: foot | Super+Space: fuzzel | Super+W: kill | Super+F: fullscreen
- Super+B: firefox | Super+E: pcmanfm | Super+S/Shift+S: grim+slurp screenshot + wl-copy
- Alt+Tab / Alt+Shift+Tab: focus cycle
- Super+HJ K; / arrows: focus, +Shift: move, Super+V: splitv (right uses ; since Super+L locks)
- Workspaces 1-9, move with Shift
- XF86 keys: volume (wpctl/PipeWire, capped at 100%), brightness (brightnessctl)

## Ideas for later

- Real ANSI colors in foot (see #5) if the flat palette ever bothers you.
- gvfs backends if pcmanfm trash/mounts matter (see #7).

## Maintenance run (Nov 18 2026)

- Removed 129 packages (~548 MiB) of leftovers: build toolchain used to make
  gtklock/wifi-app (gcc, binutils, meson, ninja, pkgconf, musl-dev, glib-dev,
  gtk+3.0-dev, gtk-layer-shell-dev, linux-pam-dev, wayland-dev,
  wayland-protocols and their deps: python3, docbook, libxslt, ...) and the
  `.wtype` test virtual + wtype. Rebuild deps now come from `dev/deps.sh`
  (run as root only when rebuilding, then `apk del` them again).
- But removing those exposed a real bug: gtklock links `libpam.so.0`, which had
  only been installed by swaylock before. `linux-pam` is now in the bootstrap
  apk list.
- Deleted one-shot helpers `~/.local/bin/supra-brightness-fix.sh` (the bootstrap
  already writes /etc/local.d/brightness.start) and `supra-dev-deps.sh`
  (replaced by dev/deps.sh in the repo; it was shipped in the payload).
- acpid: busybox provides `/sbin/acpid` and the service was enabled, so it ran
  and watched the dead /proc/acpi/event. Power goes through keyd → F13 now, so
  the service is off and no longer enabled by the bootstrap.
- Merged the two duplicate `input type:touchpad` blocks in the sway config
  (second one silently won; now one block with tap, dwt, natural_scroll,
  clickfinger).
- Removed the duplicated selector block in waybar style.css.
- gtklock config no longer hardcodes `style=/home/erick/...`; upstream falls
  back to the XDG path `~/.config/gtklock/style.css`.
- Dropped `supra-bootstrap.day1.bak.sh` from the repo (git history keeps it).
