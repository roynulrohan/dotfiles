# caelestia's Hyprland config (reference copy)

A copy of the Hyprland config that caelestia's installer wrote to
`~/.config/hypr`, as this setup uses it. **Nothing loads it from here**, and
it isn't in `manifest.tsv`. It exists so the Hyprland setup can be rebuilt
without caelestia, and so the defaults this setup adopted stay on record if
caelestia changes them or goes away.

- Source: [caelestia-dots/caelestia](https://github.com/caelestia-dots/caelestia),
  `hypr/` at revision `1ee7a98` (the `applied_rev` in
  `~/.local/state/caelestia/dots-state.json`). Used with Hyprland 0.56.2,
  caelestia-shell 2.5.0 and caelestia-cli 1.1.3. Copied 2026-10-08. Licence:
  GPL-3.0, caelestia's.
- Identical to upstream except the end of `hyprland.lua`: HyprMod adds the
  lines `-- HyprMod managed settings` and `require("hyprland-gui")`.
- Not copied: `scheme/current.lua` and `scheme/current.conf` (generated from
  the wallpaper, so they change with it), `hyprland-gui.lua` (HyprMod's, in
  `linux/hyprmod`) and `hyprsunset.conf` (in `linux/hyprsunset`).

## How the live setup sits on top

`hyprland.lua` loads, in order: `~/.config/caelestia/hypr-vars.lua` (its
values replace those in `variables.lua`), the `hyprland/*.lua` modules,
`~/.config/caelestia/hypr-user.lua`, and HyprMod's `hyprland-gui.lua`. Later
wins; a bind defined twice fires twice unless unbound first.

| Layer | Repo | Changes to caelestia's defaults |
|---|---|---|
| `hypr-vars.lua` | `linux/caelestia` | kitty as terminal, Dolphin as file manager, VS Code on Super+C, `systemctl suspend` on Super+Shift+L, `breeze_cursors`, single-window gap 4, caelestia's resize keys switched off |
| `hypr-user.lua` | `linux/caelestia` | window mode (Super+A), edge resize on Super+Shift+arrows, per-monitor workspaces (replace caelestia's numbered workspace keys, 4 modifier sets × 10 keys, and its workspace cycling keys), monitor focus keys |
| `hyprland-gui.lua` | `linux/hyprmod` | monitors, rounding 20, gaps, resize on border, snapping, flat mouse acceleration, tearing, opaque window rules; keys: Super+W float, Super+G group, Super+J / Super+Shift+J split, Ctrl+Super+Shift+arrows move window, Super+P screenshot, Super+Shift+F pin, Super+B browser, F10–F12 volume, and more |

## Using it without caelestia

Copy this folder's files to `~/.config/hypr`. Then copy the layers above to
the destinations in `linux/caelestia/SETUP.md` and `linux/hyprmod/SETUP.md`.
What needs attention:

- **Loader paths.** `hyprland.lua` reads `hypr-vars.lua` and `hypr-user.lua`
  from `~/.config/caelestia/` and creates empty ones there if they are
  missing, so that folder is needed even without caelestia. It requires
  `hyprland-gui.lua` without such a fallback: copy `linux/hyprmod/hyprland-gui.lua`
  even without HyprMod, or delete that line. `hypr-user.lua` needs the
  split-monitor-workspaces package (install steps in `linux/caelestia/SETUP.md`).
- **Keys that call caelestia's shell or CLI** do nothing without it: launcher
  (Super), session menu (Ctrl+Alt+Delete), sidebar (Super+N), all panels
  (Super+K), clear notifications (Ctrl+Alt+C), lock (Super+L, Super+Alt+L),
  shell restart (Ctrl+Super+Alt+R, Ctrl+Super+Shift+R), screenshots (Print,
  Super+Shift+S, Super+Shift+Alt+S, and HyprMod's Super+P / Super+Ctrl+P),
  recording (Ctrl+Alt+R, Super+Alt+R, Super+Shift+Alt+R), play/pause, next,
  previous and stop (the XF86Audio media keys and Ctrl+Super+Space / = / - /
  Backspace), brightness keys, and the clipboard and emoji pickers (Super+V,
  Super+Alt+V, Super+Period). Volume and mic mute use `wpctl` and keep
  working. Plain tools that do the same: fuzzel or rofi (launcher), wlogout
  (session menu), hyprlock (lock), grim + slurp (screenshots), wf-recorder
  (recording), playerctl (media), `cliphist list | fuzzel --dmenu | cliphist
  decode | wl-copy` (clipboard).
- **The shell is also a service.** caelestia's shell is the bar, the
  notification daemon, and what sets the wallpaper and colours. Plain tools:
  waybar (bar), mako or dunst (notifications), hyprpaper or swww (wallpaper).
- **Idle timeouts and the lock screen** come from caelestia's shell
  (`linux/caelestia/shell.json`: lock after 1 h, screens off after 1.5 h,
  suspend after 4 h). Without it, use hypridle and hyprlock.
- **Pop-up workspaces** (Super+M, Super+D, Super+S and the others) take their
  app list from caelestia's defaults in `utils/functions.lua`, merged with
  `~/.config/caelestia/cli.json` (`linux/caelestia/cli.json`, which makes
  Super+D start Equibop). Copy that file too. The system monitor default runs
  btop in `foot`, caelestia's terminal. If `cli.json` doesn't parse, the
  helper calls `caelestia shell toaster`, which needs the shell.
- **Autostart** (`hyprland/execs.lua`): drop `caelestia shell -d`. The
  `gammastep` and geoclue lines are dead here, because neither is installed;
  the night light is hyprsunset (`linux/hyprsunset`).
- **Qt theme.** `hyprland/env.lua` sets `QT_QPA_PLATFORMTHEME=qtengine`, and
  `qtengine` comes from caelestia's `qt` component. Without it, Qt apps lose
  their theme: install it or change the variable.
- **Colours.** Window borders, shadows, group bars and the background colour
  read `scheme/current.lua`, which caelestia regenerates from the wallpaper.
  Without caelestia, `hyprland.lua` copies `scheme/default.lua` there on first
  start, so the colours are fixed.

## Tools caelestia brings

caelestia's config starts these tools at login or calls them from a key. All
of them work without caelestia.

| Tool | Package | Does |
|---|---|---|
| fuzzel | `fuzzel` | type-to-filter pop-up menu (clipboard and emoji pickers) |
| cliphist, wl-paste | `cliphist`, `wl-clipboard` | clipboard history (autostart) |
| hyprpicker | `hyprpicker` | colour picker (Super+Shift+P, Super+Shift+C) |
| polkit-gnome | `polkit-gnome` | password prompt for admin actions (autostart) |
| gnome-keyring | `gnome-keyring` | password store for apps (autostart) |
| mpris-proxy | `bluez-utils` | Bluetooth headphone buttons control media (autostart) |
| trash-empty | `trash-cli` | empties trash older than 30 days (autostart) |
| wpctl | `wireplumber` | volume keys |
| pwvucontrol | `pwvucontrol` | audio mixer (Ctrl+Alt+V) |
| ydotool | `ydotool` | types the latest clipboard entry (Ctrl+Shift+Alt+V); needs `ydotoold`, which doesn't run here, so the key does nothing |

## Preferences

The user went through caelestia's keys on 2026-10-08. The role matters, not
the app or the exact key.

- **Must:** Super+T terminal, Super+E file manager, Super+B browser; Super+M
  music, Super+D chat and Super+S scratch (pop-up workspaces), and Super+Alt+S
  to send a window to scratch.
- **Use:** the launcher; lock; clipboard history; the keyboard's own media
  keys (through Fn), volume knob and mute; Super+Shift+S region screenshot on
  a frozen screen; colour picker; restarting the shell (Ctrl+Super+Alt+R).
- **Nice to have:** session menu, emoji picker, editor on Super+C, system
  monitor pop-up (Ctrl+Shift+Esc).
- **Not used, or didn't come up:** Print and Super+P screenshots; todo pop-up
  (Super+R, "don't care"); F10–F12 volume (the keyboard has its own keys, and
  these take F11 fullscreen and F12 developer tools away from apps).
- **Didn't know about, open to whatever the next shell does:** sidebar, all
  panels, clear notifications, restart and lock, recording, deleting
  clipboard entries, Ctrl+Super+Space media keys, audio mixer.
- Pop-up workspaces are "messy and unused" for now apart from music, chat and
  scratch; windows come back with the workspace number keys. Open to
  rethinking them.
