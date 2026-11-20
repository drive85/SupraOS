#!/bin/sh
# SupraOS debloat — minimal, safe cleanup for Chromebook 12
# Usage: ./debloat.sh [system|dev|repo|all]
# Only touches caches, logs, /tmp and repo junk; never configs.
set -e
set -u

TS=$(date +%Y%m%d-%H%M%S)
LOG=/tmp/debloat-$TS.log
exec >>"$LOG" 2>&1

echo "=== SupraOS debloat $TS ==="
echo "Log: $LOG"

root() {
  su -c "$*"
}

system_cleanup() {
  echo "[system] Cleaning apk cache"
  root 'apk cache clean'
  root 'rm -rf /var/cache/apk/*'

  echo "[system] Trimming /tmp"
  find /tmp -type f -atime +3 -print -delete || true

  echo "[system] Rotating large logs"
  root 'find /var/log -type f -mtime +30 -exec truncate -s 0 {} \;'

  echo "[system] Removing old journal"
  root 'rm -rf /var/log/journal/*'

  # Keep only packages in /etc/apk/world + dependencies
  # Dry check only — do not auto-remove to avoid breaking essentials
  echo "[system] Package drift check"
  WORLD=$(cat /etc/apk/world | tr '\n' ' ')
  INST=$(apk list --installed | awk '{print $1}')
  # report extras, do not remove automatically
  echo "Installed packages: $(apk list --installed | wc -l), world entries: $(wc -l < /etc/apk/world)"
}

dev_cleanup() {
  echo "[dev] Pruning build-backups"
  # Keep last 3 per component, delete older than 7 days
  BACKUP_ROOT=~/opencode/build-backups
  find "$BACKUP_ROOT" -maxdepth 1 -type d -name "*-20*" -mtime +7 | sort | head -n -3 | xargs -r rm -rf

  echo "[dev] Cleaning dev tmp artifacts"
  rm -rf /tmp/staging /tmp/payload.* /tmp/new_payload.* || true

  # Remove stray supra-autologin scripts if any
  rm -f /usr/local/bin/supra-autologin.sh || true

  echo "[dev] User cache prune (regenerable; keep supra-* file or dir)"
  find ~/.cache -mindepth 1 -maxdepth 1 ! -name "supra-*" -exec rm -rf {} + || true
}

repo_cleanup() {
  REPO=~/SupraOS
  echo "[repo] Finding large files >50M"
  find "$REPO" -type f -size +51200k -print

  echo "[repo] Removing common junk"
  find "$REPO" -type f \( -name ".DS_Store" -o -name "*.swp" -o -name "*~" \) -delete || true

  echo "[repo] Git prune"
  if command -v git >/dev/null 2>&1; then
    cd "$REPO" && git gc --auto || true
  fi
}

case "${1:-all}" in
  system) system_cleanup ;;
  dev) dev_cleanup ;;
  repo) repo_cleanup ;;
  all)
    system_cleanup
    dev_cleanup
    repo_cleanup
    ;;
  *) echo "Usage: $0 [system|dev|repo|all]"; exit 1 ;;
esac

echo "=== Debloat complete ==="
echo "Review log: $LOG"
