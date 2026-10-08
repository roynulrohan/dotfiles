# caelestia overrides

Everything of mine on top of [caelestia dots](https://github.com/caelestia-dots/caelestia).
**Since 2026-10-08 the shell is Noctalia (`linux/noctalia`), and
`~/.config/hypr` is ours (`linux/hypr`).** caelestia stays installed as a
fallback but doesn't run, and `caelestia update` must not run (it would
overwrite `~/.config/hypr`). Still in use from this package: `hypr-vars.lua`
and `hypr-user.lua` (loaded by `linux/hypr/hyprland.lua`), `cli.json` (the
pop-up workspaces), `user-config.fish` (caelestia's `~/.config/fish` is
still theirs). `shell.json` only applies when caelestia's shell runs. A copy
of caelestia's original Hyprland config, which nothing loads, is kept in
`hypr-reference/` (see "Reference copy" below).

## Files

| Repo | Destination | What |
|---|---|---|
| `hypr-vars.lua` | `~/.config/caelestia/hypr-vars.lua` | kitty as terminal; single-window outer gap matched to HyprMod's `gaps_out`; caelestia's resize keys switched off (see Window mode); Super+C opens VS Code (`code`; caelestia's default `codium` isn't installed), Super+Shift+L runs `systemctl suspend` (caelestia's `suspend-then-hibernate` can't work, see `shell.json` below), cursor theme `breeze_cursors` (caelestia's `sweet-cursors` isn't installed); the look (window transparency, gradient borders, no shadows, blur behind pop-up workspaces; see Look) |
| `hypr-user.lua` | `~/.config/caelestia/hypr-user.lua` | Super+Shift+arrow resize binds, HyDE's behaviour defaults (see Look), window mode and per-monitor workspaces (below), and loading `hypr-local.lua` if the machine has one; Hyprland config that HyprMod can't express goes here |
| `shell.json` | `~/.config/caelestia/shell.json` | bar: numbered workspaces, 5 shown; dashboard and sidebar on; weather for Ottawa (coordinates: the IP lookup said Toronto, and the name "Ottawa" also matches US towns); logout button runs `uwsm stop` (see `linux/sddm/SETUP.md`, frozen screen); no notifications on the lock screen (`lock.hideNotifs`); the lock screen shows the wallpaper, not a blurred screenshot of the desktop (`lock.useWallpaper`: after waking from sleep the blur once failed and the desktop showed sharp behind the lock). Idle (`general.idle.timeouts`): lock after 1 h, screens off after 1.5 h, `systemctl suspend` after 4 h. caelestia's default `suspendThenHibernate` can't work here (zram swap only, so logind reports `CanSuspendThenHibernate=na`) and failed silently. Audio playing (`general.idle.inhibitWhenAudio`, default on) and Keep awake (an idle inhibitor; every step respects it) pause all three. Launcher actions (`launcher.actions`, typed after `>`): caelestia's defaults plus Restart shell, Reload Hyprland, Restart wallpapers, Night light off/on and Battery (a notification with each wireless device's charge from UPower, such as the Lightspeed mice: caelestia only shows laptop and Bluetooth batteries); Sleep runs `systemctl suspend` instead of the impossible `suspendThenHibernate`. The list replaces caelestia's whole default list, so it repeats the defaults; commands run directly, through `sh -c` when they need a shell. The lock screen's media controls have no setting |
| `user-config.fish` | `~/.config/caelestia/user-config.fish` | runs after caelestia's `config.fish`: resets its frozen wallpaper colours in Orca's terminal and in kitty (kitty takes Noctalia's palette instead); other fish config lives in `shared/fish` |
| `cli.json` | `~/.config/caelestia/cli.json` | Super+D (the communication special workspace) starts and gathers Equibop instead of the official Discord |

## Reference copy

`hypr-reference/` holds a copy of caelestia's `~/.config/hypr` at revision
`1ee7a98`. Nothing loads it. Its README lists what the layers above change,
which keys and tools need caelestia, and the user's key preferences, so the
Hyprland setup can be rebuilt without caelestia. Nothing refreshes it now:
`caelestia update` must not run.

## Look

Settled while ricing on 2026-10-08 against HyDE (HyDE-Project/HyDE and its
themes). Each rule below names the file it lives in.

- **One spacing unit, 4 px**: screen edges, under the bar and above the windows
  all 4 px; 2 px between windows (half the outer gap, Hyprland's own 1:2
  ratio). HyprMod: `gaps_in 1`, `gaps_out 4`; `singleWindowGapsOut 4` in
  `hypr-vars.lua` and window mode's `INSET = 4 + 2` in `hypr-user.lua` follow
  it. The Noctalia bar uses the same unit (`linux/noctalia`, Bar).
- **Shapes**: window rounding 12 (HyprMod), the bar's islands are full pills
  (24 px tall, radius 12). Border 2 px.
- **Borders** (`hypr-vars.lua`): HyDE-style two-colour 45° gradients, focused
  `primary` to `tertiary`, unfocused `onSurfaceVariant` to `outlineVariant` at
  80%, so unfocused windows keep a visible border (caelestia's was almost
  invisible). In Lua a gradient is a table, `{ colors = { … }, angle = 45 }`,
  not HyDE's old text form. Colours come from `scheme/current.lua`, which a
  Noctalia template keeps in step with the wallpaper (`linux/noctalia`).
- **Transparency** (`hypr-vars.lua`, `windowOpacity`): HyDE's 90% focused, 75%
  unfocused, for every window not on HyprMod's opaque list.
- **No shadows** (HyDE). **Blur** stays caelestia's (8, 2 passes); HyDE's 6
  with 3 passes was a close second.
- **Pop-up workspaces** (Super+M, D, S): the workspace behind is dimmed 30% and
  blurred (`dim_special` in `hypr-user.lua`, `blurSpecialWs` in
  `hypr-vars.lua`), as in HyDE.
- **Behaviour** (`hypr-user.lua`, HyDE's `defaults.lua`): apps can't pull
  focus (`focus_on_activate = false`), middle-click pastes, Num Lock on at
  login. Key repeat stays caelestia's 250 ms / 35 per second (HyDE keeps
  Hyprland's slower 600 / 25).
- **Animations**: caelestia's (`linux/hypr`, Changes from caelestia's original).

## Window mode

Window controls follow one convention: **arrows move, Shift resizes, Alt makes
the step fine**. mpv's image keys use it too (`linux/mpv`).

`hypr-user.lua` defines a Hyprland submap for moving and placing the active
window from the keyboard. It's Lua functions, which HyprMod can't express.
**Super+A** enters it; Esc, Enter or Super+A leave. Other keys do nothing
inside it.

| Key | Floating window | Tiled window |
|---|---|---|
| Arrows | Move 40 px | Move within the layout |
| Alt+arrows | Move 5 px | Move within the layout |
| Shift+arrows | Move an edge 30 px | Resize |
| Alt+Shift+arrows | Move an edge 5 px | Resize |
| Ctrl+arrows | Snap to the left / right / top / bottom half | Nothing |
| `f` | Fill the height | Nothing |
| `c` | Centre | Centre |

Outside the mode, **Super+Shift+arrows** resize the same way, 30 px. The edge
keys move the right or bottom edge in the arrow's direction. When a floating
window sits against the right or bottom side of the usable area (snapped there
with Ctrl+→ or Ctrl+↓), they move the left or top edge instead, so the window
stays against that side.

Floating windows stay inside the usable area of their monitor: the bar (the
monitor's reserved area) and the 4 px outer gap are excluded,
and a step that would cross an edge stops at it. Hyprland resizes a floating
window around its centre, so the edge keys move it by half the change to keep
the other edge put.

caelestia's own resize keys are switched off in `hypr-vars.lua` (empty key
lists): Super+-/=, Super+Shift+-/= and Super+Alt+arrows, which resized by 10%
of the window per press. Those keys are free.

The convention is for these window controls, not every bind. In caelestia's
workspace and monitor keys, Shift means "take the window along" (Super+Shift+1…0,
Super+Shift+[ / ]) and Alt means "send it without following" (Super+Alt+1…0);
Super+Shift+arrows is the exception there.

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
21–30 (`monitor_priority`). A bar that labels workspaces by id (caelestia's
did) shows 11–20 and 21–30 on the side monitors. All 30 workspaces are persistent (the package's
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
Ctrl+Super+Alt+N) are unbound. Ctrl+Super+Shift+arrows (move in a direction)
carries a tiled window across monitors at the edge, but a floating window only slides to its own
monitor's edge (Hyprland's floating layout, `moveTargetInDirection`); use
Super+Shift+[ / ] for those.

