#!/bin/bash
# items/front_app.sh — Two items:
#   1) `aerospace` — a chevron pointing at the app name. Its colour carries the focused
#                    window's state: blue tiled, magenta floating, green
#                    fullscreen, red accordion. Click toggles floating.
#   2) `front_app` — name of the currently focused app.

# front_app_switched is a sketchybar built-in event; the app name arrives in $INFO.
FRONT_APP_SCRIPT='sketchybar --set $NAME label="$INFO"'

aerospace=(
  script="$PLUGIN_DIR/aerospace.sh"
  icon.font="$FONT:Heavy:16.0"
  label.drawing=off
  icon.width=30
  icon=$CHEVRON
  icon.color=$BLUE
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

# The aerospace_* events are declared in items/spaces.sh, which is sourced first.
sketchybar --add item aerospace left                        \
           --set aerospace "${aerospace[@]}"                \
           --subscribe aerospace aerospace_focus_change     \
                                 aerospace_workspace_change \
                                 mouse.clicked              \
                                                            \
           --add item front_app left                        \
           --set front_app "${front_app[@]}"                \
           --subscribe front_app front_app_switched
