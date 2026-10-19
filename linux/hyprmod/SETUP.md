# HyprMod

[HyprMod](https://github.com/bluemancz/hyprmod) is a GUI for Hyprland binds,
monitors, workspace and window rules. It owns `~/.config/hypr/hyprland-gui.lua`,
which [`linux/hypr/hyprland.lua`](../hypr/hyprland.lua) loads last, so everything
in it wins.

## Files

| Repo | Destination |
|---|---|
| [`hyprland-gui.lua`](hyprland-gui.lua) | `~/.config/hypr/hyprland-gui.lua` |

The rest of `~/.config/hypr` belongs to [`linux/hypr`](../hypr/SETUP.md).

## Install

```bash
paru -S hyprmod              # AUR; pulls in python-hyprland-config
sudo pacman -S hyprpicker    # the colour picker on Super+Shift+P
paru -S zen-browser-bin      # AUR; Super+B opens Zen
```

The window rules name apps from other packages (see Notes). A rule for an app
that isn't installed does nothing.

Copy the file in **while HyprMod is closed**. Then open HyprMod and confirm that
the Keybinds and Window rules pages list everything.

## Notes

### Editing the file

HyprMod regenerates the whole file on save. Edit it by hand only while HyprMod
is closed, and keep its exact `hl.bind` / `hl.window_rule` shape.

### What's in it

- **Monitors**: DP-2 left, DP-1 middle at 280 Hz, HDMI-A-1 right. These are
  specific to the hardware; redo them for other monitors. There are no
  workspace rules: each monitor has its own workspaces, set up in
  [`linux/hypr/hypr-user.lua`](../hypr/hypr-user.lua) (see "Per-monitor
  workspaces" in [`linux/hypr/SETUP.md`](../hypr/SETUP.md)). Don't add workspace
  keys or rules in HyprMod: its file loads last and would override them.
- **Keybinds**, HyDE-style, on top of the binds in
  [`linux/hypr/hyprland/keybinds.lua`](../hypr/hyprland/keybinds.lua):
  Ctrl+Super+Shift+arrows move the window, Super+W float, Super+G group,
  Super+J toggle split, Super+Shift+J swap split, Super+Shift+P colour picker,
  Super+Shift+F pin. Super+B opens Zen. The Super+Shift+arrow resize binds are
  in [`linux/hypr/hypr-user.lua`](../hypr/hypr-user.lua), because they share
  window mode's Lua resize function, which HyprMod can't express.
- **Unbinds** of the binds in
  [`linux/hypr/hyprland/keybinds.lua`](../hypr/hyprland/keybinds.lua) that
  those replace. The `unbind` text must match that file's spelling exactly,
  including modifier order and key capitalisation (`CTRL + SUPER + SHIFT + Left`),
  or both binds stay live.
- **Window rules** force these windows opaque, so the default window
  transparency (`windowOpacity` in
  [`linux/hypr/hypr-vars.lua`](../hypr/hypr-vars.lua)) doesn't apply: kitty,
  the browsers (Zen, Opera GX, Firefox, Brave), Discord, Jellyfin, the file
  explorers (Dolphin, Thunar) and the viewers (Gwenview, Haruna, mpv). The
  rules in [`linux/hypr/hyprland/rules.lua`](../hypr/hyprland/rules.lua)
  already keep `imv` and `feh` opaque. Orca's own window is never
  transparent, so it keeps the default transparency on purpose.
- **Settings**: dwindle, flat mouse acceleration, rounding 12, border 2 px,
  `gaps_in 1` and `gaps_out 4` (see "Look" in
  [`linux/hypr/SETUP.md`](../hypr/SETUP.md)).
  - Tearing is allowed. `allow_tearing` is only Hyprland's master switch: the
    `immediate` rule in
    [`linux/hypr/hyprland/rules.lua`](../hypr/hyprland/rules.lua) limits it to
    games (Steam, Lutris, gamescope), and only while one is fullscreen and alone
    on its monitor.
  - `resize_on_border`: drag a window edge to resize it. A side edge changes
    one dimension only.
  - `snap:enabled`: floating windows dragged with the mouse snap to screen
    edges and other windows within 10 px.
  - `follow_mouse = 2`: hovering a window gives it mouse focus. Keyboard focus
    moves only on click.

### The load lines in hyprland.lua

HyprMod loads its file through two lines at the end of
`~/.config/hypr/hyprland.lua` (in [`linux/hypr`](../hypr/SETUP.md)):

```lua
-- HyprMod managed settings
require("hyprland-gui")
```

If they go missing, every bind, rule and setting in `hyprland-gui.lua` stops
applying. Open HyprMod once: it checks for the line at startup and adds it
back. Or add the two lines by hand and run `hyprctl reload`.

### A replugged monitor lands on the far right

HyprMod can drop a monitor's `hl.monitor` block from the live
`hyprland-gui.lua`, most likely when it saves the file while that monitor is
unplugged. When the monitor comes back, Hyprland puts it to the right of the
others at its default refresh rate. The repo copy has every monitor, so restore
it. Then restart the live wallpapers, which only cover monitors that were
connected when they started:

```bash
# From the repo root. Look at the diff first: if HyprMod changed anything else
# since the last commit, copy that back into the repo instead of overwriting it.
diff linux/hyprmod/hyprland-gui.lua ~/.config/hypr/hyprland-gui.lua
cp linux/hyprmod/hyprland-gui.lua ~/.config/hypr/
~/.local/bin/live-wallpaper
```

## Verify

```bash
./status.sh | grep hyprland-gui                          # ok
grep -A1 'HyprMod managed' ~/.config/hypr/hyprland.lua  # the two load lines (Notes)
python3 -c 'import hyprland_config, pathlib; hyprland_config.load_any(pathlib.Path.home()/".config/hypr/hyprland.lua")'   # prints nothing; creates missing override files, see linux/hypr
hyprctl monitors -j | jq -r 'sort_by(.x)[].name'         # DP-2, DP-1, HDMI-A-1: left to right
```

The `python3` line reads the config the way HyprMod does. It prints nothing
when HyprMod can read the whole config.
