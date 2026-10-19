#!/bin/bash
# plugins/aerospace.sh: the chevron before the app name. Its colour shows the
# focused window's state: tiled, floating, fullscreen, accordion. Click toggles
# floating.

source "$HOME/.config/sketchybar/colors.sh"
source "$HOME/.config/sketchybar/icons.sh"
AEROSPACE=/opt/homebrew/bin/aerospace

window_state() {
  read -r fullscreen layout <<< "$($AEROSPACE list-windows --focused --format '%{window-is-fullscreen} %{window-parent-container-layout}' 2>/dev/null)"
  case "$fullscreen:$layout" in
    true:*)        sketchybar --set "$NAME" icon.color=$GREEN ;;
    *:floating)    sketchybar --set "$NAME" icon.color=$MAGENTA ;;
    *:*accordion*) sketchybar --set "$NAME" icon.color=$RED ;;
    *)             sketchybar --set "$NAME" icon.color=$BLUE ;;
  esac
}

case "$SENDER" in
  mouse.clicked) $AEROSPACE layout floating tiling; window_state ;;
  *)             window_state ;;
esac
