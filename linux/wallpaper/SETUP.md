# wallpaper

Live wallpapers on CachyOS: Wallpaper Engine wallpapers from the Steam Workshop,
one per monitor, played by
[linux-wallpaperengine](https://github.com/Almamu/linux-wallpaperengine).
A still frame of the main wallpaper is the shell's wallpaper: Noctalia takes
its colours and lock screen background from it, with its own wallpaper drawing
switched off ([`linux/noctalia`](../noctalia/SETUP.md)). The login screen gets the same still from
Noctalia whenever it changes ([`linux/sddm`](../sddm/SETUP.md)).

| Repo | Destination |
|---|---|
| `live-wallpaper` | `~/.local/bin/live-wallpaper` |
| `live-wallpaper.service` | `~/.config/systemd/user/` |
| `live-wallpaper-watchdog.service`, `.timer` | `~/.config/systemd/user/` |

`live-wallpaper.service` runs it with the graphical session (`live-wallpaper
--run`, in the foreground), and `Restart=always` brings it back whenever it
exits: right after login Hyprland sometimes closes the wallpaper's layer
surface while outputs and workspaces settle ("Compositor closed our LS" in the
log), and the wallpapers used to stay gone until restarted by hand. Plain
`live-wallpaper` restarts the service by hand. linux-wallpaperengine only
draws on the outputs it saw at start, so [`linux/hypr/hypr-user.lua`](../hypr/hypr-user.lua)
restarts the service on Hyprland's `monitor.added` event (`try-restart`, so not
at login): a replugged monitor, or the DisplayPort VG248, which reconnects as a
new output when the screens wake from DPMS (seen on 2026-10-08: the left
monitor came back without its wallpaper). Stop
the wallpapers with `systemctl --user stop live-wallpaper`. Output goes to the
journal: `journalctl --user -u live-wallpaper`.

## Install

