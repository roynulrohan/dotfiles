#!/bin/bash
# plugins/calendar.sh — "Sun 18. Apr" in icon, "13:46" in label.
# Reformat here if you prefer 12h time or US date style.

sketchybar --set "$NAME" icon="$(date '+%a %d. %b')" label="$(date '+%H:%M')"