## Machine-local config

If `~/.config/caelestia/hypr-local.lua` exists, `hypr-user.lua` loads it after
everything above. It holds config that stays on one machine and out of this
repo. A load error shows as a Hyprland notification instead of failing quietly.

## Install

Follow caelestia's installer first (it also installs Hyprland, fish, foot,
fastfetch, starship, the Nerd Font). Then copy the files above in and run
`hyprctl reload`. `shell.json` only matters when caelestia's shell runs.

The installer asks which components to set up. Pick these:

hypr, fish, foot, fastfetch, btop, micro, thunar, starship, firefox, gtk, qt,
auth, network, bluetooth, pipewire, clipboard, fonts, tools, spotify, vscode,
zed, nvim, discord, uwsm, zen

The first CachyOS install also enabled `todoist`, but it isn't used: skip it.
caelestia's Super+R (the todo special workspace) then opens an empty scratchpad.
caelestia records the components it set up in
`~/.local/state/caelestia/dots-state.json` (`enabled_components`).

The `spotify` component installs Spotify and Spicetify (a Spotify client mod)
with a "caelestia" theme, so Spotify takes the wallpaper colours. Super+M (the
music special workspace) starts Spotify through `spicetify watch -s`, which
refuses to run until Spicetify has been applied once, so Super+M did nothing.
Apply it after installing, and again after a Spotify update (the package
resets the folder to root-only and drops the patch):

