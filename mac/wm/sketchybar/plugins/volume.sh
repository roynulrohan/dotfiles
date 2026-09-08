#!/bin/bash
# plugins/volume.sh — Handles the slider item's events:
#   volume_change → animate slider to new %, then auto-hide after 2s
#   mouse.clicked → clicking a point on the slider sets volume there
#   mouse.entered/exited → show/hide the slider knob

WIDTH=100

volume_change() {
  source "$HOME/.config/sketchybar/icons.sh"
  case $INFO in
    [6-9][0-9]|100) ICON=$VOLUME_100 ;;
    [3-5][0-9])     ICON=$VOLUME_66 ;;
    [1-2][0-9])     ICON=$VOLUME_33 ;;
    [1-9])          ICON=$VOLUME_10 ;;
    0)              ICON=$VOLUME_0 ;;
    *)              ICON=$VOLUME_100 ;;
  esac

  sketchybar --set volume_icon label="$ICON"

  sketchybar --set "$NAME" slider.percentage=$INFO \
             --animate tanh 30 --set "$NAME" slider.width=$WIDTH

  # Auto-hide the slider 2s after the last volume change.
  sleep 2
  FINAL_PERCENTAGE=$(sketchybar --query "$NAME" | jq -r ".slider.percentage")
  if [ "$FINAL_PERCENTAGE" -eq "$INFO" ]; then
    sketchybar --animate tanh 30 --set "$NAME" slider.width=0
  fi
}

mouse_clicked() {
  osascript -e "set volume output volume $PERCENTAGE"
}

mouse_entered() { sketchybar --set "$NAME" slider.knob.drawing=on ; }
mouse_exited()  { sketchybar --set "$NAME" slider.knob.drawing=off ; }

case "$SENDER" in
  "volume_change")  volume_change ;;
  "mouse.clicked")  mouse_clicked ;;
  "mouse.entered") mouse_entered ;;
  "mouse.exited")   mouse_exited ;;
esac
