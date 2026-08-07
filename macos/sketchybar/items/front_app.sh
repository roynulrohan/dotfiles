#!/bin/bash
# items/front_app.sh — Two items:
#   1) `yabai`     — colored icon indicating focused-window state (tiled/
#                    floating/fullscreen-zoom/parent-zoom/stacked).
#   2) `front_app` — name of the currently focused app.

# The front_app item's script just echoes the app name into its label when
# the front_app_switched event fires. sketchybar passes the app name in $INFO.
FRONT_APP_SCRIPT='sketchybar --set $NAME label="$INFO"'

yabai=(
  script="$PLUGIN_DIR/yabai.sh"
  icon.font="$FONT:Bold:16.0"
  label.drawing=off
  icon.width=30
  icon=$YABAI_GRID
  icon.color=$ORANGE
  associated_display=active
)

front_app=(
  script="$FRONT_APP_SCRIPT"
  icon.drawing=off
  padding_left=0
  label.color=$WHITE
  label.font="$FONT:Black:12.0"
  associated_display=active
)

# The events here are custom — they're triggered from yabairc signals:
#   window_focused    → sketchybar --trigger window_focus
#   window_created    → sketchybar --trigger windows_on_spaces
#   window_destroyed  → sketchybar --trigger windows_on_spaces
sketchybar --add event window_focus            \
           --add event windows_on_spaces       \
           --add item yabai left               \
           --set yabai "${yabai[@]}"           \
           --subscribe yabai window_focus      \
                             windows_on_spaces \
                             mouse.clicked     \
                                               \
           --add item front_app left           \
           --set front_app "${front_app[@]}"   \
           --subscribe front_app front_app_switched
