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

- **Monitors and workspaces**: DP-2 left (ws 1), DP-1 middle 280 Hz (ws 2),
  HDMI-A-1 right (ws 3). Machine-specific; redo on different hardware.
- **HyDE-style keybinds on caelestia**: Super+Shift+N move window to workspace,
  Super+Shift+arrows resize (in `linux/caelestia/hypr-user.lua`: HyprMod can't
  convert repeating resize binds), Ctrl+Super+Shift+arrows move window, Super+Ctrl+Alt+←/→
  move to relative workspace, Super+Ctrl+↓ empty workspace, Super+W float,
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
  (`org.kde.gwenview`), Haruna (`org.kde.haruna`) and mpv (`mpv`). caelestia's
  own rules already keep `imv` and `feh` opaque.
- **Settings**: dwindle, no tearing, flat mouse accel, gaps 2 / 4.
  `resize_on_border`: drag a window edge to resize (a side edge changes one
  dimension only). `snap:enabled`: floating windows dragged with the mouse snap
  to screen edges and other windows within 10 px.
  `follow_mouse = 2`: hovering a window gives it mouse focus; keyboard focus
  moves only on click.
