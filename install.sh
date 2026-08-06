#!/usr/bin/env bash
# Link this repo's config into place. Safe to re-run.
#
#   ./install.sh            link everything (backs up anything it replaces)
#   ./install.sh --dry-run  show what would change, touch nothing
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DOTFILES/lib/links.sh"

BACKUP_DIR="$DOTFILES/.backups/$(date +%Y%m%d-%H%M%S)"
DRY_RUN=0
[ "${1:-}" = "--dry-run" ] && DRY_RUN=1

say() { printf '%s\n' "$*"; }
run() { [ "$DRY_RUN" = 1 ] && { say "       would: $*"; return 0; }; "$@"; }

link_one() {
  local src="$DOTFILES/$1" dst="$2"

  if [ ! -e "$src" ]; then
    say "  !!   missing in repo: $1"
    return 1
  fi

  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    say "  ok   $dst"
    return 0
  fi

  # Anything real sitting at the destination gets preserved before we clobber it.
  # Mirror the destination path under the backup dir — two tracked files can
  # share a basename (both settings.json), and a flat backup would lose one.
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    local keep="$BACKUP_DIR/${dst#"$HOME"/}"
    say "  bak  $dst -> ${keep#"$DOTFILES"/}"
    run mkdir -p "$(dirname "$keep")"
    run cp -R "$dst" "$keep"
  fi

  run mkdir -p "$(dirname "$dst")"
  run rm -rf "$dst"
  run ln -s "$src" "$dst"
  say "  link $dst"
}

say "dotfiles: $DOTFILES"
say "claude:   $CLAUDE_DIR"
[ "$DRY_RUN" = 1 ] && say "(dry run — nothing will be written)"
say ""

for entry in "${LINKS[@]}"; do
  link_one "${entry%%::*}" "${entry##*::}"
done

chmod +x "$DOTFILES/claude/hooks/rtk-rewrite.sh" 2>/dev/null || true

# Dependencies. Only bun is load-bearing; the rest degrade quietly.
say ""
say "dependencies:"
if command -v bun >/dev/null 2>&1; then
  say "  ok   bun $(bun --version) — statusline + hooks"
else
  say "  MISS bun — statusline and ccstatusline hooks will not run."
  say "       install: curl -fsSL https://bun.sh/install | bash"
fi
command -v jq  >/dev/null 2>&1 && say "  ok   jq"  || say "  --   jq missing — RTK hook no-ops (apt install jq)"
command -v rtk >/dev/null 2>&1 && say "  ok   rtk" || say "  --   rtk missing — RTK hook no-ops (cargo install rtk)"
command -v gh  >/dev/null 2>&1 && say "  ok   gh"  || say "  --   gh missing — git-pr statusline segment stays blank"

say ""
say "done. restart Claude Code to pick up settings.json."
