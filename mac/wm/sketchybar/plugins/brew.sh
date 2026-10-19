#!/bin/bash
# plugins/brew.sh: counts the outdated Homebrew packages and sets the label and
# the icon colour from the count. At 0, a check mark (􀆅) replaces the number.

source "$HOME/.config/sketchybar/colors.sh"

# SketchyBar runs plugins with a minimal PATH. Fall back to Homebrew's path on
# Apple Silicon.
BREW_BIN="$(command -v brew || echo /opt/homebrew/bin/brew)"

# HOMEBREW_NO_AUTO_UPDATE=1: an auto-update from a background process can fail
# (a Hardware::CPU.cores error in some Homebrew versions). --quiet prints only
# the package names.
COUNT=$(HOMEBREW_NO_AUTO_UPDATE=1 "$BREW_BIN" outdated --quiet 2>/dev/null | wc -l | tr -d ' ')

COLOR=$RED
case "$COUNT" in
  [3-5][0-9]) COLOR=$ORANGE ;;
  [1-2][0-9]) COLOR=$YELLOW ;;
  [1-9])      COLOR=$WHITE ;;
  0)          COLOR=$GREEN; COUNT=􀆅 ;;
esac

sketchybar --set "$NAME" label="$COUNT" icon.color=$COLOR
