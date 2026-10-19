#!/bin/bash
# items/calendar.sh: the day and date in the icon, the time in the label.
# Updates every 30 s. A click opens Calendar.

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
