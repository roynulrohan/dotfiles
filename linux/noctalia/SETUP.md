# Noctalia

Noctalia is the desktop shell: the bar at the top, launcher, notifications,
lock screen, idle timers, on-screen pop-ups, control centre, clipboard history
and screenshots. Docs: [docs.noctalia.dev](https://docs.noctalia.dev/).

## Files

| Repo | Destination |
|---|---|
| [`config.toml`](config.toml) | `~/.config/noctalia/config.toml` |
| [`templates/`](templates) | `~/.config/noctalia/templates/` (see Colour templates) |
| [`plugins/workspace-apps/`](plugins/workspace-apps) | `~/.local/share/noctalia/plugins/workspace-apps/` (see Plugin: workspace apps) |
| [`plugins/workspace-pills/`](plugins/workspace-pills) | `~/.local/share/noctalia/plugins/workspace-pills/` (see Plugin: workspace pills) |
| [`plugins/arch-updater/`](plugins/arch-updater/README.md) | `~/.local/share/noctalia/plugins/arch-updater/` (see Update widget) |
| [`arch-update-tray.desktop`](arch-update-tray.desktop) | `~/.config/autostart/arch-update-tray.desktop` (see Update widget) |
| [`spicetify-user.css`](spicetify-user.css) | `~/.config/spicetify/Themes/noctalia/user.css` (the Spotify theme's CSS; the `spicetify.ini` template writes its colours) |
| [`lock/scripts/`](lock/scripts) | `~/.local/share/noctalia/lock/scripts/` (see Lock screen; `apply.sh` is executable) |
| [`lock/avatar-clamshell.png`](lock/avatar-clamshell.png) | `~/.local/share/noctalia/lock/avatar-clamshell.png` |
| [`fonts/google-sans-flex/`](fonts/google-sans-flex) | `~/.local/share/fonts/google-sans-flex/` |

Files that are not in the repo:

- `~/.local/state/noctalia/settings.toml`: what Noctalia's settings window
  saves. It loads last and wins (see Config).
- `~/.config/noctalia/lock.toml`: the lock screen config. `gen.py` generates
  it, and it holds absolute paths.
- `~/Pictures/lock-gifs`: the GIFs for the lock screen's GIF card.
- The community plugin hypr-submap, which Noctalia keeps under
  `~/.local/state/noctalia/plugins/materialized/community/`.
- The wallpapers ([`linux/wallpaper`](../wallpaper/SETUP.md)).

## Install

```bash
sudo pacman -S noctalia socat pacman-contrib ffmpeg python ttf-jetbrains-mono-nerd
paru -S qtengine darkly-bin   # AUR; the Qt theme engine and style
sudo pacman -S papirus-icon-theme
```

- `noctalia` is version 5, a C++ rewrite. Don't install `noctalia-shell`, which
  is the old Quickshell version 4, or `cachyos-hypr-noctalia`, a whole Hyprland
  preset.
- `socat`: the workspace-apps, workspace-pills and hypr-submap plugins follow
  Hyprland's event socket with it.
- `pacman-contrib`: `checkupdates`, which the Arch Updater runs.
- `ffmpeg` and `python`: the lock screen scripts and its GIF card.
- `ttf-jetbrains-mono-nerd`: the shell's font.
- `qtengine`, `darkly-bin` and `papirus-icon-theme`: the Qt apps' theme engine,
  style and icons. `qtengine` reads the colours a template writes (see Colour
  templates).

The session also needs uwsm ([`linux/uwsm`](../uwsm/SETUP.md)): Hyprland starts
Noctalia at login in its own uwsm scope
([`linux/hypr`](../hypr/SETUP.md), `hyprland/execs.lua`), and log out runs
`uwsm stop`. The other templates write colour files for apps from other
packages (see Colour templates).

Copy the files, then run these once:

```bash
fc-cache -f   # the lock screen fonts
# The wallpaper the colours come from (see linux/wallpaper)
noctalia msg wallpaper-set ~/Pictures/Wallpapers/live/<your-still>.jpg
noctalia msg plugins enable roynul/workspace-apps
noctalia msg plugins enable roynul/workspace-pills
noctalia msg plugins enable roynul/arch-updater
# A community plugin, fetched from Noctalia's community repo
noctalia msg plugins enable k4n4t4/hypr-submap
```

Put the lock screen GIFs in `~/Pictures/lock-gifs`, then generate the lock
screen config (see Lock screen):

```bash
~/.local/share/noctalia/lock/scripts/apply.sh
```

On CachyOS, switch off `cachy-update`'s daily check (see Update widget):

```bash
systemctl --user mask --now arch-update.timer
```

## Notes

### Config

All files in `~/.config/noctalia/*.toml` are merged. Noctalia never rewrites
them. Changes made in its settings window go to
`~/.local/state/noctalia/settings.toml`, which loads last and wins. Check the
config with `noctalia config validate`. Apply it with
`noctalia msg config-reload`. Log: `~/.cache/noctalia/noctalia.log`.

- **Wallpaper drawing is off**: otherwise it covers the live wallpapers
  ([`linux/wallpaper`](../wallpaper/SETUP.md)). The wallpaper path is still
  set, for the colours.
- **Colours** come from the wallpaper: one palette for the whole shell, and
  every template (kitty, Hyprland, GTK, Qt, btop, Spotify, the login screen)
  follows it. Switch the scheme or wallpaper in Noctalia's settings at any time;
  Noctalia saves that in its state, not here. `config.toml` only holds the
  first-run default (`m3-tonal-spot`).
- **Idle**: lock after 1 h, screens off after 1.5 h, lock and suspend after
  4 h. Noctalia pauses for idle inhibitors (browsers and mpv during video).
  Audio playing on its own doesn't pause it.
- **Location**, for weather: `[location] address` takes a full
  `city, region, country` string, because a bare city name can match another
  town. Coordinates work, but the UI then shows the numbers as the place name.
- **12-hour time** everywhere: `[shell] time_format` / `date_format` (control
  centre, calendar, lock screen) and the bar clock (`Thu Oct 8 · 3:42 PM`, full
  date on hover). Font: JetBrainsMono Nerd Font.
- **Session menu**: the default five buttons, but log out runs `uwsm stop`.
  Don't switch it back: Noctalia's built-in log out exits Hyprland directly, and
  that has frozen the login screen ([`linux/sddm`](../sddm/SETUP.md)).
- **Panels** (control centre, wallpaper, session) float with their own solid
  background and open under the island that was clicked. Attached panels share
  the bar's background, which is invisible in this config.
- **Screenshots** open in Noctalia's editor before anything is delivered.
  Enter or Done copies, Save writes to `~/Pictures/Screenshots`, Esc discards.
  Ctrl+C / Ctrl+S in the region overlay skip the editor. Nothing is saved
  automatically.
- **Launcher actions**: `/cmd` lists Restart audio, Restart shell, Reload
  Hyprland, Restart wallpapers, Night light off / on, and Battery. They also
  match by name in normal search. Restart audio restarts PipeWire and the EQ,
  for when a USB headset drops off and PipeWire keeps failing on the old
  device. Battery reads `upower`. Shutdown, lock and the rest are in
  `/session`.
- **Media island** (`[widget.media]`): "Title - Artist", 20 px album art, no
  minimum width so it hugs short titles, at most 240 px with long titles
  scrolling. It hides when no player runs. `hide_when_idle` (hide while paused)
  is in the docs but not in 5.2.1. Clicking it opens the control centre's Media
  tab.
- **Control centre**: the sidebar shows icons and names (`[control_center]`).
- **Night Light** in the control centre is Noctalia's own and is off. The night
  light that runs is hyprsunset ([`linux/hyprsunset`](../hyprsunset/SETUP.md)).
  Use the `/cmd` actions.
- **Bluetooth** shows nothing while the BlueZ service isn't running.
- **Login screen**: SDDM with this repo's `noctalia-card` theme
  ([`linux/sddm`](../sddm/SETUP.md)), which follows Noctalia's palette,
  wallpaper and lock GIF. Noctalia has its own greeter, for greetd instead of
  SDDM.

### Bar

HyDE-style islands: the bar itself is invisible (`background_opacity = 0`), and
each widget or group is a rounded pill at 80% opacity. Hyprland's layer rule
blurs them ([`linux/hypr`](../hypr/SETUP.md); `ignore_alpha` keeps the empty bar
unblurred). Left, middle and right, separated by `|`:

stats (CPU, RAM, CPU and GPU temperature) · workspaces · submap | app icons |
media · signal (network, volume) · updates · tray · clock · system (caffeine,
notifications, wallpaper, control centre; right-click the bell for do not
disturb) · power

Workspaces show only occupied ones, as bare numbers. The active one is a wider
filled pill; inactive pills are transparent. Spacing follows the window grid
(see "Look" in [`linux/hypr/SETUP.md`](../hypr/SETUP.md)): the bar is 24 px tall
and the islands fill it, 4 px from the screen top and 4 px above the windows,
flush with the window edges. Islands have 16 px between them, 8 px inside, and
8 px end padding (groups default to 6, so it is set per group). Text is about
10.5 px bold (Noctalia's bar text is 14 px; `font_scale 0.75`), close to HyDE's
10 px.

### Keys

In [`linux/hypr/hyprland/keybinds.lua`](../hypr/hyprland/keybinds.lua), most
through `noctalia msg`:

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
| Super+Shift+S | `screenshot-region` |
| media keys, Ctrl+Super+Space / = / - / Backspace | `media toggle` / `next` / `previous` / `stop` |
| brightness keys | `brightness-up` / `brightness-down` |
| Ctrl+Super+Alt+R / Ctrl+Super+Shift+R | restart / stop Noctalia |

Alt+Tab runs `window-switcher hold` (in
[`linux/hypr/hypr-user.lua`](../hypr/hypr-user.lua)). Volume keys use `wpctl`.

### Plugin: hypr-submap (community)

`k4n4t4/hypr-submap` 1.0.0 (MIT) shows the active Hyprland submap. A small
island reading "window" appears while window mode (Super+A,
[`linux/hypr`](../hypr/SETUP.md)) is on. It is hidden otherwise, and clicking it
leaves the mode. It listens to Hyprland's event socket with `socat` and runs
only `hyprctl submap` and `hyprctl dispatch 'hl.dsp.submap("reset")'`; version
1.0.0 was reviewed for this. Noctalia keeps it under
`~/.local/state/noctalia/plugins/materialized/community/`, so it isn't copied
from here.

### Plugin: workspace apps

[`plugins/workspace-apps`](plugins/workspace-apps) (Luau, v0.4) shows the app
icons of the windows on *this* monitor's current workspace, in screen order.
Each monitor's own last-focused window is bright, the others are dimmed. Click
an icon to focus its window. The widget hides when the workspace is empty. It
stands in for the built-in `taskbar` with `only_active_workspace`, which shows
every window from all monitors on a monitor whose workspace is empty
(`taskbar_widget.cpp`: the filter only runs when it finds a workspace to
match). It never uses window titles.

- `hyprland.luau` is a `[[service]]`, one for all bars. It follows Hyprland's
  event socket with one `socat` (`noctalia.runStream`), runs `hyprctl -j
  monitors` and `clients` after a burst of events, and publishes each monitor's
  list to plugin state. A 5 s poll covers a dead stream.
  `noctalia msg plugin roynul/workspace-apps:hyprland all status` logs
  counters, and `... all refresh` re-reads Hyprland at once.
- The plugin setting `hidden_tags` is empty by default. Set it under
  `[plugin_settings."roynul/workspace-apps"]` or in Settings → Plugins: windows
  with any of these Hyprland tags get no icon. Tags from window rules match
  without their trailing `*`. A tag change raises no Hyprland event, so after
  you change a window's tags, send `refresh` to update the bars at once
  (otherwise the 5 s poll catches it). The service applies a changed setting in
  place (`onConfigChanged`). Labels are in `translations/en.json`.
- `icons.luau` is the bar widget. It renders its monitor's list from
  `noctalia.state.watch`. A watch callback carries no bar context, so
  `barWidget.outputName()` returns nil there (`plugin_bindings.cpp`). The widget
  remembers its output from load and `update()` instead; without that, every
  bar draws the same monitor's list.

Changing `plugin.toml` needs `noctalia msg plugins disable` then `enable` for
Noctalia to re-read it.

### Plugin: workspace pills

[`plugins/workspace-pills`](plugins/workspace-pills) (Luau, v0.1) is the
workspaces widget again, animated like HyDE's waybar. It is on the bar in place
of the built-in `workspaces` (`"roynul/workspace-pills:pills"` in
`[bar.default]` `start`; a bar can name a plugin entry directly, with no
`[widget]` block). To go back, put `"workspaces"` there again.

Why: with `hide_when_empty`, the built-in widget rebuilds without its animation
snapshot when a workspace gains its first window or loses its last
(`workspaces_widget.cpp`, 5.2.1), so those pills snap in and out.

- It looks the same as the built-in widget at the `[widget.workspaces]`
  settings in `config.toml`, matched pixel for pixel: numbers by Hyprland id,
  occupied workspaces plus the active one, the active pill 2.2 x 16 px filled
  with `primary`, white digits on transparent inactive pills. The sizes are
  constants in `pills.luau`, so `[widget.workspaces]` settings do not apply to
  it.
- Motion: HyDE's `cubic-bezier(.55, -0.68, .48, 1.682)` (anticipation, then
  overshoot). The active pill widens and fills in 0.4 s. New pills grow in from
  zero width and empty ones shrink out on the same curve. Hover fades in
  `primary` at 40 % in 0.3 s. A click switches with `hyprctl eval
  'hl.dispatch(hl.dsp.focus({ workspace = N }))'`. Special workspaces never
  show.
- Bar plugins get no frame tick: the widget sets its update interval to 16 ms
  only while something moves, and back to 5 s once everything settles.
- `hyprland.luau` is a `[[service]]` like workspace-apps': `socat` on the event
  socket, then `hyprctl -j monitors` and `workspaces`. A `workspacev2` event
  moves the active pill at once, before hyprctl answers.
  `noctalia msg plugin roynul/workspace-pills:hyprland all status` logs
  counters and the published ids.
  `... all fake '{"DP-1": {"active": 3, "ids": [1, 3]}}'` shows a test state
  (until `... all real`). Without Hyprland, the service only takes `fake`.

### Update widget (Arch Updater)

A local copy of the community plugin `yuuto/arch-updater` 2.0.3, installed as
`roynul/arch-updater`. The bar's `updates` widget shows pending pacman and AUR
updates. Its panel lists both, warns about Arch news, checks, updates and rolls
back. It needs `pacman-contrib`. It checks every 4 hours
(`[plugin_settings."roynul/arch-updater"] auto_check_hours`; 0, the default,
only checks on click).

Why a copy: plugin panels attach to the bar and share its background, which is
invisible in this config, so the upstream panel is transparent. Noctalia has no
setting for plugin panel placement, and it re-copies community plugins from
their source on every start, so the change can't be patched in place. The copy
differs from upstream only in its id (in `plugin.toml`, `widget.luau`'s
`PANEL_ID` and `panel.luau`'s settings link) and in `placement = "floating"` for
its panel. To update it, copy the new upstream folder from
`~/.local/state/noctalia/plugins/materialized/community/arch-updater` (enable
the community plugin briefly to fetch it) and apply those changes again.

On CachyOS, `cachy-update` is switched off in favour of the widget. Its tray
icon is hidden by `arch-update-tray.desktop` in `~/.config/autostart`
(`Hidden=true` overrides the copy in `/etc/xdg/autostart`). Its daily check,
which the package enables for every user, is off because the timer is masked
(see Install). The package stays installed: `arch-update` in a terminal still
runs its interactive update (Arch news, `.pacnew` files, orphans, cache
cleanup).

### Lock screen

Laid out like the login screen ([`linux/sddm`](../sddm/SETUP.md)): one
1500x840 surface card on the blurred wallpaper of the main monitor (DP-1),
never a snapshot of the desktop. The card is 90% opaque (`card_alpha`), so the
blurred wallpaper shows through, as on the login screen.

- Left: weather with a 3-day forecast, and a month calendar without events.
- Centre: hours, minutes and AM/PM in "GSF Lock Clock", the date, the avatar
  cut to Material's ClamShell shape with an audio ring that fades when idle,
  the login name under it (read from the account when `gen.py` runs), and the
  password field.
- Right, in the login screen's places: a GIF card, CPU, RAM and GPU gauges
  where the login screen has its session card, and Suspend, Reboot and Shut
  down buttons (Noctalia `button` widgets that run
  `noctalia msg session <action>`).
- The side monitors show the clock group only. There is no lock or unlock
  animation.

The config is generated, not edited: [`lock/scripts/gen.py`](lock/scripts/gen.py)
turns `params.json` (sizes and opacities) into `~/.config/noctalia/lock.toml`:
the whole `[lockscreen]` and `[lockscreen_widgets]` sections plus the
`[hooks] session_unlocked` line. `lock.toml` holds absolute paths, so it is not
in this repo. To set up or change it, copy the files, edit `params.json`, and
run `~/.local/share/noctalia/lock/scripts/apply.sh`. It regenerates `lock.toml`,
strips `[lockscreen_widgets]` from `settings.toml` (`strip.py`), and restarts
Noctalia.

**GIFs**: put them in `~/Pictures/lock-gifs` (not in this repo). After every
unlock, the `session_unlocked` hook runs `reroll.py`. It picks a random GIF,
renders it once to the card's size with ffmpeg into
`~/.local/share/noctalia/lock/cards/`, and points `current.gif` at it. The lock
screen reads `current.gif` again at every lock, so no reload is needed.
`apply.sh` rerolls too. When `/var/lib/sddm-assets` exists, `reroll.py` also
copies the new card there for the login screen
([`linux/sddm`](../sddm/SETUP.md)).

It needs `python3`, `ffmpeg`, and the two fonts in
[`fonts/google-sans-flex`](fonts/google-sans-flex) (SIL Open Font License 1.1,
`LICENSE` included). "GSF Lock Clock" is a renamed instance of Google Sans Flex
at width 30, weight 500, which the licence permits. Run `fc-cache -f` after you
copy the fonts.

Things to know:

- **`settings.toml` wins.** Noctalia rewrites
  `~/.local/state/noctalia/settings.toml` whole, and a `[lockscreen_widgets]`
  in it overrides `lock.toml` entirely. Editing the lock screen in Noctalia's
  editor puts one there; `apply.sh` strips it.
- **Write config files atomically.** Noctalia watches its config directory. A
  half-written file parses without `[lockscreen_widgets]`, and the lock
  controller then saves an `enabled = false` copy to `settings.toml`. `gen.py`
  writes a temporary file and renames it.
- **Merging.** Noctalia loads every `*.toml` in `~/.config/noctalia` in name
  order, then `settings.toml`. Tables merge key by key. For the same key the
  later file wins, and arrays (such as `widget_order`) are replaced whole. So a
  `[hooks]` table in `config.toml` merges with the one in `lock.toml`, and a
  second `session_unlocked` there loses to `lock.toml`. `apply.sh` warns when
  another file sets `[lockscreen*]` or `[hooks]`. The login screen's sync adds
  no `[hooks]` key: its still rides on the `sddm` template's `post_hook`, and
  its GIF on `reroll.py`.
- **Rounded GIF corners are in the GIF.** The sticker widget has no corner
  radius, so `reroll.py` cuts the card's corners into the GIF's transparency
  with a 1-bit mask.
- **Long GIFs are cut off.** The sticker decodes at most 512 frames or 96 MiB
  of pixels (`desktop_sticker_widget.cpp`): about 163 frames at the card's
  453x340. The log then says "truncated at N frames (resource cap)".
- **Single-frame GIFs** load as plain images, not through the GIF decoder, and
  may not change when `current.gif` points to a new card.

### Colour templates

- [`templates/kitty.conf`](templates/kitty.conf): Noctalia's built-in kitty
  template, copied. It writes `~/.config/kitty/themes/noctalia.conf` (see
  [`shared/kitty`](../../shared/kitty/SETUP.md)). The built-in one also edits
  `kitty.conf`, which the Mac shares.
- [`templates/hypr-scheme.lua`](templates/hypr-scheme.lua): rewrites
  `~/.config/hypr/scheme/current.lua`, the colour file the Hyprland config
  reads (window borders, group bars, background), in the key names that config
  reads, then runs `hyprctl reload`. Noctalia's own Hyprland template only
  gives solid borders.

Each of the other templates writes a file that the app's own setting already
points at, so each file has one owner. Noctalia's built-in GTK and Qt templates
are not used: the GTK one edits `gtk.css` and gsettings (kde-gtk-config also
writes to `gtk.css`), and the Qt one merges into `kdeglobals`.

| Template | Writes | Notes |
|---|---|---|
| `spicetify.ini` | `~/.config/spicetify/Themes/noctalia/color.ini` | caelestia's Spotify scheme, next to [`spicetify-user.css`](spicetify-user.css) in a theme folder named `noctalia` (`spicetify config current_theme noctalia color_scheme noctalia`); hook `spicetify -q -n refresh` re-patches Spotify without restarting it |
| `gtk.css` | `gtk-3.0/gtk.css` and `gtk-4.0/gtk.css` | caelestia's layout with Noctalia colours; keeps `@import "thunar.css"` and kde-gtk-config's `@import 'colors.css'`. Open GTK apps pick it up on restart |
| `thunar.css` | `gtk-3.0/thunar.css` and `gtk-4.0/thunar.css` | |
| `qtengine.colors` | `~/.config/qtengine/noctalia.colors` | Noctalia's KDE colour-scheme template; `qtengine/config.json`'s `colorScheme` points at this file, `kdeglobals` is left alone |
| `btop.theme` | `~/.config/btop/themes/noctalia.theme` | the theme `btop.conf` selects ([`linux/btop`](../btop/SETUP.md)); hook `pkill -USR2 -x btop` makes a running btop reload |
| `sddm-theme.conf` | `/var/lib/sddm-assets/colours.conf` | the login screen's colours ([`linux/sddm`](../sddm/SETUP.md), How it stays in sync), in the theme's key names with the lock screen's roles; hook: `chmod 644` (the greeter runs as user `sddm`) and copy `{{ image }}`, the wallpaper the palette came from, as the login still. Until that folder exists, the log says "failed to open template output" and the hook is skipped |
| `equibop.theme.css` | `~/.config/equibop/themes/noctalia.theme.css` | Noctalia's community "Midnight" Discord theme; switch it on in Equibop → Settings → Themes. It loads its base CSS from `refact0r.github.io` |

VS Code is not themed: it keeps One Dark Pro Night Flat.

### Qt apps turn light after a Qt update

Qt apps (Dolphin and others) get their dark colours from `qtengine`, a Qt theme
engine from the AUR that is built against Qt's private API. When `qt6-base`
moves to a new version, the engine still loads but stops applying the colour
scheme, so newly started Qt apps come up light. Rebuild it, then restart the Qt
apps:

```bash
paru -S --rebuild qtengine
```

Darkly (`darkly-bin`) only uses Qt's public API and survives updates.

## Verify

```bash
./status.sh | grep -E '/noctalia/|google-sans|arch-update'   # ok on every line
noctalia config validate                        # ✓ Config is valid
noctalia msg plugins list | grep -w enabled     # roynul/workspace-apps, workspace-pills, arch-updater, k4n4t4/hypr-submap
systemctl --user is-enabled arch-update.timer   # masked
```

The bar shows at the top of the screen, with the islands listed in Bar.
