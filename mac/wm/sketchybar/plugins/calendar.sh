#!/bin/bash
# plugins/calendar.sh: "Thu 18 Sep" in the icon, "3:42 PM" in the label. No year.
# %l pads the hour with a space, which sed removes.

sketchybar --set "$NAME" icon="$(date '+%a %d %b')" label="$(date '+%l:%M %p' | sed 's/^ //')"