1. In Steam, install **Wallpaper Engine** (Properties → Compatibility → force a
   Proton version if Steam doesn't offer it). It never needs to run here: the
   install provides the `assets` folder, and Steam downloads the Workshop
   wallpapers you subscribe to. Subscribe from its UI, then close it; it holds
   about 0.7 GB of GPU memory while open.
2. `paru -S linux-wallpaperengine-git` (AUR, maintained by the author; builds
   from source and installs into `/opt/linux-wallpaperengine`).
3. Copy `live-wallpaper` and the service into place, then
   `systemctl --user enable --now live-wallpaper.service`.
4. Make the local 1080p copy of the main video (below), then copy the watchdog
   units and run `systemctl --user enable --now live-wallpaper-watchdog.timer`.

## Picks

The list at the top of `live-wallpaper` maps monitors to wallpapers: a Workshop
ID, or the name of a local copy (below). Only connected monitors get a
wallpaper. Change a pick there, then rerun it.

| Monitor | Wallpaper | ID |
|---|---|---|
| DP-1 (main, middle) | Ayanami Rei, "effects": video, 30 fps, a local copy of Workshop `3407977762` (also the login video) | `ayanami-rei-effects` |
| HDMI-A-1 (right) | [4K]CITRUS - go to class | `2704773569` |
| DP-2 (left) | Rain 雨 [4K] | `2511663284` |

Other local copies: `ayanami-rei-minimal` (the calmer "Beneath Blue Light"
video) and `3314492008` (世界很温柔, the previous main one).

Tested on 2026-10-07 and 2026-10-12 with build r627:

| Works | Problems |
|---|---|
| Ayanami Rei 『night』 (scene, `3258032485`; lighter than a video: 5.6% CPU and 310 MiB against 7.4% and 438 MiB), Elaina (prompt box off, see below; too blue as the main one), Citrus (some character animations don't move: "Unsupported puppet model header MDLV0013"), Rain 雨 [4K], Your name, Kayn (video), Futari Dake No Hanabi (video), 世界很温柔 (video), Nami Dark Background, Frieren - Pagoda of flowers | Dream View. and Dream View. 3: stars render as lines. Nico Robin 4k: crashes on load (`json type_error.302`). Ayanami Rei 『Starry』 (`3571376089`): shader compile errors, broken. Ayanami Rei 綾波レイ・丽 (`3299982340`): partly broken |

**Video** wallpapers are plain `.mp4`/`.webm` files and play exactly as on
Windows. **Scene** wallpapers are re-implemented, so some effects are missing
or wrong. mpvpaper can play the video ones if linux-wallpaperengine ever stops
working, but it doesn't avoid the memory leak below: it draws through the same
libmpv OpenGL path, and its own issues (#101, #116, #117) report the same
growth on Hyprland with NVIDIA.

## Memory

The monitors are 1080p, so 4K wallpapers only cost memory. A 1080p copy of a
video wallpaper goes in `~/.local/share/live-wallpapers/<name>-1080p/`, outside
Steam's folder so Workshop updates or unsubscribing don't touch it;
`live-wallpaper` uses it instead of the Workshop original when it exists. The
4K original goes next to it in `<name>-4k/`, for a future 4K monitor. A copy
needs only the video and a `project.json` with `"type" : "video"` and its
`"file"`, so videos from outside the Workshop work the same way. Made with NVENC, 60 fps
kept so the same file suits mpvpaper too:

```bash
src=~/.local/share/Steam/steamapps/workshop/content/431960/3314492008
dst=~/.local/share/live-wallpapers/3314492008-1080p
mkdir -p "$dst" && cp -p "$src/project.json" "$src/preview.gif" "$dst/"
f=$(jq -r .file "$src/project.json")
ffmpeg -i "$src/$f" -vf scale=1920:1080:flags=lanczos -c:v h264_nvenc -preset p7 \
    -tune hq -rc vbr -cq 19 -b:v 0 -profile:v high -pix_fmt yuv420p -c:a copy "$dst/$f"
```

With it the process starts at about 430 MiB instead of 2 GiB or more.

linux-wallpaperengine still leaks with video wallpapers on NVIDIA, about
10 MiB a minute here (upstream issue #416, traced to mpv's OpenGL render path:
mpv issues #15099 and #8516; a fix, mpv PR #17303, is merged but not in mpv
0.41). The watchdog timer runs `live-wallpaper --if-over 1500` every 10
minutes: above 1500 MiB (PSS) it restarts the service, which flickers for
about a second. It never starts the wallpapers if they aren't running. Revisit once mpv 0.42 ships.

## Wallpaper settings

Each wallpaper's options are in `project.json` (`general.properties`) in its
Workshop folder, `~/.local/share/Steam/steamapps/workshop/content/431960/<id>/`.
Override one with `--set-property name=value` (1/0 for on/off); `live-wallpaper`
keeps them in its `PROPERTIES` list. Elaina's notice box hides itself after 5
seconds through a Wallpaper Engine script that doesn't run here, so
`fontcolorff4848bigbpromptbox=0` turns it off.

## Colours from the live wallpaper

Noctalia builds its colours from its own wallpaper setting, not from what
linux-wallpaperengine draws. Give it a still frame of the main wallpaper; the
stills live in `~/Pictures/Wallpapers/live/` (not in this repo):

```bash
noctalia msg wallpaper-set ~/Pictures/Wallpapers/live/ayanami-rei.jpg
```

Ways to get a still:
- **Scene:** `linux-wallpaperengine --window 0x0x1920x1080 --screenshot out.png --screenshot-delay 30 <id>`.
  The file is 1920x1080 even though Hyprland tiles the window. It keeps
  running afterwards, so wrap it in `timeout 25`. Elaina crashes in window mode.
- **Video:** `ffmpeg -ss 1.5 -i <video> -frames:v 1 out.png`.
- **What the monitor shows:** switch it to an empty workspace, `grim -o DP-1`,
  then crop off the bar (caelestia's took 60 px left, 10 px elsewhere, plus a
  little for the rounded corners). Used for Elaina.

In dark mode the accents are always a light tone of the wallpaper's main hue,
so a red wallpaper gives pink accents whatever the scheme variant.

## Things to know

- **Layers:** linux-wallpaperengine uses the `bottom` layer, so it stays below
  windows and above any shell wallpaper on `background`. Noctalia's wallpaper
  drawing is off, so stopping linux-wallpaperengine
  (`pkill -f '^\./linux-wallpaperengine'`) leaves the plain background.
- **Performance** for two screens: about 6% of one CPU core, 0.7 GB RAM and
  1.1 GB of GPU memory on the RTX 5070. It runs at 30 fps and pauses while an app
  is fullscreen.
- **Preview** a wallpaper in a window: `linux-wallpaperengine --silent <id>`.
- **Login screen:** the SDDM theme can loop a video too; see [`linux/sddm`](../sddm/SETUP.md).

## Verify

```bash
./status.sh | grep live-wallpaper   # ok on all four lines
systemctl --user is-active live-wallpaper.service live-wallpaper-watchdog.timer   # active, twice
pgrep -af '^\./linux-wallpaperengine' | grep -o -- '--screen-root [^ ]*'          # one line per connected monitor
```

Every connected monitor plays its wallpaper from "Picks".
