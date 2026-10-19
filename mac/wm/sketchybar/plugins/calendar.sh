#!/bin/bash
# plugins/calendar.sh: "Thu 18 Sep" in the icon, "23:41" in the label. No year.

sketchybar --set "$NAME" icon="$(date '+%a %d %b')" label="$(date '+%H:%M')"
