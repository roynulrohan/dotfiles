# Hyprland

The Hyprland config in `~/.config/hypr`: binds, rules, autostart, the look, a
keyboard mode that places windows, and separate workspaces on each monitor. The
modules and [`variables.lua`](variables.lua) come from caelestia's Hyprland
config, so some names and defaults are caelestia's. The animation presets and
[`window-mute`](window-mute) come from HyDE. Both projects are GPL-3.0, so this
package is too ([`LICENSE`](LICENSE)).

## Files

Every file is in [`manifest.tsv`](../../manifest.tsv).

| Repo | Destination | What |
|---|---|---|
| [`hyprland.lua`](hyprland.lua) | `~/.config/hypr/hyprland.lua` | Entry point. Loads the modules, then the override layers (see Load order). |
| [`variables.lua`](variables.lua) | `~/.config/hypr/variables.lua` | Key names, apps and colours that the modules read, with caelestia's defaults. `hypr-vars.lua` overrides values. |
| [`hyprland/`](hyprland) | `~/.config/hypr/hyprland/` | The modules: env, general, input, misc, animations, decoration, group, autostart (`execs.lua`), rules, gestures, binds. |
| [`hypr-vars.lua`](hypr-vars.lua), [`hypr-user.lua`](hypr-user.lua) | `~/.config/hypr/` | The override layers (see Override layers). |
| [`utils/functions.lua`](utils/functions.lua) | `~/.config/hypr/utils/functions.lua` | Helpers that the binds and autostart use (pop-up workspaces, picture-in-picture). |
| [`animations/`](animations) | `~/.config/hypr/animations/` | Animation presets. [`hyprland/animations.lua`](hyprland/animations.lua) picks one by name (see Animations). |
| [`scheme/default.lua`](scheme/default.lua) | `~/.config/hypr/scheme/default.lua` | Fallback colours. `hyprland.lua` copies it to `scheme/current.lua` when that file is missing. |
| [`window-mute`](window-mute) | `~/.local/bin/window-mute` (executable) | Mutes the focused window's sound (see window-mute). |

Other files in `~/.config/hypr`:

- `hyprland-gui.lua` belongs to HyprMod ([`linux/hyprmod`](../hyprmod/SETUP.md)).
- `hyprsunset.conf` belongs to [`linux/hyprsunset`](../hyprsunset/SETUP.md).
- `scheme/current.lua` is the colour file that borders, group bars and the
  background read. A Noctalia template generates it from the wallpaper palette
  ([`linux/noctalia`](../noctalia/SETUP.md)), so it isn't in the repo.
- `hypr-local.lua` is an optional local slot for config that stays on one
  machine and out of this repo. If it exists, `hypr-user.lua` loads it after
  everything else. A load error shows as a Hyprland notification instead of
  failing quietly.
- `scheme/current.conf` is a `gone` row in `manifest.tsv`: nothing reads it, so
  delete it if it exists.

split-monitor-workspaces lives in `~/.local/share/hypr-plugins/` as a git clone
(see Install). The wallpapers aren't in this repo
([`linux/wallpaper`](../wallpaper/SETUP.md)).

## Install

```bash
# The compositor and its portals; uwsm runs the session (linux/uwsm)
sudo pacman -S hyprland xdg-desktop-portal-hyprland xdg-desktop-portal-gtk uwsm
# What the autostart and binds run: polkit agent, trash cleanup, terminal,
# file manager, cursor theme
sudo pacman -S polkit-gnome trash-cli kitty dolphin breeze-cursors
# AUR: the editor (Super+C) and music (Super+M) apps
paru -S visual-studio-code-bin spotify spicetify-cli
# AUR, optional: the todo pop-up (Super+R)
paru -S todoist-appimage
```

The autostart also starts Noctalia ([`linux/noctalia`](../noctalia/SETUP.md)),
and Super+D starts Equibop ([`linux/equibop`](../equibop/SETUP.md)). The Verify
checks use `jq`.

Install split-monitor-workspaces (see Per-monitor workspaces), pinned to the
reviewed commit:

