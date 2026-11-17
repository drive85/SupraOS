#!/bin/sh
# SupraOS dev environment: one-shot setup after cloning this repo on a new PC.
# Links the opencode skill and the build-backups area into their live paths so
# that working on this machine IS working on the repo. Idempotent and
# non-destructive: anything already at a live path is preserved, never deleted.
set -e
R="$(cd "$(dirname "$0")/.." && pwd)"
TS=$(date +%Y%m%d-%H%M%S)
BK="$R/dev/env-backup-$TS"

link() {
  tgt="$1"; dst="$2"
  if [ -L "$dst" ]; then
    echo "ok    $dst (already linked)"
  elif [ -e "$dst" ]; then
    mkdir -p "$BK"
    mv "$dst" "$BK/$(basename "$dst")"
    mkdir -p "$(dirname "$dst")"
    ln -s "$tgt" "$dst"
    echo "moved old file to $BK and linked $dst -> $tgt"
  else
    mkdir -p "$(dirname "$dst")"
    ln -s "$tgt" "$dst"
    echo "link  $dst -> $tgt"
  fi
}

if command -v opencode >/dev/null 2>&1; then
  echo "ok    opencode installed ($(opencode --version 2>/dev/null || echo unknown))"
else
  echo "WARN  opencode not found. install it with:"
  echo "      curl -fsSL https://opencode.ai/install | bash"
fi

link "$R/dev/skill/supraos-dev" "$HOME/.config/opencode/skill/supraos-dev"
mkdir -p "$HOME/opencode"
link "$R/dev/build-backups" "$HOME/opencode/build-backups"

echo
echo "dev env ready. restart opencode so the supraos-dev skill loads."
echo "fresh machine, restore the whole desktop: cd $R && ./supra-bootstrap.sh"
