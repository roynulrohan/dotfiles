# wallpaper

Live wallpapers on CachyOS: Wallpaper Engine wallpapers from the Steam Workshop,
one per monitor, played by
[linux-wallpaperengine](https://github.com/Almamu/linux-wallpaperengine).
caelestia's own wallpaper stays underneath as a still frame: it drives the
dynamic colour scheme, the lock screen and the login screen, and it shows if
the live wallpaper isn't running.

| Repo | Destination |
|---|---|
| `live-wallpaper` | `~/.local/bin/live-wallpaper` |

`linux/caelestia/hypr-user.lua` runs it once when Hyprland starts. Run
`live-wallpaper` again to restart the wallpapers, e.g. after plugging a monitor
in. It logs to `~/.cache/live-wallpaper.log`.

## Install

1. In Steam, install **Wallpaper Engine** (Properties → Compatibility → force a
   Proton version if Steam doesn't offer it). It never needs to run here: the
   install provides the `assets` folder, and Steam downloads the Workshop
   wallpapers you subscribe to. Subscribe from its UI, then close it; it holds
   about 0.7 GB of GPU memory while open.
2. `paru -S linux-wallpaperengine-git` (AUR, maintained by the author; builds
   from source and installs into `/opt/linux-wallpaperengine`).
3. Copy `live-wallpaper` into place and log in again, or run it.

## Picks

The list at the top of `live-wallpaper` maps monitors to Workshop IDs; only
connected monitors get a wallpaper. Change a pick there, then rerun it.

| Monitor | Wallpaper | ID |
|---|---|---|
| DP-1 (main, middle) | 世界很温柔 (Eri Uesugi), video, 4K 60 fps | `3314492008` |
| HDMI-A-1 (right) | [4K]CITRUS - go to class | `2704773569` |
| DP-2 (left) | Rain 雨 [4K] | `2511663284` |

Tested on 2026-10-07 with build r627:

| Works | Problems |
|---|---|
| Elaina (prompt box off, see below; too blue as the main one), Citrus (some character animations don't move: "Unsupported puppet model header MDLV0013"), Rain 雨 [4K], Your name, Kayn (video), Futari Dake No Hanabi (video), 世界很温柔 (video), Nami Dark Background, Frieren - Pagoda of flowers | Dream View. and Dream View. 3: stars render as lines. Nico Robin 4k: crashes on load (`json type_error.302`) |

**Video** wallpapers are plain `.mp4`/`.webm` files and play exactly as on
Windows. **Scene** wallpapers are re-implemented, so some effects are missing
or wrong. mpvpaper can play the video ones if linux-wallpaperengine ever stops
working.

## Wallpaper settings

Each wallpaper's options are in `project.json` (`general.properties`) in its
Workshop folder, `~/.local/share/Steam/steamapps/workshop/content/431960/<id>/`.
Override one with `--set-property name=value` (1/0 for on/off); `live-wallpaper`
keeps them in its `PROPERTIES` list. Elaina's notice box hides itself after 5
seconds through a Wallpaper Engine script that doesn't run here, so
`fontcolorff4848bigbpromptbox=0` turns it off.

## Colours from the live wallpaper

caelestia builds the scheme from its own wallpaper, not from what
linux-wallpaperengine draws. Give it a still frame of the main wallpaper; the
stills live in `~/Pictures/Wallpapers/live/` (not in this repo):

```bash
caelestia wallpaper -f ~/Pictures/Wallpapers/live/eri-uesugi.png -N   # -N keeps dark mode
```

Ways to get a still:
- **Scene:** `linux-wallpaperengine --window 0x0x1920x1080 --screenshot out.png --screenshot-delay 30 <id>`.
  The file is 1920x1080 even though Hyprland tiles the window. It keeps
  running afterwards, so wrap it in `timeout 25`. Elaina crashes in window mode.
- **Video:** `ffmpeg -ss 1.5 -i <video> -frames:v 1 out.png`.
- **What the monitor shows:** switch it to an empty workspace, `grim -o DP-1`,
  then crop off caelestia's bar and frame (60 px left, 10 px elsewhere, plus a
  little for the rounded corners). Used for Elaina.

In dark mode the accents are always a light tone of the wallpaper's main hue,
so a red wallpaper gives pink accents whatever the scheme variant.

## Things to know

- **Layers:** caelestia draws its wallpaper on the `background` layer;
  linux-wallpaperengine uses `bottom`, one above, so it covers it and stays below
  windows. Stopping it (`pkill -f '^\./linux-wallpaperengine'`) shows
  caelestia's still again.
- **Performance** for two screens: about 6% of one CPU core, 0.7 GB RAM and
  1.1 GB of GPU memory on the RTX 5070. It runs at 30 fps and pauses while an app
  is fullscreen.
- **Preview** a wallpaper in a window: `linux-wallpaperengine --silent <id>`.
- **Login screen:** the SDDM theme can loop a video too; see `linux/sddm`.
