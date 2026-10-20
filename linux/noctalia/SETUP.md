# Noctalia

Noctalia is the desktop shell: the bar at the top, launcher, notifications,
lock screen, idle timers, on-screen pop-ups, control centre, clipboard history
and screenshots. Docs: [docs.noctalia.dev](https://docs.noctalia.dev/).

## Files

| Repo | Destination |
|---|---|
| [`config.toml`](config.toml) | `~/.config/noctalia/config.toml` |
| [`templates/`](templates) | `~/.config/noctalia/templates/` (see Colour templates) |
| [`plugins/workspace-apps/`](plugins/workspace-apps/README.md) | `~/.local/share/noctalia/plugins/workspace-apps/` (see Plugins) |
| [`plugins/workspace-pills/`](plugins/workspace-pills/README.md) | `~/.local/share/noctalia/plugins/workspace-pills/` (see Plugins) |
| [`plugins/arch-updater/`](plugins/arch-updater/README.md) | `~/.local/share/noctalia/plugins/arch-updater/` (see Update widget) |
| [`arch-update-tray.desktop`](arch-update-tray.desktop) | `~/.config/autostart/arch-update-tray.desktop` (see Update widget) |
| [`spicetify-user.css`](spicetify-user.css) | `~/.config/spicetify/Themes/noctalia/user.css` (the Spotify theme's CSS; the `spicetify.ini` template writes its colours) |
| [`lock/scripts/`](lock/scripts) | `~/.local/share/noctalia/lock/scripts/` (see Lock screen; `apply.sh` is executable) |
| [`fonts/google-sans-flex/`](fonts/google-sans-flex) | `~/.local/share/fonts/google-sans-flex/` |

Files that are not in the repo:

- `~/.local/state/noctalia/settings.toml`: what Noctalia's settings window
  saves. It loads last and wins (see Config).
- `~/.config/noctalia/lock.toml`: the lock screen config. `gen.py` generates
  it, and it holds absolute paths.
- `~/Pictures/lock-gifs`: the GIFs for the lock screen's GIF card.
- `~/Pictures/lock-avatar.png`: the lock screen's avatar, a transparent PNG
  already cut to shape. The sticker draws it at 315x215.
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

If you use spicetify, select the theme folder that the `spicetify.ini`
template writes:

```bash
spicetify config current_theme noctalia color_scheme noctalia
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

Noctalia loads every `*.toml` in `~/.config/noctalia` in name order, then
`~/.local/state/noctalia/settings.toml`. Tables merge key by key. For the same
key the later file wins, and an array (such as `widget_order`) is replaced
whole. Noctalia never rewrites the config files. Its settings window saves to
`settings.toml`. Check the config with `noctalia config validate`. Apply it
with `noctalia msg config-reload`. The log is `~/.cache/noctalia/noctalia.log`.

The comments in [`config.toml`](config.toml) explain its values.

- **Colours** come from the wallpaper, and every template follows the palette.
  Change the scheme or the wallpaper in Noctalia's settings at any time.
  Noctalia saves that in `settings.toml`, so `config.toml` holds only the
  first-run default. In dark mode the accents are always a light tone of the
  wallpaper's main hue, so a red wallpaper gives pink accents in every scheme.
- **Screenshots** open in Noctalia's editor first. Enter or Done copies, Save
  writes to `~/Pictures/Screenshots`, and Esc discards. In the region overlay,
  Ctrl+C and Ctrl+S skip the editor.
- **Launcher actions**: type `/cmd` to list Restart audio, Restart shell,
  Reload Hyprland, Restart wallpapers, Night light off, Night light on and
  Battery. They also match by name in a normal search. Use Restart audio when a
  USB headset reconnects and PipeWire keeps failing on the old device.
  Shutdown, lock and the other session actions are in `/session`.
- **Night light**: the Night Light toggle in the control centre is Noctalia's
  own and stays off. The night light that runs is hyprsunset
  ([`linux/hyprsunset`](../hyprsunset/SETUP.md)). Use the `/cmd` actions.
- **Login screen**: SDDM with this repo's `noctalia-card` theme
  ([`linux/sddm`](../sddm/SETUP.md)). It follows Noctalia's palette, wallpaper
  and lock GIF.

### Bar

The bar itself is invisible (`background_opacity = 0`). Each widget or group is
a rounded island at 80% opacity, and Hyprland's layer rule blurs them
([`linux/hypr`](../hypr/SETUP.md)). The bar uses the window grid's 4 px unit
(see "Look" in [`linux/hypr/SETUP.md`](../hypr/SETUP.md)). The islands, left,
middle and right, separated by `|`:

stats (CPU, RAM, CPU and GPU temperature) · workspaces · submap | app icons |
media · signal (network, volume) · updates · tray · clock · system (caffeine,
notifications, wallpaper, control centre; right-click the bell for do not
disturb) · power

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

### Plugins

- **workspace-apps**
  ([`plugins/workspace-apps`](plugins/workspace-apps/README.md)): the app
  icons of the windows on the current workspace of the bar's monitor. It
  replaces the built-in `taskbar`.
- **workspace-pills**
  ([`plugins/workspace-pills`](plugins/workspace-pills/README.md)): the
  workspace numbers, animated like HyDE's waybar. It replaces the built-in
  `workspaces`.
- **hypr-submap** (`k4n4t4/hypr-submap` 1.0.0, MIT, a community plugin): an
  island that reads "window" while window mode (Super+A,
  [`linux/hypr`](../hypr/SETUP.md)) is on. Click it to leave the mode. It reads
  Hyprland's event socket with `socat`, and runs only `hyprctl submap` and
  `hyprctl dispatch 'hl.dsp.submap("reset")'`.
  Version 1.0.0 was reviewed for this.
- **arch-updater**: see Update widget.

After you change a local plugin's `plugin.toml`, run
`noctalia msg plugins disable <id>` and then `enable`. Noctalia reads the file
again only then.

### Update widget (Arch Updater)

[`plugins/arch-updater`](plugins/arch-updater/README.md) is a local copy of the
community plugin `yuuto/arch-updater` 2.0.3, with the id `roynul/arch-updater`.
The bar's `updates` widget shows pending pacman and AUR updates. Its panel
lists them, warns about Arch news, and checks, updates and rolls back.

Why a copy: a plugin panel attaches to the bar and shares its background, which
is invisible in this config, so the upstream panel is transparent. Noctalia has
no setting for plugin panel placement, and it copies community plugins again
from their source at every start. The copy differs from upstream only in its
id (in `plugin.toml`, `widget.luau`'s `PANEL_ID` and `panel.luau`'s settings
link) and in `placement = "floating"` for its panel. Keep the copy until
Noctalia can float a plugin panel.

To update it, enable the community plugin briefly to fetch it. Copy the new
folder from `~/.local/state/noctalia/plugins/materialized/community/arch-updater`,
then apply those changes again.

On CachyOS, the widget replaces `cachy-update`. `arch-update-tray.desktop`
hides its tray icon: `Hidden=true` overrides the copy in `/etc/xdg/autostart`.
The masked timer stops its daily check (see Install). Keep the package:
`arch-update` in a terminal still runs its interactive update.

### Lock screen

The lock screen looks like the login screen ([`linux/sddm`](../sddm/SETUP.md)).
It is one 1500x840 card on the blurred wallpaper of the main monitor (DP-1),
never a snapshot of the desktop. The card is 90% opaque (`card_alpha`). The
layout and the centre clock follow caelestia's lock screen.

- Left: the weather with a 3-day forecast, and a month calendar.
- Centre: the clock in "GSF Lock Clock", the date, your avatar
  (`~/Pictures/lock-avatar.png`) with an audio ring, the login name and the
  password field.
- Right: a GIF card, CPU, RAM and GPU gauges, and Suspend, Reboot and Shut down
  buttons.
- The side monitors show only the clock and the date.

The config is generated: [`lock/scripts/gen.py`](lock/scripts/gen.py) turns
`params.json` (sizes and opacities) into `~/.config/noctalia/lock.toml`. That
file holds the `[lockscreen]` and `[lockscreen_widgets]` sections and the
`[hooks] session_unlocked` line. To change the lock screen, edit `params.json`
and run `~/.local/share/noctalia/lock/scripts/apply.sh`. It regenerates
`lock.toml`, strips `[lockscreen_widgets]` from `settings.toml` (`strip.py`),
and restarts Noctalia.

**GIFs**: put them in `~/Pictures/lock-gifs` (not in this repo). After every
unlock, the `session_unlocked` hook runs `reroll.py`. It picks a random GIF,
renders it once to the card's size into `~/.local/share/noctalia/lock/cards/`,
and points `current.gif` at it. The lock screen reads `current.gif` again at
every lock, so no reload is necessary. `apply.sh` rerolls too. When
`/var/lib/sddm-assets` exists, `reroll.py` also copies the new card there for
the login screen ([`linux/sddm`](../sddm/SETUP.md)).

**Fonts**: the lock screen uses the two fonts in
[`fonts/google-sans-flex`](fonts/google-sans-flex) (SIL Open Font License 1.1,
`LICENSE` included). "GSF Lock Clock" is a renamed instance of Google Sans Flex
at width 30 and weight 500, which the licence permits. Run `fc-cache -f` after
you copy the fonts.

Things to know:

- **`settings.toml` wins.** Noctalia rewrites
  `~/.local/state/noctalia/settings.toml` whole, and a `[lockscreen_widgets]`
  in it overrides `lock.toml` entirely. Editing the lock screen in Noctalia's
  editor puts one there. Run `apply.sh` to strip it.
- **Keep `[lockscreen*]` and `[hooks]` in `lock.toml` only.** The same key in
  another config file mixes with it or overrides it. `apply.sh` warns when
  another file sets them.
- **Long GIFs are cut off.** The sticker decodes at most 512 frames or 96 MiB
  of pixels: about 163 frames at the card's 453x340. The log then says
  "truncated at N frames (resource cap)".
- **Single-frame GIFs** load as plain images, not through the GIF decoder, and
  may not change when `current.gif` points to a new card.

### Colour templates

- [`templates/kitty.conf`](templates/kitty.conf): a copy of Noctalia's
  built-in kitty template. It writes `~/.config/kitty/themes/noctalia.conf`
  (see [`shared/kitty`](../../shared/kitty/SETUP.md)). The built-in one also
  edits `kitty.conf`, which the Mac shares.
- [`templates/hypr-scheme.lua`](templates/hypr-scheme.lua): rewrites
  `~/.config/hypr/scheme/current.lua`, the colour file that the Hyprland config
  reads (window borders, group bars, background), then runs `hyprctl reload`.
  Noctalia's own Hyprland template gives only solid borders.

Each of the other templates writes a file that the app's own setting already
points at, so each file has one owner. Noctalia's built-in GTK and Qt templates
are not used: the GTK one edits `gtk.css` and gsettings (kde-gtk-config also
writes to `gtk.css`), and the Qt one merges into `kdeglobals`.

| Template | Writes | Notes |
|---|---|---|
| `spicetify.ini` | `~/.config/spicetify/Themes/noctalia/color.ini` | The Spotify colours, next to [`spicetify-user.css`](spicetify-user.css). The hook `spicetify -q -n refresh` patches Spotify again without a restart |
| `gtk.css` | `gtk-3.0/gtk.css` and `gtk-4.0/gtk.css` | Keeps `@import "thunar.css"` and kde-gtk-config's `@import 'colors.css'`. Open GTK apps pick it up on restart |
| `thunar.css` | `gtk-3.0/thunar.css` and `gtk-4.0/thunar.css` | |
| `qtengine.colors` | `~/.config/qtengine/noctalia.colors` | `qtengine/config.json`'s `colorScheme` points at this file. `kdeglobals` stays untouched |
| `btop.theme` | `~/.config/btop/themes/noctalia.theme` | The theme `btop.conf` selects ([`linux/btop`](../btop/SETUP.md)). The hook `pkill -USR2 -x btop` makes a running btop reload |
| `sddm-theme.conf` | `/var/lib/sddm-assets/colours.conf` | The login screen's colours ([`linux/sddm`](../sddm/SETUP.md), How it stays in sync). The hook copies the wallpaper the palette came from as the login still. Until that folder exists, the log says "failed to open template output" and the hook is skipped |
| `rgb-accent.txt` | `~/.config/case-lights/accent` | The accent colour as plain hex, for [`linux/case-lights`](../case-lights/SETUP.md). No hook: case-lights reads the file every second |
| `equibop.theme.css` | `~/.config/equibop/themes/noctalia.theme.css` | Noctalia's community "Midnight" Discord theme. To switch it on, open Equibop's Settings, then Themes. It loads its base CSS from `refact0r.github.io` |

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
