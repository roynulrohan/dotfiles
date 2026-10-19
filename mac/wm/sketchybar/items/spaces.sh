#!/bin/bash
# items/spaces.sh: one item per AeroSpace workspace (its name and the glyphs of
# its apps), and one invisible observer that repaints all of them in a single batch per
# event. A workspace is shown only while it has windows or focus.
# Events are custom, fired from ~/.config/aerospace/aerospace.toml:
#   aerospace_workspace_change  exec-on-workspace-change, carries FOCUSED_WORKSPACE
#   aerospace_focus_change      on-focus-changed: window opened, closed, moved, focused

AEROSPACE=/opt/homebrew/bin/aerospace

sketchybar --add event aerospace_workspace_change \
           --add event aerospace_focus_change

# Items only. No per-item script: the observer below sets them all at once.
for sid in $($AEROSPACE list-workspaces --all | sort -V); do
  space=(
    icon="$sid"
    icon.padding_left=10
    icon.padding_right=15
    padding_left=2
    padding_right=2
    label.padding_right=20
    icon.highlight_color=$RED
    label.font="sketchybar-app-font:Regular:16.0"
    label.background.height=26
    label.background.drawing=on
    label.background.color=$BACKGROUND_2
    label.background.corner_radius=8
    label.drawing=off
    drawing=off
    click_script="$AEROSPACE workspace $sid"
  )
  sketchybar --add item space.$sid left \
             --set space.$sid "${space[@]}"
done

# Observer. updates=on: hidden items skip scripts otherwise. The bracket regex
# below needs the literal dot, so it does not catch this item.
sketchybar --add item space_observer left                        \
           --set space_observer drawing=off updates=on           \
                 script="$PLUGIN_DIR/spaces.sh"                  \
           --subscribe space_observer aerospace_workspace_change \
                                      aerospace_focus_change

spaces=(
  background.color=$BACKGROUND_1
  background.border_color=$BACKGROUND_2
  background.border_width=2
  background.drawing=on
)
sketchybar --add bracket spaces '/space\..*/' \
           --set spaces "${spaces[@]}"
