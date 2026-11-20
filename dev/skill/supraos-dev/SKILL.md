---
name: supraos-dev
description: Use ONLY when developing or debugging SupraOS — its waybar/sway/foot/fuzzel configs, supra-* scripts in ~/.local/bin, supra-bootstrap.sh, the ~/SupraOS repo, or any Wi-Fi/battery/menu/desktop feature on this Alpine machine. Enforces Omarchy/upstream research-first, minimal code, and mandatory automated backups before touching working configs.
---

# SupraOS development rules

SupraOS is personal Alpine Linux mod (Omarchy-inspired) on weak hardware: Dell Chromebook 12, 2-core Celeron, 4 GB RAM, Sway + waybar. Source of truth: `~/SupraOS/AGENTS.md` and `NOTES.md`. Read them before acting.

## 0. Execution style – focus, speed, low tokens

- No overthinking. Stay on task, no rabbit holes, no speculative alternatives unless asked.
- Think precisely, decide boldly. Pick smallest viable solution and execute. Do not wander.
- Work fast, use less tokens: keep outputs concise, avoid repetition, condense explanations, skip verbose intros. Prefer bullet points over prose.
- Research is limited to what's necessary to decide. Verify on-device, then act.

## 1. Research first

- Omarchy reference for functionality/looks only, not tech stack. Copy behaviour/visuals, credit it. Never copy Hyprland/Electron/Rust/GTK4/NetworkManager. Choose smallest working thing; fewer daemons, less memory, faster start.
- Upstream docs beat memory. For waybar/sway/wlroots/foot/fuzzel/wpa_supplicant, check man pages/wiki/source for exact installed version. Verify on-device: `waybar --version`, `zcat /usr/share/man/man5/...`, `strings /usr/bin/... | grep ...`. Use native features before scripts/popups/packages.
- Reject heavy ecosystems unless lighter option impossible.

## 2. Minimal always

- Delete before adding. Every package/daemon/module must earn RAM/startup time. Fast > pretty, working > clever.
- Smallest change that solves problem: minimal code/config/deps. No extra features/options/polish.
- Shell: POSIX sh for BusyBox ash, no bashisms/GNU-only flags. One script per job, few lines, comments only when non-obvious.
- Do not add packages unless required; keep `/etc/apk/world` in sync with `apk add` in supra-bootstrap.sh.
- Prefer deleting over fixing mechanisms that fight user.

## 3. Non-destructive backups

Before touching waybar/sway/foot/fuzzel/gtk configs, supra-* scripts, supra-bootstrap.sh:
```sh
TS=$(date +%Y%m%d-%H%M%S)
B=~/opencode/build-backups/<component>-$TS
mkdir -p "$B"
cp <files+related scripts> "$B"/
printf '#!/bin/sh\ncp <files> <paths> && <reload>\n' > "$B/restore.sh"
chmod +x "$B/restore.sh"
```
Backup live files + companions. After change verify alive: `pgrep`, logs, `sh -n`, sample output. If broken, restore newest known-good backup; keep `-good-<ts>` snapshots on approval. Delete rejected experiments.

## 4. Repo hygiene

- Lockscreen is patched gtklock (`dev/lock-app/` vendored, GPL). Never re-add swaylock; `swaylock` and `supra-wifi-fix.sh` deleted on purpose.
- Git identity: `drive85 <drive85@users.noreply.github.com>`. No real name in commits/files/docs.
- Never commit/push unless explicitly requested; pushes use one-shot token URL.
- Changes to supra-bootstrap.sh embedded tarball require refresh: stage live files → `tar -czf - . | base64` → splice between ARCHIVE markers → extract-and-diff check. Include `~/.local/bin/supra-*`.
- Record non-obvious decisions and scrapped approaches in `~/SupraOS/NOTES.md`.
