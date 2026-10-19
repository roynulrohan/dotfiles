#!/bin/bash
# items/brew.sh: the count of outdated Homebrew packages. The icon colour
# follows the count: green with a check mark at 0, white to 9, yellow to 29,
# orange to 59, red above (plugins/brew.sh).
# It updates every hour (update_freq=3600) and on the `brew_update` event.
# Nothing in this repo sends that event. Run `sketchybar --trigger brew_update`
# to refresh the count at once.

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
