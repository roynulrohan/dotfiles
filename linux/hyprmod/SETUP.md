# HyprMod

[HyprMod](https://github.com/bluemancz/hyprmod) is a GUI for Hyprland binds,
monitors, workspace and window rules. It owns `~/.config/hypr/hyprland-gui.lua`,
which caelestia loads last, so everything in it overrides caelestia.

## Files

| Repo | Destination |
|---|---|
| `hyprland-gui.lua` | `~/.config/hypr/hyprland-gui.lua` |

## Install

`paru -S hyprmod`. Copy the file in **while HyprMod is closed**, then open HyprMod
and confirm the Keybinds and Window rules pages list everything. HyprMod
regenerates the whole file on save, so only edit it by hand when HyprMod is
closed, and keep its exact `hl.bind` / `hl.window_rule` shape.

## What's in it

- **Monitors**: DP-2 left, DP-1 middle 280 Hz, HDMI-A-1 right.
  Machine-specific; redo on different hardware. No workspace rules: each
  monitor has its own workspaces, set up in `linux/caelestia/hypr-user.lua`
  (see "Per-monitor workspaces" in `linux/caelestia/SETUP.md`). Don't add
  workspace keys or rules in HyprMod: its file loads last and would override them.
- **HyDE-style keybinds on caelestia**: Super+Shift+arrows resize (in
  `linux/caelestia/hypr-user.lua`: HyprMod can't convert repeating resize
  binds), Ctrl+Super+Shift+arrows move window, Super+W float,
  Super+G group, Super+J toggle split, Super+Shift+J swap split, Super+P /
  Super+Ctrl+P / Super+Shift+P screenshot / freeze / colour picker,
  Super+Shift+F pin, F10–F12 volume. Super+B opens Zen.
- **Unbinds** of the caelestia binds those replace. The `unbind` text must match
  caelestia's spelling exactly, including modifier order and key capitalisation
  (`CTRL + SUPER + SHIFT + Left`), or both binds stay live.
- **Window rules**: forced opaque so caelestia's default window opacity doesn't
  apply: kitty, Zen (`zen`), Discord (`discord`), Jellyfin
  (`org.jellyfin.JellyfinDesktop`), the file explorers Dolphin
  (`org.kde.dolphin`) and Thunar (`[Tt]hunar`), and the viewers Gwenview
  (`org.kde.gwenview`), Haruna (`org.kde.haruna`) and mpv (`mpv`). caelestia's own rules already keep
  `imv` and `feh` opaque. Orca (`orca`) is left at caelestia's 95% on purpose:
  its own window is never transparent, so that's the only see-through it gets.
- **Settings**: dwindle, flat mouse accel, gaps 2 / 4. Border size is left at
  caelestia's 1 px. Tearing is allowed: `allow_tearing` is only Hyprland's master
  switch; caelestia's `immediate` rule limits it to games (Steam, Lutris,
  gamescope), and only while one is fullscreen and alone on its monitor.
  `resize_on_border`: drag a window edge to resize (a side edge changes one
  dimension only). `snap:enabled`: floating windows dragged with the mouse snap
  to screen edges and other windows within 10 px.
  `follow_mouse = 2`: hovering a window gives it mouse focus; keyboard focus
  moves only on click.

## Gotcha

HyprMod loads its file through two lines it appends to caelestia's
`~/.config/hypr/hyprland.lua`:

```lua
-- HyprMod managed settings
require("hyprland-gui")
```

A caelestia update that rewrites `hyprland.lua` drops them, and every bind,
rule and setting in `hyprland-gui.lua` stops applying. Open HyprMod once: it
checks for the line at startup and adds it back. Or add the two lines by hand
and run `hyprctl reload`.

### A replugged monitor lands on the far right

Seen once after DP-2 was unplugged for a while: the live `hyprland-gui.lua` had
lost DP-2's `hl.monitor` block, most likely because HyprMod saved the file while
the monitor was disconnected. Plugged back in, Hyprland put it to the right of
the others at its default refresh rate. The repo copy still has every monitor,
so restore it, then restart the live wallpapers, which only cover monitors that
were connected when they started:

```bash
cp ~/Coding/dotfiles/linux/hyprmod/hyprland-gui.lua ~/.config/hypr/
~/.local/bin/live-wallpaper
```

Check `diff` first if HyprMod changed anything else since the last commit.
