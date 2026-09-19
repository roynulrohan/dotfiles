#!/usr/bin/env bash
# mac/wm/macos-settings.sh: macOS settings the AeroSpace + SketchyBar setup relies on.
# Idempotent, safe to re-run. Log out and back in afterwards so the menu bar and
# Spaces settings fully apply.
set -euo pipefail

# Stage Manager off: it repositions windows on its own, which fights any tiler.
defaults write com.apple.WindowManager GloballyEnabled -bool false

# Hide the macOS menu bar; SketchyBar replaces it (SketchyBar setup docs). It still
# slides down at the top edge, which is where wifi, volume and battery live.
defaults write NSGlobalDomain _HIHideMenuBar -bool true

# "Displays have separate Spaces" ON (spans-displays = false). SketchyBar's setup docs
# require it. The AeroSpace guide prefers it off; this setup runs fine with it on.
defaults write com.apple.spaces spans-displays -bool false

# Ctrl+Cmd drag anywhere on a window moves it (AeroSpace goodies).
defaults write -g NSWindowShouldDragOnGesture -bool true

# Faster native window resize animation.
defaults write -g NSWindowResizeTime -float 0.05

# No Mission Control animation.
defaults write com.apple.dock expose-animation-duration -float 0

killall Dock SystemUIServer 2>/dev/null || true
echo "applied; log out and back in for the menu bar and Spaces settings"
