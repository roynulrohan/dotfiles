#!/bin/bash
# items/battery.sh — Battery icon, only drawn when % is below 60 or we're on AC
# (the plugin script decides drawing on/off). Updates every 120s and on
# power-source change + system wake.

battery=(
  script="$PLUGIN_DIR/battery.sh"
  icon.font="$FONT:Regular:19.0"
  padding_right=5
  padding_left=0
  label.drawing=off
  update_freq=120
  updates=on
)

sketchybar --add item battery right      \
           --set battery "${battery[@]}" \
           --subscribe battery power_source_change system_woke