```bash
sudo chmod a+wr /opt/spotify && sudo chmod a+wr /opt/spotify/Apps -R
spicetify backup apply
```

The `chmod` lines are Spicetify's own instructions for Spotify from the AUR.

AUR helper chosen in the installer: `paru`.

Colour scheme: `dynamic`, which takes its colours from the current wallpaper,
dark mode, `tonalspot` variant. Set it after installing:

```fish
caelestia scheme set -n dynamic -f hard -m dark -v tonalspot
```

The wallpapers themselves aren't in this repo; they live in
`~/Pictures/Wallpapers` on the CachyOS desktop.

## Things to know

- Load order: `linux/hypr` base → `hyprland/*.lua` → `hypr-user.lua` → HyprMod's
  `hyprland-gui.lua`. Later wins, but a duplicate bind fires twice; overriding a
  caelestia bind needs an `unbind` first (see `linux/hyprmod`).
- caelestia set terminal colours 0–18 from the wallpaper via
  `~/.local/state/caelestia/sequences.txt`. Since the Noctalia switch nothing
  rewrites the file; kitty resets those colours and takes Noctalia's palette
  instead (`shared/kitty`).
- **Qt apps turn light after a Qt update.** Qt apps (Dolphin and others) get
  their dark colours from `qtengine`, caelestia's Qt theme engine, built from
  the AUR against Qt's private API. When `qt6-base` moves to a new version (6.11
  to 6.12 on 2026-10-08), the engine still loads but stops applying the colour
  scheme, so newly started Qt apps come up light. Rebuild it, then restart the
  Qt apps: `paru -S --rebuild qtengine`. Darkly (`darkly-bin`) only uses Qt's
  public API and survives updates.
- `singleWindowGapsOut` in `hypr-vars.lua` must track HyprMod's outer gap by hand.
- Wallpapers: `~/Pictures/Wallpapers`. If the folder is created after the shell
  starts, restart the shell once so the picker sees it.
