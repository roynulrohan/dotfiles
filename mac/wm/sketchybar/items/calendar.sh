#!/bin/bash
# items/calendar.sh — Day + date in icon, time in label. Updates every 30s.
# (No zen-mode click — his dotfiles had that; we drop it since it referenced
# items we aren't using. Add back later once those items exist.)

calendar=(
  icon=cal
  icon.font="$FONT:Black:12.0"
  icon.padding_right=0
  label.width=45
  label.align=right
  padding_left=15
  update_freq=30
  script="$PLUGIN_DIR/calendar.sh"
  click_script="open -a 'Calendar'"
)

sketchybar --add item calendar right       \
           --set calendar "${calendar[@]}" \
           --subscribe calendar system_woke
