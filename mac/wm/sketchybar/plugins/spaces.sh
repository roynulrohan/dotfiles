#!/bin/bash
# plugins/spaces.sh: one pass per event: read AeroSpace twice, then set every
# workspace item in ONE sketchybar call, so the pill re-lays out once instead of
# once per item (the source of the flicker when moving windows between
# workspaces). Written for the system bash 3.2, which has no associative arrays.
#   $FOCUSED_WORKSPACE  set by the aerospace_workspace_change trigger only
# Per item: drawing (only with windows or focus), display
# (the AppKit screen id AeroSpace reports, which matches sketchybar's arrangement
# id here), highlight, and the app glyph strip.

source "$HOME/.config/sketchybar/plugins/icon_map.sh"
AEROSPACE=/opt/homebrew/bin/aerospace

# Coalesce bursts. A move-with-follow fires workspace_change and focus_change back
# to back, and the first paint can catch AeroSpace mid-move; only the last event
# within 80 ms paints.
stamp=/tmp/sketchybar-spaces.stamp
token=$$-$RANDOM
echo "$token" > "$stamp"
sleep 0.08
[ "$(cat "$stamp" 2>/dev/null)" = "$token" ] || exit 0

focused=${FOCUSED_WORKSPACE:-$($AEROSPACE list-workspaces --focused 2>/dev/null)}
windows=$($AEROSPACE list-windows --all --format '%{workspace}|%{app-name}' 2>/dev/null)

args=()
while read -r ws mon; do
  [ -z "$ws" ] && continue
  apps=$(printf '%s\n' "$windows" | awk -F'|' -v w="$ws" '$1 == w { print $2 }' | sort -u)
  strip=""
  if [ -n "$apps" ]; then
    while IFS= read -r app; do
      __icon_map "$app"              # sets $icon_result
      strip+=" $icon_result"
    done <<< "$apps"
  fi
  hl=off; [ "$ws" = "$focused" ] && hl=on
  # A workspace is drawn only while it has windows or focus.
  draw=off; { [ -n "$apps" ] || [ "$ws" = "$focused" ]; } && draw=on
  ld=off; [ -n "$strip" ] && ld=on
  args+=(--set "space.$ws" drawing=$draw display="${mon:-1}" icon.highlight=$hl label="$strip " label.drawing=$ld)
done < <($AEROSPACE list-workspaces --all --format '%{workspace} %{monitor-appkit-nsscreen-screens-id}' 2>/dev/null)

[ ${#args[@]} -gt 0 ] && sketchybar "${args[@]}"
