#!/bin/bash
# plugins/space.sh — Runs when a space item receives an event.
# Called with env vars set by sketchybar:
#   $NAME     = item name, e.g. "space.3"
#   $SID      = space number (because we set `associated_space=$sid`)
#   $SELECTED = "true" if this is the currently focused space
#   $SENDER   = event name ("mouse.clicked", "space_change", etc.)
#   $BUTTON   = mouse button for mouse.clicked ("left", "right")

update() {
  # Animate: when a space is focused, hide its app-icon strip (width=0);
  # otherwise let the strip expand naturally (width=dynamic).
  WIDTH="dynamic"
  if [ "$SELECTED" = "true" ]; then
    WIDTH="0"
  fi

  sketchybar --animate tanh 20 --set "$NAME" icon.highlight=$SELECTED label.width=$WIDTH
}

mouse_clicked() {
  if [ "$BUTTON" = "right" ]; then
    # Right-click → destroy the space.
    yabai -m space --destroy $SID
    sketchybar --trigger space_change --trigger windows_on_spaces
  else
    # Left-click → focus the space. The `2>/dev/null` swallows the error
    # that yabai emits if the space is already focused.
    yabai -m space --focus $SID 2>/dev/null
  fi
}

case "$SENDER" in
  "mouse.clicked") mouse_clicked ;;
  *) update ;;
esac
