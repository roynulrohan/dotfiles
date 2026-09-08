#!/bin/sh
# ~/.config/yabai/create_spaces.sh
# Ensures every macOS display has exactly DESIRED_SPACES_PER_DISPLAY spaces,
# creating or destroying them as needed. Called from yabairc at startup and
# whenever a display is added/removed.

DESIRED_SPACES_PER_DISPLAY=4
CURRENT_SPACES="$(yabai -m query --displays | jq -r '.[].spaces | @sh')"

DELTA=0
while read -r line
do
  LAST_SPACE="$(echo "${line##* }")"
  LAST_SPACE=$(($LAST_SPACE+$DELTA))
  EXISTING_SPACE_COUNT="$(echo "$line" | wc -w)"
  MISSING_SPACES=$(($DESIRED_SPACES_PER_DISPLAY - $EXISTING_SPACE_COUNT))
  if [ "$MISSING_SPACES" -gt 0 ]; then
    # Too few spaces on this display — create more.
    for i in $(seq 1 $MISSING_SPACES)
    do
      yabai -m space --create "$LAST_SPACE"
      LAST_SPACE=$(($LAST_SPACE+1))
    done
  elif [ "$MISSING_SPACES" -lt 0 ]; then
    # Too many — destroy the extras.
    for i in $(seq 1 $((-$MISSING_SPACES)))
    do
      yabai -m space --destroy "$LAST_SPACE"
      LAST_SPACE=$(($LAST_SPACE-1))
    done
  fi
  DELTA=$(($DELTA+$MISSING_SPACES))
done <<< "$CURRENT_SPACES"

# Let sketchybar refresh now that the space count has changed.
sketchybar --trigger space_change --trigger windows_on_spaces
