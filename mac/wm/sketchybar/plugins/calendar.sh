#!/bin/bash
# plugins/calendar.sh — "Thu 18 Sep" in icon, "23:41" in label. No year.
# Reformat here if you prefer 12h time or US date style.

sketchybar --set "$NAME" icon="$(date '+%a %d %b')" label="$(date '+%H:%M')"