```bash
git clone https://github.com/zjeffer/split-monitor-workspaces.git \
    ~/.local/share/hypr-plugins/split-monitor-workspaces
git -C ~/.local/share/hypr-plugins/split-monitor-workspaces checkout f26d624
```

Copy the files in the table, then run `hyprctl reload`.

Super+M (the music pop-up workspace) starts Spotify through
`spicetify watch -s`. That command refuses to run until Spicetify (a Spotify
client mod) has been applied once, so Super+M does nothing until then. Apply it
after you install Spotify, and again after each Spotify update (the package
resets the folder to root-only and drops the patch):

```bash
sudo chmod a+wr /opt/spotify && sudo chmod a+wr /opt/spotify/Apps -R
spicetify backup apply
```

The `chmod` lines are Spicetify's own instructions for Spotify from the AUR.

## Notes

### Load order

`hyprland.lua` loads `hypr-vars.lua`, the `hyprland/*.lua` modules,
`hypr-user.lua`, then HyprMod's `hyprland-gui.lua`, all from `~/.config/hypr`.
The later file wins. But a duplicate bind fires twice: to override a bind from
[`hyprland/keybinds.lua`](hyprland/keybinds.lua), `unbind` it first (see
[`linux/hyprmod`](../hyprmod/SETUP.md)).

### Override layers

[`hypr-vars.lua`](hypr-vars.lua) changes values from `variables.lua`:

- kitty is the terminal, Dolphin the file manager.
- `editor = "code"`: Super+C opens VS Code.
- `sleepGestureCmd`: Super+Shift+L runs `systemctl suspend`. The default,
  `suspend-then-hibernate`, can't work with zram swap only: logind then reports
  `CanSuspendThenHibernate=na`.
- The cursor theme is `breeze_cursors` (package `breeze-cursors`). Keep it
  equal to `XCURSOR_THEME` in [`linux/uwsm`](../uwsm/SETUP.md).
- Volume keys step 1%.
- `singleWindowGapsOut = 4`: a lone tiled window gets the same outer gap as
  HyprMod's `gaps_out`. Change both together by hand.
- The look: window transparency, gradient borders, no shadows, blur behind
  pop-up workspaces (see Look).
- The resize keys from `keybinds.lua` are switched off (see Window mode).
- `toggles`: Super+D (the communication pop-up workspace) starts and gathers
  Equibop, not the official Discord app. The defaults are in
  [`utils/functions.lua`](utils/functions.lua).

[`hypr-user.lua`](hypr-user.lua) holds Hyprland config that HyprMod can't
express:

- Window mode and the Super+Shift+arrow resize binds (see Window mode).
- Per-monitor workspaces (see below).
- The behaviour settings, the pop-up dimming and the glow (see Look).
- Alt+Tab opens Noctalia's window switcher: hold Alt and press Tab to move,
  release Alt to switch. Shift+Tab moves back inside the switcher, so
  Hyprland's Shift+Alt+Tab is unbound.
- Super+Ctrl+M runs `window-mute`.
- Super+Ctrl+F toggles "fake fullscreen": the app is told it is fullscreen,
  but the window keeps its size. A browser then hides its tabs, and a video's
  own fullscreen button fills only this window.
- Loading `hypr-local.lua`, if it exists (see Files).

### Autostart, rules and environment

- **Autostart** ([`hyprland/execs.lua`](hyprland/execs.lua)): the polkit agent,
  `trash-empty 30` (deletes trash older than 30 days), the cursor theme for
  `hyprctl` and gsettings, and Noctalia in its own uwsm scope
  (`uwsm app -- noctalia`). The night light is hyprsunset's own user service
  ([`linux/hyprsunset`](../hyprsunset/SETUP.md)).
- **Shell keys** ([`hyprland/keybinds.lua`](hyprland/keybinds.lua)) call
  `noctalia msg …`. The list is in [`linux/noctalia`](../noctalia/SETUP.md),
  Keys. The clipboard history is Noctalia's own.
- **Environment:** uwsm gives apps started by systemd or D-Bus the variables in
  `~/.config/uwsm/env` and `env-hyprland` ([`linux/uwsm`](../uwsm/SETUP.md)),
  not those in [`hyprland/env.lua`](hyprland/env.lua). Change both when a
  variable changes.
