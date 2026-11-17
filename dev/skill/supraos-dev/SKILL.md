---
name: supraos-dev
description: Use ONLY when developing or debugging SupraOS — its waybar/sway/foot/fuzzel configs, supra-* scripts in ~/.local/bin, supra-bootstrap.sh, the ~/SupraOS repo, or any Wi-Fi/battery/menu/desktop feature on this Alpine machine. Enforces Omarchy/upstream research-first, minimal code, and mandatory automated backups before touching working configs.
---

# SupraOS development rules

SupraOS is the user's personal Alpine Linux mod (Omarchy-inspired) on weak
hardware (Dell Chromebook 12, 2-core Celeron, 4 GB RAM, Sway + waybar).
`~/SupraOS/AGENTS.md` and `NOTES.md` are the source of truth for environment
facts and past decisions — read them before acting. Apply every rule below on
every SupraOS task.

## 1. Research first — never reinvent the wheel

Before writing any functionality, look at how it is already solved:

- **Omarchy is the reference project.** Check the official Omarchy repo and
  docs (github.com/omacom_io/omarchy, omarchy.org) for how it implements the
  same desktop element (bar modules, menus, installers, defaults). Copy its
  approach/code freely and credit it — SupraOS is an Omarchy-inspired mod, not
  a competitor. If Omarchy does it with an existing tool, prefer that tool.
- **Upstream docs of the actual package beat memory and guesses.** Waybar,
  sway, wlroots/layer-shell, foot, fuzzel, wpa_supplicant: check the official
  man pages, wiki, and source for the EXACT installed version. Verify
  capabilities on-device before trusting docs:
  `waybar --version`, `zcat /usr/share/man/man5/<page>.5.gz`,
  `strings /usr/bin/<bin> | grep <feature>` (e.g. proved waybar menu support),
  or fetch the source at the matching release tag.
- If a feature exists natively in an installed tool (e.g. waybar menus,
  drawers), use it before considering scripts, popups, or new packages.
- Reject heavy ecosystems (Rust/Python/GTK4 widget frameworks, NetworkManager
  stacks) unless nothing lighter works: this machine is musl/Alpine on a
  Celeron.

## 2. Minimal always

- Smallest change that solves the stated problem: minimal code, minimal
  interface, minimal config, minimal dependencies. No features, options, help
  text, or polish beyond what the user asked for.
- Shell scripts: POSIX sh for BusyBox ash. No bashisms, no GNU-only flags.
  One script per job, few lines each, comments only when non-obvious.
- Do not add packages unless the feature truly requires one; if adding one,
  keep `/etc/apk/world` in sync with the `apk add` list in supra-bootstrap.sh.
- Prefer deleting over fixing when a mechanism fights the user (several
  scrapped experiments in NOTES.md won by being removed).

## 3. Non-destructive: automated backup BEFORE touching working elements

Any time you modify a working element — waybar/sway/foot/fuzzel/gtk configs,
supra-* scripts, waybar restarts during experiments, supra-bootstrap.sh —
FIRST make an automated timestamped backup. Never skip this, even for "small"
edits:

```sh
TS=$(date +%Y%m%d-%H%M%S)
B=~/opencode/build-backups/<component>-$TS   # e.g. waybar-20261117-070546
mkdir -p "$B"
cp <every file you are about to touch, plus its related scripts> "$B"/
printf '#!/bin/sh\ncp <files> <original paths> && <reload command>\n' > "$B/restore.sh"
chmod +x "$B/restore.sh"
```

- Backup live files, not intended changes. Include companion scripts
  (e.g. supra-wifi-* with waybar config) so restore.sh actually restores a
  working state.
- After the change: verify alive (e.g. `pgrep waybar`, no errors in log,
  script syntax `sh -n`, sample script output). If it is broken and the user
  wants it back, restore from the newest known-good backup — keep
  `-good-<ts>` snapshots whenever the user approves a state.
- Experiments the user rejects get deleted, not left in place.

## 4. Repo hygiene

- Git identity is `drive85 <drive85@users.noreply.github.com>` — the user's
  real name must appear nowhere in commits, files, or docs.
- Never commit or push unless the user explicitly says so; pushes happen with
  the one-shot token URL at the end of a session.
- Any change to a config captured in supra-bootstrap.sh's embedded tarball
  requires refreshing the payload (stage live files → `tar -czf - . | base64`
  → splice between the ARCHIVE markers → extract-and-diff roundtrip check).
  Include `~/.local/bin/supra-*` scripts in the staging tree.
- Record non-obvious decisions and scrapped approaches in `~/SupraOS/NOTES.md`
  so the next session does not repeat them.
