# Noctalia

The desktop shell since 2026-10-08: bar (top), launcher, notifications, lock
screen, idle timers, on-screen pop-ups, control centre, clipboard history,
screenshots. Replaced caelestia's shell, mainly for the top bar and plugins.
Docs: [docs.noctalia.dev](https://docs.noctalia.dev/).

| Repo | Destination |
|---|---|
| `config.toml` | `~/.config/noctalia/config.toml` |
| `templates/` | `~/.config/noctalia/templates/` (colour templates, below) |
| `plugins/workspace-apps/` | `~/.local/share/noctalia/plugins/workspace-apps/` (bar plugin, below) |

## Install

```bash
sudo pacman -S noctalia
```

The package is `noctalia`, version 5 (a C++ rewrite). Not `noctalia-shell`,
which is the old Quickshell version 4, and not `cachyos-hypr-noctalia`, a whole
Hyprland preset. Copy `config.toml`, then set the wallpaper the colours come
from:

```bash
noctalia msg wallpaper-set ~/Pictures/Wallpapers/live/eri-uesugi.png
```

Hyprland starts it at login (`linux/hypr`, `hyprland/execs.lua`), in its own
uwsm scope; verified across a log out and log in on 2026-10-08. Enable the plugins once:
`noctalia msg plugins enable roynul/workspace-apps` and
`noctalia msg plugins enable k4n4t4/hypr-submap` (a community plugin, fetched
from Noctalia's community repo).

## Config

All files in `~/.config/noctalia/*.toml` are merged; Noctalia never rewrites
them. Changes made in its settings window go to
`~/.local/state/noctalia/settings.toml`, which loads last and wins. Check with
`noctalia config validate`; apply with `noctalia msg config-reload`. Log:
`~/.cache/noctalia/noctalia.log`.

- **Wallpaper drawing off**: the live wallpapers (`linux/wallpaper`) would be
  covered otherwise. The wallpaper path is still set, for the colours.
- **Colours** from the wallpaper, style `m3-tonal-spot`, caelestia's
  "tonalspot". One palette for the whole shell, from the default wallpaper.
- **Idle**, as under caelestia: lock after 1 h, screens off after 1.5 h, lock
  and suspend after 4 h. Noctalia pauses for idle inhibitors (browsers and mpv
  during video), not for any audio playing as caelestia did.
- **Location** `Ottawa, Ontario, Canada`, for weather. Plain "Ottawa" also
  matches US towns; coordinates work but the UI then shows the numbers as the
  place name.
- **12-hour time** everywhere: `[shell] time_format` / `date_format` (control
  centre, calendar, lock screen) and the bar clock (`Thu Oct 8 · 3:42 PM`, full
  date on hover). Font: JetBrainsMono Nerd Font.
- **Session menu**: the default five buttons, but log out runs `uwsm stop`.
- **Panels** (control centre, wallpaper, session) float with their own solid
  background and open under the island that was clicked. Attached panels share
  the bar's background, which is invisible here.
- **Screenshots** open in Noctalia's editor before anything is delivered: Enter
  or Done copies, Save writes to `~/Pictures/Screenshots`, Esc discards; Ctrl+C
  / Ctrl+S in the region overlay skip the editor. Nothing is saved
  automatically.
- **Launcher actions**: `/cmd` lists Restart audio (PipeWire and the EQ, for
  when the headset drops off USB and PipeWire keeps failing on the old device),
  Restart shell, Reload Hyprland, Restart wallpapers, Night light off / on,
  Battery. They also match by name in normal search. Ported from caelestia's
  `>` actions; shutdown, lock and the rest are in `/session`.

## Bar

HyDE-style islands: the bar itself is invisible (`background_opacity = 0`) and
each widget or group is a rounded pill at 80% opacity, blurred by Hyprland's
layer rule (`linux/hypr`, `ignore_alpha` keeps the empty bar unblurred). Left
holds information, the middle the current workspace's apps, the right
controls:

stats (CPU, RAM, CPU and GPU temperature) · workspaces · submap | app icons |
media · signal (network, volume) · modes (caffeine, notifications; right-click
the bell for do not disturb) · tray · clock · system (wallpaper, control
centre) · power

Workspaces show only occupied ones as bare numbers; the active one is a wider
filled pill (inactive pills are transparent). Spacing follows the window grid
(see "Look" in `linux/caelestia/SETUP.md`): the bar is 24 px tall and the
islands fill it, 4 px from the screen top and 4 px above the windows, flush
with the window edges; 16 px between islands, 8 px inside one, 8 px end
padding (groups default to 6, so it is set per group). Text ≈ 10.5 px bold
(Noctalia's bar text is 14 px; `font_scale 0.75`), as HyDE's 10 px.

## Plugin: hypr-submap (community)

`k4n4t4/hypr-submap` 1.0.0 (MIT): shows the active Hyprland submap, so a small
island reading "window" appears while window mode (Super+A,
`linux/caelestia`) is on; hidden otherwise, and clicking it leaves the mode. It
listens to Hyprland's event socket with `socat` and runs only `hyprctl submap`
and `hyprctl dispatch 'hl.dsp.submap("reset")'`; the code was read before
installing. Noctalia keeps it under
`~/.local/state/noctalia/plugins/materialized/community/`, so it isn't copied
from here.

## Plugin: workspace apps

`plugins/workspace-apps` (Luau, v0.3): the app icons of the windows on *this*
monitor's current workspace, in screen order; each monitor's own last-focused
window bright, the others dimmed; click to focus; hidden when the workspace is
empty. It replaces the built-in `taskbar` with `only_active_workspace`, which
shows every window from all monitors on a monitor whose workspace is empty
(`taskbar_widget.cpp`: the filter only runs when it finds a workspace to match).
It never uses window titles.

- `hyprland.luau`, a `[[service]]` (one for all bars): follows Hyprland's event
  socket with one `socat` (`noctalia.runStream`), runs `hyprctl -j monitors` and
  `clients` after a burst of events, and publishes each monitor's list to plugin
  state. A 5 s poll covers a dead stream. `noctalia msg plugin
  roynul/workspace-apps:hyprland all status` logs counters.
- `icons.luau`, the bar widget: renders its monitor's list from
  `noctalia.state.watch`. A watch callback carries no bar context, so
  `barWidget.outputName()` returns nil there (`plugin_bindings.cpp`); the widget
  remembers its output from load and `update()` instead. Version 0.2 missed this
  and drew one monitor's list on every bar.

Changing `plugin.toml` needs `noctalia msg plugins disable` then `enable` for
Noctalia to re-read it.

## Colour templates

- `templates/kitty.conf`: Noctalia's built-in kitty template, copied, writing
  `~/.config/kitty/themes/noctalia.conf` (see `shared/kitty`). The built-in one
  also edits `kitty.conf`, which the Mac shares.
- `templates/hypr-scheme.lua`: rewrites `~/.config/hypr/scheme/current.lua`, the
  colour file the Hyprland config reads (window borders, group bars,
  background), in the key names of caelestia's old scheme file, then runs
  `hyprctl reload`. Noctalia's own Hyprland template only gives solid borders.

The rest take over the files caelestia used to write, so each app's existing
setting keeps pointing at the same file, and each file has one owner.
Noctalia's built-in GTK and Qt templates are not used: the GTK one edits
`gtk.css` and gsettings (kde-gtk-config also writes to `gtk.css`), and the Qt
one merges into `kdeglobals`.

| Template | Writes | Notes |
|---|---|---|
| `spicetify.ini` | `~/.config/spicetify/Themes/caelestia/color.ini` | keeps the `[caelestia]` section Spicetify selects; hook `spicetify -q -n refresh` re-patches Spotify without restarting it |
| `gtk.css` | `gtk-3.0/gtk.css` and `gtk-4.0/gtk.css` | caelestia's layout with Noctalia colours; keeps `@import "thunar.css"` and kde-gtk-config's `@import 'colors.css'`. Open GTK apps pick it up on restart |
| `thunar.css` | `gtk-3.0/thunar.css` and `gtk-4.0/thunar.css` | |
| `qtengine.colors` | `~/.config/qtengine/caelestia.colors` | Noctalia's KDE colour-scheme template; qtengine's config still points at this file, `kdeglobals` is left alone |
| `btop.theme` | `~/.config/btop/themes/caelestia.theme` | hook `pkill -USR2 -x btop` makes a running btop reload |
| `sddm-theme.conf` | `~/.local/state/caelestia/theme/sddm-theme.conf` | what `sddm-sync` reads for the login screen (`linux/sddm`); a fixed green for its success colour (`custom_colors.success`) |
| `equibop.theme.css` | `~/.config/equibop/themes/noctalia.theme.css` | Noctalia's community "Midnight" Discord theme, a new file; switch it on in Equibop → Settings → Themes. It loads its base CSS from `refact0r.github.io`, as caelestia's did |

VS Code is not themed: it keeps One Dark Pro Night Flat.

## Keys

In `linux/hypr/hyprland/keybinds.lua` (and HyprMod's Super+P / Super+Ctrl+P),
most through `noctalia msg`:

| Key | Command |
|---|---|
| Super (tap) | `panel-toggle launcher` |
| Super+L | `session lock` |
| Ctrl+Alt+Delete | `panel-toggle session` |
| Super+N | `panel-toggle control-center` |
| Ctrl+Alt+C | `notification-clear-active` |
| Super+V | `panel-toggle clipboard` |
| Super+Period | `panel-toggle launcher /emo` |
| Print | `screenshot-fullscreen` |
| Super+Shift+S, Super+Shift+Alt+S, Super+P, Super+Ctrl+P | `screenshot-region` |
| media keys, Ctrl+Super+Space / = / - / Backspace | `media toggle` / `next` / `previous` / `stop` |
| brightness keys | `brightness-up` / `brightness-down` |
| Ctrl+Super+Alt+R / Ctrl+Super+Shift+R | restart / stop Noctalia |

Volume keys stay on `wpctl`.

## Things to know

- **Log out with `uwsm stop`.** Noctalia's built-in log out exits Hyprland
  directly, which once froze the login screen (`linux/sddm`); the session menu
  is set to run `uwsm stop` instead.
- **Media island** (`[widget.media]`): "Title - Artist", 20 px album art, no
  minimum width so it hugs short titles, at most 240 px with long titles
  scrolling; hidden when no player runs. `hide_when_idle` (hide while paused) is
  in the docs but not in 5.2.1. Clicking it opens the control centre's Media tab.
  Tried and dropped: the media-island plugin.
- **Control centre** sidebar shows icons and names (`[control_center]`).
- **Night Light** in the control centre is Noctalia's own and off; the night
  light that runs is hyprsunset (`linux/hyprsunset`). Use the `/cmd` actions.
- Bluetooth shows nothing: the BlueZ service isn't running on this PC.
- The login screen is still SDDM with caelestia's theme. Noctalia has its own
  greeter, for greetd instead of SDDM; not tried yet.
- caelestia stays installed as a fallback but doesn't run. Back to it for one
  session: `pkill -x noctalia`, then `caelestia shell -d`. For good: restore
  `~/.config/hypr` from `linux/caelestia/hypr-reference`.
