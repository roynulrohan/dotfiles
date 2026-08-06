#!/usr/bin/env bash
# Health check for the symlinks, plus recovery when something replaced one.
#
#   ./sync.sh           report only — never writes
#   ./sync.sh --adopt   for any link that got replaced by a real file, copy that
#                       file back into the repo and restore the symlink
#
# Why --adopt exists: apps that save config by writing a temp file and renaming
# it over the target (Claude Code can do this to settings.json) leave a regular
# file where the symlink used to be. The edit is real and worth keeping — this
# pulls it into the repo instead of throwing it away.
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DOTFILES/lib/links.sh"

ADOPT=0
[ "${1:-}" = "--adopt" ] && ADOPT=1

say() { printf '%s\n' "$*"; }
problems=0
adopted=0

for entry in "${LINKS[@]}"; do
  src="$DOTFILES/${entry%%::*}"
  dst="${entry##*::}"

  if [ ! -e "$dst" ] && [ ! -L "$dst" ]; then
    say "  GONE     $dst"
    say "           not installed — run ./install.sh"
    problems=$((problems + 1))
  elif [ -L "$dst" ]; then
    target="$(readlink "$dst")"
    if [ "$target" = "$src" ]; then
      say "  ok       $dst"
    else
      say "  WRONG    $dst"
      say "           points at $target"
      problems=$((problems + 1))
    fi
  else
    # Real file/dir where a symlink belongs — the link got clobbered.
    say "  DETACHED $dst"
    problems=$((problems + 1))
    if [ "$ADOPT" = 1 ]; then
      rm -rf "$src"
      cp -R "$dst" "$src"
      rm -rf "$dst"
      ln -s "$src" "$dst"
      say "           adopted into repo and relinked"
      adopted=$((adopted + 1))
    else
      say "           re-run with --adopt to pull it into the repo and relink"
    fi
  fi
done

say ""
if [ "$problems" = 0 ]; then
  say "all links healthy."
else
  say "$problems issue(s); $adopted adopted."
fi

# Uncommitted repo changes are normal here — you edit config, the repo sees it.
if git -C "$DOTFILES" rev-parse --git-dir >/dev/null 2>&1; then
  if [ -n "$(git -C "$DOTFILES" status --porcelain)" ]; then
    say ""
    say "uncommitted changes in $DOTFILES:"
    git -C "$DOTFILES" status --short
  fi
fi
