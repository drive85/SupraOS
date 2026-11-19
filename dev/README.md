# dev/ — opencode + SupraOS development environment

Everything needed to keep working on SupraOS from any PC, truly one-shot:

```sh
git clone https://github.com/drive85/SupraOS.git && cd SupraOS
./dev/setup-dev.sh        # link skill + backups, check opencode
opencode                  # restart it so the skill loads
```

## What is in here

- `setup-dev.sh` — one-shot, idempotent, non-destructive env setup. Links the
  skill into `~/.config/opencode/skill/supraos-dev` and the backups into
  `~/opencode/build-backups` (symlinks into this repo, so live edits and new
  backups land in the repo and travel with the next push). Anything already
  at a live path is moved to `env-backup-<timestamp>/`, never deleted.
- `skill/supraos-dev/SKILL.md` — the opencode skill that enforces the SupraOS
  working rules: Omarchy/upstream research-first, minimal code, automated
  backups before touching working elements, repo hygiene.
- `build-backups/` — pre-modification snapshots of live configs, each with a
  `restore.sh` to roll back. Naming: `<element>-<timestamp>` (snapshot before
  changes) and `<element>-good-<timestamp>` (approved known-good state).
- `wifi-app/` — source and `build.sh` for the bar's wifi popup (GTK3 +
  gtk-layer-shell). Build deps are one-time: `su -c
  ~/.local/bin/supra-dev-deps.sh` (script ships in the payload), then
  `./dev/wifi-app/build.sh` installs the binary into `~/.local/bin`.
- `lock-app/` — patched gtklock 4.0.0 + static gtk-session-lock, with both
  upstream tarballs vendored (GPL compliance for the payload binary). `./build.sh`
  installs `~/.local/bin/supra-lock`. The patch adds hold-to-reveal eye and
  click-away hide; look lives in `~/.config/gtklock/`.
- `opencode.jsonc` — global opencode config (currently just `$schema`).

## Conventions

- Work happens from `~/` on any PC: clone the repo to `~/SupraOS`, run
  `dev/setup-dev.sh` once, and you are exactly where the last session left.
- New backups and skill edits live in the repo automatically (symlinks); commit
  and push at the end of a session to save them for the next machine.
- `NOTES.md` (repo root) is the running session log and decision history.
