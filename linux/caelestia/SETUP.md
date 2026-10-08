# caelestia overrides

Everything of mine on top of [caelestia dots](https://github.com/caelestia-dots/caelestia).
Only the override layer is here; caelestia's own tree (`~/.config/hypr`,
`~/.config/fish`, the shell) is installed and updated by `caelestia` and is
**never committed**.

## Files

| Repo | Destination | What |
|---|---|---|
| `hypr-vars.lua` | `~/.config/caelestia/hypr-vars.lua` | kitty as terminal; single-window outer gap matched to HyprMod's `gaps_out` |
| `hypr-user.lua` | `~/.config/caelestia/hypr-user.lua` | Super+Shift+arrow resize binds, `emulate_discrete_scroll = 0`, window mode and per-monitor workspaces (below), and loading `hypr-local.lua` if the machine has one; Hyprland config that HyprMod can't express goes here |
| `shell.json` | `~/.config/caelestia/shell.json` | bar: numbered workspaces, 5 shown; dashboard and sidebar on; weather for Ottawa (coordinates: the IP lookup said Toronto, and the name "Ottawa" also matches US towns); logout button runs `uwsm stop` (see `linux/sddm/SETUP.md`, frozen screen); no notifications on the lock screen (`lock.hideNotifs`); the lock screen shows the wallpaper, not a blurred screenshot of the desktop (`lock.useWallpaper`: after waking from sleep the blur once failed and the desktop showed sharp behind the lock). Idle (`general.idle.timeouts`): lock after 1 h, screens off after 1.5 h, `systemctl suspend` after 4 h. caelestia's default `suspendThenHibernate` can't work here (zram swap only, so logind reports `CanSuspendThenHibernate=na`) and failed silently. Audio playing (`general.idle.inhibitWhenAudio`, default on) and Keep awake (an idle inhibitor; every step respects it) pause all three. Launcher actions (`launcher.actions`, typed after `>`): caelestia's defaults plus Restart shell, Reload Hyprland, Restart wallpapers and Night light off/on; Sleep runs `systemctl suspend` instead of the impossible `suspendThenHibernate`. The list replaces caelestia's whole default list, so it repeats the defaults; commands run directly, through `sh -c` when they need a shell. The lock screen's media controls have no setting |
| `user-config.fish` | `~/.config/caelestia/user-config.fish` | runs after caelestia's `config.fish`: resets its wallpaper colours in Orca's terminal; other fish config lives in `shared/fish` |
| `cli.json` | `~/.config/caelestia/cli.json` | Super+D (the communication special workspace) starts and gathers Equibop instead of the official Discord |

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

## Per-monitor workspaces

Each monitor has its own workspaces 1–10 on Super+1…0, like awesome/dwm.
[split-monitor-workspaces](https://github.com/zjeffer/split-monitor-workspaces)
does it: a Lua package for Hyprland 0.55 or newer (its rival hyprsplit doesn't
work with Lua configs). It isn't copied into this repo. Install it pinned to the
reviewed commit:

```bash
git clone https://github.com/zjeffer/split-monitor-workspaces.git \
    ~/.local/share/hypr-plugins/split-monitor-workspaces
git -C ~/.local/share/hypr-plugins/split-monitor-workspaces checkout f26d624
```

`hypr-user.lua` requires it by its full name: its modules are called
`globals`, `helpers` and `monitors`, and caelestia requires its own modules by
bare names too. If the package is missing, caelestia's global workspace keys stay
and Super+Shift+N does nothing. HyprMod reads the whole config by running it and parsing
stdout, so the package's `print()` at setup broke HyprMod (it wouldn't open);
`hypr-user.lua` sends those lines to stderr during setup. Check with
`python3 -c 'import hyprland_config, pathlib; hyprland_config.load_any(pathlib.Path.home() / ".config/hypr/hyprland.lua")'`.

Ranges: main DP-1 gets Hyprland ids 1–10, right HDMI-A-1 11–20, left DP-2
21–30 (`monitor_priority`). caelestia's bar labels workspaces by id, so the side
monitors show 11–20 and 21–30. All 30 workspaces are persistent (the package's
default), so Hyprland's own workspace rules pin each one to its monitor. With
persistence off, every config reload made the package create a missing
workspace on whichever monitor had focus and then move it, and Hyprland handed
the robbed monitor a fallback workspace; on 2026-10-07 that left workspaces and
their windows on the wrong monitor.

| Key | Does |
|---|---|
| Super+1…0 | go to workspace N on the focused monitor |
| Super+Shift+1…0 / Super+Alt+1…0 | move the window there and follow / stay |
| Super+scroll, Super+PgUp/PgDn, Ctrl+Super+←/→ | cycle workspaces on this monitor |
| Super+Alt+scroll, Super+Alt+PgUp/PgDn, Super+Ctrl+Alt+←/→ | move the window to the next/previous workspace on this monitor |
| Super+Ctrl+↓ | first empty workspace on this monitor |
| Super+[ / Super+] | focus the left / right monitor |
| Super+Shift+[ / Super+Shift+] | send the window to the left / right monitor |

caelestia's "groups of 10" (Ctrl+Super+N, Ctrl+Super+scroll,
Ctrl+Super+Alt+N) are unbound. Super+Alt+arrows stays caelestia's 10 px
resize. Ctrl+Super+Shift+arrows (move in a direction) carries a tiled window
across monitors at the edge, but a floating window only slides to its own
monitor's edge (Hyprland's floating layout, `moveTargetInDirection`); use
Super+Shift+[ / ] for those.

## Machine-local config

If `~/.config/caelestia/hypr-local.lua` exists, `hypr-user.lua` loads it after
everything above. It holds config that stays on one machine and out of this
repo. A load error shows as a Hyprland notification instead of failing quietly.

## Install

Follow caelestia's installer first (it also installs Hyprland, fish, foot,
fastfetch, starship, the Nerd Font). Then copy the files above in and run
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

Colour scheme: `dynamic`, which takes its colours from the current wallpaper,
dark mode, `tonalspot` variant. Set it after installing:

```fish
caelestia scheme set -n dynamic -f hard -m dark -v tonalspot
```

The wallpapers themselves aren't in this repo; they live in
`~/Pictures/Wallpapers` on the CachyOS desktop.

## Things to know

- Load order: caelestia base → `hyprland/*.lua` → `hypr-user.lua` → HyprMod's
  `hyprland-gui.lua`. Later wins, but a duplicate bind fires twice; overriding a
  caelestia bind needs an `unbind` first (see `linux/hyprmod`).
- caelestia sets terminal colours 0–18 from the wallpaper via
  `~/.local/state/caelestia/sequences.txt`; the prompt and greeting rely on that.
- `singleWindowGapsOut` in `hypr-vars.lua` must track HyprMod's outer gap by hand.
- Wallpapers: `~/Pictures/Wallpapers`. If the folder is created after the shell
  starts, restart the shell once so the picker sees it.
