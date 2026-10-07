# caelestia overrides

Everything of mine on top of [caelestia dots](https://github.com/caelestia-dots/caelestia).
Only the override layer is here; caelestia's own tree (`~/.config/hypr`,
`~/.config/fish`, the shell) is installed and updated by `caelestia` and is
**never committed**.

## Files

| Repo | Destination | What |
|---|---|---|
| `hypr-vars.lua` | `~/.config/caelestia/hypr-vars.lua` | kitty as terminal; single-window outer gap matched to HyprMod's `gaps_out` |
| `hypr-user.lua` | `~/.config/caelestia/hypr-user.lua` | Super+Shift+arrow resize binds, `emulate_discrete_scroll = 0`, window mode (below); Hyprland config that HyprMod can't express goes here |
| `shell.json` | `~/.config/caelestia/shell.json` | bar: numbered workspaces, 5 shown; dashboard and sidebar on |
| `user-config.fish` | `~/.config/caelestia/user-config.fish` | empty on purpose; fish config lives in `shared/fish` |

## Window mode

`hypr-user.lua` defines a Hyprland submap for moving and placing the active
window from the keyboard. It's Lua functions, which HyprMod can't express.
**Super+A** enters it; Esc, Enter or Super+A leave. Other keys do nothing
inside it.

| Key | Floating window | Tiled window |
|---|---|---|
| Arrows | Move 40 px | Move within the layout |
| Alt+arrows | Move 5 px | Move within the layout |
| Shift+←/→ | Right edge in / out, 30 px | Resize |
| Shift+↑/↓ | Bottom edge up / down, 30 px | Resize |
| Ctrl+arrows | Snap to the left / right / top / bottom half | Nothing |
| `f` | Fill the height | Nothing |
| `c` | Centre | Centre |

Floating windows stay inside the usable area of their monitor: caelestia's bar
and frame (the monitor's reserved area) and the 4 px outer gap are excluded,
and a step that would cross an edge stops at it. Hyprland resizes a floating
window around its centre, so the edge keys move it back by half the change.

## Install

Follow caelestia's installer first (it also installs Hyprland, fish, foot,
fastfetch, starship, the Nerd Font). Then copy these four files in and run
`hyprctl reload`. The shell picks up `shell.json` live; restart it with
Ctrl + Super + Alt + R if the bar doesn't change.

The installer asks which components to set up. Pick these:

hypr, fish, foot, fastfetch, btop, micro, thunar, starship, firefox, gtk, qt,
auth, network, bluetooth, pipewire, clipboard, fonts, tools, spotify, vscode,
zed, nvim, discord, uwsm, zen

The first CachyOS install also enabled `todoist`, but it isn't used: skip it.
caelestia's Super+R (the todo special workspace) then opens an empty scratchpad.
caelestia records the components it set up in
`~/.local/state/caelestia/dots-state.json` (`enabled_components`).

AUR helper chosen in the installer: `paru`.

## Things to know

- Load order: caelestia base → `hyprland/*.lua` → `hypr-user.lua` → HyprMod's
  `hyprland-gui.lua`. Later wins, but a duplicate bind fires twice; overriding a
  caelestia bind needs an `unbind` first (see `linux/hyprmod`).
- caelestia sets terminal colours 0–18 from the wallpaper via
  `~/.local/state/caelestia/sequences.txt`; the prompt and greeting rely on that.
- `singleWindowGapsOut` in `hypr-vars.lua` must track HyprMod's outer gap by hand.
- Wallpapers: `~/Pictures/Wallpapers`. If the folder is created after the shell
  starts, restart the shell once so the picker sees it.
