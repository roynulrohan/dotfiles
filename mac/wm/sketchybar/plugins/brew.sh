#!/bin/bash
{ echo "=== $(date +%H:%M:%S) ==="; HOMEBREW_NO_AUTO_UPDATE=1 HOMEBREW_DOWNLOAD_CONCURRENCY=1 /opt/homebrew/bin/brew outdated --quiet 2>&1; echo exit=$?; } >> /tmp/brew-debug.log
# plugins/brew.sh — Counts outdated Homebrew packages and sets the item label
# + icon color based on the count. The ✓ glyph (􀆅) replaces the number when
# everything's up to date.

source "$HOME/.config/sketchybar/colors.sh"

# sketchybar runs plugins with a minimal PATH — fall back to the canonical
# Homebrew binary location on Apple Silicon.
BREW_BIN="$(command -v brew || echo /opt/homebrew/bin/brew)"

# HOMEBREW_NO_AUTO_UPDATE=1 avoids the auto-update path that can trip a
# Hardware::CPU.cores bug in certain Homebrew versions when run from a
# non-terminal subprocess. --quiet suppresses harmless progress chatter.
COUNT=$(HOMEBREW_NO_AUTO_UPDATE=1 "$BREW_BIN" outdated --quiet 2>/dev/null | wc -l | tr -d ' ')

COLOR=$RED
case "$COUNT" in
  [3-5][0-9]) COLOR=$ORANGE ;;
  [1-2][0-9]) COLOR=$YELLOW ;;
  [1-9])      COLOR=$WHITE ;;
  0)          COLOR=$GREEN; COUNT=􀆅 ;;
esac

sketchybar --set "$NAME" label="$COUNT" icon.color=$COLOR
