#!/bin/bash
# items/spaces.sh — One indicator per yabai space (1..N). Each space shows
# its number + glyphs of the apps running in it (from sketchybar-app-font).
# Left-click focuses, right-click destroys, and clicking the > separator creates a new space.

# Define up to 15 spaces' icon digits. yabai actually only creates 4 per display
# (see ~/.config/yabai/create_spaces.sh), but listing extras is harmless.
SPACE_ICONS=("1" "2" "3" "4" "5" "6" "7" "8" "9" "10" "11" "12" "13" "14" "15")

sid=0
for i in "${!SPACE_ICONS[@]}"
do
  sid=$(($i+1))

  space=(
    associated_space=$sid
    icon=${SPACE_ICONS[i]}
    icon.padding_left=10
    icon.padding_right=15
    padding_left=2
    padding_right=2
    label.padding_right=20
    icon.highlight_color=$RED
    # The "sketchybar-app-font" renders :ableton:, :ghostty: etc. as app glyphs.
    label.font="sketchybar-app-font:Regular:16.0"
    label.background.height=26
    label.background.drawing=on
    label.background.color=$BACKGROUND_2
    label.background.corner_radius=8
    label.drawing=off
    script="$PLUGIN_DIR/space.sh"
  )

  sketchybar --add space space.$sid left    \
             --set space.$sid "${space[@]}" \
             --subscribe space.$sid mouse.clicked
done

# Wraps all space items in a single rounded pill.
spaces=(
  background.color=$BACKGROUND_1
  background.border_color=$BACKGROUND_2
  background.border_width=2
  background.drawing=on
)

# The ">" separator: click creates a new yabai space.
separator=(
  icon=􀆊
  icon.font="$FONT:Heavy:16.0"
  padding_left=15
  padding_right=15
  label.drawing=off
  associated_display=active
  click_script='yabai -m space --create && sketchybar --trigger space_change'
  icon.color=$WHITE
)

sketchybar --add bracket spaces '/space\..*/' \
           --set spaces "${spaces[@]}"        \
                                              \
           --add item separator left          \
           --set separator "${separator[@]}"
