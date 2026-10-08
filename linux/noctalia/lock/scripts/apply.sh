#!/bin/bash
# Regenerates ~/.config/noctalia/lock.toml from gen.py + params.json and restarts
# Noctalia. gen.py also puts a new GIF on the card (reroll.py).
set -e
D=$(dirname "$(readlink -f "$0")")
CFG_DIR=~/.config/noctalia
# gen.py writes atomically: Noctalia watches its config directory, and a
# half-written file read by the watcher parses without [lockscreen_widgets]. The
# lock controller then saves an "enabled = false" snapshot to settings.toml,
# which overrides every config file.
python3 -I "$D/gen.py" "$D/params.json" "$CFG_DIR/lock.toml"
# Files merge in name order, table by table, and a later file wins key by key; a
# second definition elsewhere would mix with or override the lock screen.
if other=$(grep -lE '^\[+ *"?(lockscreen|hooks)' "$CFG_DIR"/*.toml | grep -v '/lock\.toml$'); then
    echo "warning: [lockscreen*] or [hooks] also set in: $other"
fi
noctalia config validate 2>&1 | tail -5
# A config-reload that changes [lockscreen_widgets] left the lock editor empty in
# testing (5.2.1), so restart Noctalia instead; it re-reads the config cleanly.
export HYPRLAND_INSTANCE_SIGNATURE=$(ls -t "${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/hypr/" | head -1)
pkill -x noctalia || true; sleep 1.5
# A dying Noctalia can write its in-memory [lockscreen_widgets] back; strip it.
python3 -I "$D/strip.py" ~/.local/state/noctalia/settings.toml
hyprctl dispatch 'hl.dsp.exec_cmd("uwsm app -- noctalia")' >/dev/null
sleep 3; pgrep -x noctalia >/dev/null && echo "noctalia restarted"
