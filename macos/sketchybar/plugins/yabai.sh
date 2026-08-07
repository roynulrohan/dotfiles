#!/bin/bash
# plugins/yabai.sh — Handles two custom events triggered from ~/.config/yabai/yabairc:
#   window_focus       → updates the yabai state icon (grid/float/fullscreen/stack)
#   windows_on_spaces  → repaints each space indicator with glyphs for running apps
# Also handles mouse.clicked on the yabai item (left-click toggles float on
# the focused window).

# Source icon_map.sh once so we can call __icon_map() as a function rather
# than spawning a subshell per app. (Upstream version called it as a CLI — the
# newer sketchybar-app-font ships a function-only icon_map, so we adapt here.)
source "$HOME/.config/sketchybar/plugins/icon_map.sh"

window_state() {
  source "$HOME/.config/sketchybar/colors.sh"
  source "$HOME/.config/sketchybar/icons.sh"

  WINDOW=$(yabai -m query --windows --window)
  CURRENT=$(echo "$WINDOW" | jq '.["stack-index"]')

  args=()
  if [[ $CURRENT -gt 0 ]]; then
    # Current window is inside a stack → show [n/total].
    LAST=$(yabai -m query --windows --window stack.last | jq '.["stack-index"]')
    args+=(--set "$NAME" icon=$YABAI_STACK icon.color=$RED label.drawing=on label=$(printf "[%s/%s]" "$CURRENT" "$LAST"))
    # Note: original sets window_border color here, but yabai v7 removed borders.
    # JankyBorders handles its own colors — no-op this line.

  else
    args+=(--set "$NAME" label.drawing=off)
    case "$(echo "$WINDOW" | jq '.["is-floating"]')" in
      "false")
        if [ "$(echo "$WINDOW" | jq '.["has-fullscreen-zoom"]')" = "true" ]; then
          args+=(--set "$NAME" icon=$YABAI_FULLSCREEN_ZOOM icon.color=$GREEN)
        elif [ "$(echo "$WINDOW" | jq '.["has-parent-zoom"]')" = "true" ]; then
          args+=(--set "$NAME" icon=$YABAI_PARENT_ZOOM icon.color=$BLUE)
        else
          args+=(--set "$NAME" icon=$YABAI_GRID icon.color=$ORANGE)
        fi
        ;;
      "true")
        args+=(--set "$NAME" icon=$YABAI_FLOAT icon.color=$MAGENTA)
        ;;
    esac
  fi

  sketchybar -m "${args[@]}"
}

windows_on_spaces() {
  # For each display's list of spaces, paint the space indicator's label
  # with a strip of app-font glyphs representing the apps running there.
  CURRENT_SPACES="$(yabai -m query --displays | jq -r '.[].spaces | @sh')"

  args=()
  while read -r line
  do
    for space in $line
    do
      icon_strip=" "
      apps=$(yabai -m query --windows --space "$space" | jq -r ".[].app")
      if [ -n "$apps" ]; then
        while IFS= read -r app; do
          __icon_map "$app"   # sets global $icon_result
          icon_strip+=" $icon_result"
        done <<< "$apps"
      fi
      args+=(--set space.$space label="$icon_strip" label.drawing=on)
    done
  done <<< "$CURRENT_SPACES"

  sketchybar -m "${args[@]}"
}

mouse_clicked() {
  yabai -m window --toggle float
  window_state
}

case "$SENDER" in
  "mouse.clicked")       mouse_clicked ;;
  "forced")              exit 0 ;;
  "window_focus")        window_state ;;
  "windows_on_spaces")   windows_on_spaces ;;
esac
