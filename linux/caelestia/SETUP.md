# caelestia overrides

Everything of mine on top of [caelestia dots](https://github.com/caelestia-dots/caelestia).
Only the override layer is here; caelestia's own tree (`~/.config/hypr`,
`~/.config/fish`, the shell) is installed and updated by `caelestia` and is
**never committed**.

## Files

| Repo | Destination | What |
|---|---|---|
| `hypr-vars.lua` | `~/.config/caelestia/hypr-vars.lua` | kitty as terminal; single-window outer gap matched to HyprMod's `gaps_out` |
| `hypr-user.lua` | `~/.config/caelestia/hypr-user.lua` | Super+Shift+arrow resize binds, imv's wheel-zoom scroll factor; Hyprland config that HyprMod can't express goes here |
| `shell.json` | `~/.config/caelestia/shell.json` | bar: numbered workspaces, 5 shown; dashboard and sidebar on |
| `user-config.fish` | `~/.config/caelestia/user-config.fish` | empty on purpose; fish config lives in `shared/fish` |

## Install

Follow caelestia's installer first (it also installs Hyprland, fish, foot,
fastfetch, starship, the Nerd Font). Then copy these four files in and run
`hyprctl reload`. The shell picks up `shell.json` live; restart it with
Ctrl + Super + Alt + R if the bar doesn't change.

## Things to know

- Load order: caelestia base → `hyprland/*.lua` → `hypr-user.lua` → HyprMod's
  `hyprland-gui.lua`. Later wins, but a duplicate bind fires twice; overriding a
  caelestia bind needs an `unbind` first (see `linux/hyprmod`).
- caelestia sets terminal colours 0–18 from the wallpaper via
  `~/.local/state/caelestia/sequences.txt`; the prompt and greeting rely on that.
- `singleWindowGapsOut` in `hypr-vars.lua` must track HyprMod's outer gap by hand.
- Wallpapers: `~/Pictures/Wallpapers`. If the folder is created after the shell
  starts, restart the shell once so the picker sees it.
