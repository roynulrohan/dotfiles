#!/bin/bash
# Regenerates ~/.config/noctalia/lock.toml from gen.py + params.json and restarts
# Noctalia. gen.py also puts a new GIF on the card (reroll.py).
set -e
D=$(dirname "$(readlink -f "$0")")
CFG_DIR=~/.config/noctalia
python3 -I "$D/gen.py" "$D/params.json" "$CFG_DIR/lock.toml"
# Config files merge in name order, and a later file wins key by key. A second
# definition elsewhere would mix with the lock screen or override it.
if other=$(grep -lE '^\[+ *"?(lockscreen|hooks)' "$CFG_DIR"/*.toml | grep -v '/lock\.toml$'); then
    echo "warning: [lockscreen*] or [hooks] also set in: $other"
fi
noctalia config validate 2>&1 | tail -5
# Restart, not config-reload: a reload that changes [lockscreen_widgets] left the
# lock editor empty (Noctalia 5.2.1). A restart reads the config cleanly.
export HYPRLAND_INSTANCE_SIGNATURE=$(ls -t "${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/hypr/" | head -1)
pkill -x noctalia || true; sleep 1.5
# A dying Noctalia can write its in-memory [lockscreen_widgets] back; strip it.
python3 -I "$D/strip.py" ~/.local/state/noctalia/settings.toml
hyprctl dispatch 'hl.dsp.exec_cmd("uwsm app -- noctalia")' >/dev/null
sleep 3; pgrep -x noctalia >/dev/null && echo "noctalia restarted"