- **Rules** ([`hyprland/rules.lua`](hyprland/rules.lua)): Noctalia's
  recommended blur for its bar, panels and notifications, a floating settings
  window, and no Hyprland animation on any Noctalia layer. Without that last
  rule, the preset's slide-in for layers makes the screenshot overlay drop in
  from the top. Hyprland matches the whole namespace, so the pattern is
  `^noctalia-.*$`, not `^noctalia-`.

### Animations

[`hyprland/animations.lua`](hyprland/animations.lua) picks a preset by name from
`animations/`. The one in use is `caelestia.lua`, caelestia's original set:
quick window open and close, smooth workspace slides, and a vertical slide-fade
for pop-up workspaces. On top of the preset, `animations.lua` makes pop-up
workspaces drop in from the top and slide back up on close.

The other presets are HyDE's (HyDE-Project/HyDE,
`Configs/.local/share/hypr/lua/animations/`, GPL-3.0), copied unchanged at HyDE
commit `fa2fd57a`, with HyDE's GPL-3.0 licence as
[`animations/LICENSE`](animations/LICENSE). They only call `hl.curve` and
`hl.animation`. Most scale their speeds by `hyde.config.anim.duration_scale`,
which the picker sets to 1.

### Look

Each rule below names the file it lives in.

- **One spacing unit, 4 px**: the screen edges, the space under the bar and
  the space above the windows are all 4 px. HyprMod sets `gaps_out 4` and
  `gaps_in 1`. Hyprland puts `gaps_in` on each side of a window, so windows
  have 2 px between them. `singleWindowGapsOut 4` in `hypr-vars.lua` and window
  mode's `INSET = 4 + 2` in `hypr-user.lua` follow the unit. The Noctalia bar
  uses the same unit ([`linux/noctalia`](../noctalia/SETUP.md), Bar).
- **Shapes**: window rounding 12 and border 2 px (HyprMod).
- **Borders** (`hypr-vars.lua`): HyDE-style two-colour 45° gradients from
  `scheme/current.lua`. Focused windows go from `primary` to `tertiary`.
  Unfocused windows go from `onSurfaceVariant` to `outlineVariant` at 80%, so
  they keep a visible border.
- **Transparency** (`hypr-vars.lua`, `windowOpacity`): HyDE's 90% focused and
  75% unfocused, for every window that is not on HyprMod's opaque list.
- **No shadows** (`hypr-vars.lua`). **Blur**: size 8, 2 passes
  (`variables.lua`).
- **Glow** (`hypr-user.lua`, Hyprland 0.56 or newer): an inner glow on the
  focused window, in the border's gradient at half strength. Unfocused windows
  get none. Motion blur stays off: with an NVIDIA GPU, windows flash while they
  move.
- **Pop-up workspaces** (Super+M, D, S): the workspace behind is dimmed 30% and
  blurred (`dim_special` in `hypr-user.lua`, `blurSpecialWs` in
  `hypr-vars.lua`).
- **Behaviour** (`hypr-user.lua`): apps can't pull focus
  (`focus_on_activate = false`), middle-click pastes, and Num Lock is on at
  login. Key repeat ([`hyprland/input.lua`](hyprland/input.lua)) is 250 ms
  and 35 per second, faster than Hyprland's default 600 / 25.
- **Animations**: the caelestia preset (see Animations).

### Window mode

`hypr-user.lua` defines a Hyprland submap that moves and places the active
window from the keyboard. It uses Lua functions, which HyprMod can't express.
**Super+A** enters it. Esc, Enter or Super+A leave it. Other keys do nothing
inside it.

| Key | Floating window | Tiled window |
|---|---|---|
| Arrows | Move 40 px | Move within the layout |
| Alt+arrows | Move 5 px | Move within the layout |
| Shift+arrows | Move an edge 30 px | Resize |
| Alt+Shift+arrows | Move an edge 5 px | Resize |
| Ctrl+arrows | Snap to the half in the arrow's direction | Nothing |
| `f` | Fill the height | Nothing |
| `c` | Centre | Nothing |

