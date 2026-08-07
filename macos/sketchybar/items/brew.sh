#!/bin/bash
# items/brew.sh — Shows the count of outdated Homebrew packages. Icon tint
# indicates severity (green ✓ if up-to-date, white/yellow/orange/red as count grows).
#
# Updates:
#   1) Every hour (update_freq=3600) so the number stays fresh on its own.
#   2) Instantly on the `brew_update` event, which you can optionally trigger
#      from your zshrc by wrapping `brew`:
#        function brew() {
#          command brew "$@"
#          if [[ $* =~ "upgrade|update|outdated" ]]; then
#            sketchybar --trigger brew_update
#          fi
#        }

brew=(
  icon=􀐛
  label=?
  padding_right=10
  update_freq=3600
  script="$PLUGIN_DIR/brew.sh"
)

sketchybar --add event brew_update \
           --add item brew right   \
           --set brew "${brew[@]}" \
           --subscribe brew brew_update
