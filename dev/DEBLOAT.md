# SupraOS Debloat

Minimal, safe cleanup for Chromebook 12. Use when system feels heavy, after long dev sessions, or when you say "debloat".

## Usage

```sh
~/.local/bin/supra-debloat [system|dev|repo|all]
```

* `system` — apk cache clean, /tmp trim, old logs rotation, journal prune. Requires root via su.
* `dev` — prune `~/opencode/build-backups` older than 7d keeping last 3, clean tmp artifacts, safe user cache prune keeping `supra-*` caches. Backs up caches before wiping.
* `repo` — list large files >50M in `~/SupraOS`, remove .DS_Store/swp/~ junk, git gc.
* `all` — run all three.

Logs go to `/tmp/debloat-YYYYMMDD-HHMMSS.log`.

Backups are created in `~/opencode/build-backups/<component>-<ts>/` before any destructive step.

## Principles

* Zen minimal: never remove essential configs. `system_cleanup` only reports package drift, never auto-removes packages.
* Backups first per SupraOS skill rules.
* Idempotent and safe to run repeatedly.

## Automation

The script can be called manually. If you want automatic debloat after long sessions, add a hook in your workflow.