Outside the mode, **Super+Shift+arrows** resize the same way, 30 px. The edge
keys move the right or bottom edge in the arrow's direction. When a floating
window sits against the right or bottom side of the usable area (snapped there
with Ctrl+→ or Ctrl+↓), they move the left or top edge instead, so the window
stays against that side.

Floating windows stay inside the usable area of their monitor: the bar (the
monitor's reserved area) and a 6 px margin, the 4 px outer gap plus the 2 px
border, are excluded, and a step that would cross an edge stops at it. Hyprland
resizes a floating window around its centre, so the edge keys move it by half
the change to keep the other edge in place.

`hypr-vars.lua` switches off the resize keys from `keybinds.lua` with empty key
lists: Super+-/=, Super+Shift+-/= and Super+Alt+arrows. Those keys are free.

### Per-monitor workspaces

Each monitor has its own workspaces 1 to 10 on Super+1…0, as in awesome and
dwm. [split-monitor-workspaces](https://github.com/zjeffer/split-monitor-workspaces)
does it. It is a Lua package for Hyprland 0.55 or newer. Its alternative,
hyprsplit, doesn't work with Lua configs. It isn't copied into this repo (see
Install).

If the package is missing, the global workspace keys in
[`hyprland/keybinds.lua`](hyprland/keybinds.lua) stay and Super+Shift+N does
nothing.

`monitor_priority` in `hypr-user.lua` sets the ranges: DP-1 (main) gets
Hyprland ids 1 to 10, HDMI-A-1 (right) 11 to 20, and DP-2 (left) 21 to 30.
With other monitor names, change that list. A bar that labels workspaces by id
shows 11 to 20 and 21 to 30 on the side monitors.

All 30 workspaces are persistent (the package's default), so Hyprland's own
workspace rules pin each one to its monitor. Don't turn persistence off.
Without it, each config reload moves workspaces and their windows to the wrong
monitor.

| Key | Does |
|---|---|
| Super+1…0 | go to workspace N on the focused monitor |
| Super+Shift+1…0, Super+Alt+1…0 | move the window there and follow it, or stay |
| Super+scroll, Super+PgUp/PgDn, Ctrl+Super+←/→ | cycle workspaces on this monitor |
| Super+Alt+scroll, Super+Alt+PgUp/PgDn, Super+Ctrl+Alt+←/→ | move the window to the next or previous workspace on this monitor |
| Super+Ctrl+↓ | first empty workspace on this monitor |
| Super+[, Super+] | focus the monitor on the left or right |
| Super+Shift+[, Super+Shift+] | send the window to the monitor on the left or right |

The "groups of 10" keys from `keybinds.lua` (Ctrl+Super+N, Ctrl+Super+scroll,
Ctrl+Super+Alt+N) are unbound. Ctrl+Super+Shift+arrows (move in a direction)
carries a tiled window across monitors at the edge. A floating window only
slides to its own monitor's edge (Hyprland's floating layout,
`moveTargetInDirection`); use Super+Shift+[ / ] for those.

### window-mute

Super+Ctrl+M mutes or unmutes only the focused window's sound.
[`window-mute`](window-mute) is a port of HyDE's `window.mute.py`. Its header
explains how it matches audio streams to the window. The notification names
the app, not the window title. It needs `python`, `pactl` (package `libpulse`)
and `notify-send` (package `libnotify`).

## Verify

```bash
./status.sh | grep -E 'config/hypr/|window-mute'   # ok on every line
hyprctl configerrors                                # blank lines only: no config errors
git -C ~/.local/share/hypr-plugins/split-monitor-workspaces rev-parse --short HEAD   # f26d624
hyprctl workspaces -j | jq -r '.[] | select(.id > 0) | .monitor' | sort | uniq -c   # 10 per monitor
python3 -c 'import hyprland_config, pathlib; hyprland_config.load_any(pathlib.Path.home() / ".config/hypr/hyprland.lua")'   # prints nothing: HyprMod can read the config (needs linux/hyprmod)
```

The `python3` line runs `hyprland.lua`, which creates `hypr-vars.lua`,
`hypr-user.lua` and `scheme/current.lua` if they are missing.

With Noctalia's hypr-submap plugin ([`linux/noctalia`](../noctalia/SETUP.md)),
Super+A shows a "window" island on the bar until you leave window mode.
