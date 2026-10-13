# wallpaper

Live wallpapers on CachyOS: Wallpaper Engine wallpapers from the Steam
Workshop, one per monitor, played by
[linux-wallpaperengine](https://github.com/Almamu/linux-wallpaperengine). A
still frame of the main wallpaper is the shell's wallpaper: Noctalia takes its
colours and lock screen background from it, with its own wallpaper drawing
switched off ([`linux/noctalia`](../noctalia/SETUP.md)). The login screen gets
the same still from Noctalia whenever it changes ([`linux/sddm`](../sddm/SETUP.md)).

## Files

| Repo | Destination |
|---|---|
| [`live-wallpaper`](live-wallpaper) | `~/.local/bin/live-wallpaper` |
| [`live-wallpaper.service`](live-wallpaper.service) | `~/.config/systemd/user/` |
| [`live-wallpaper-watchdog.service`](live-wallpaper-watchdog.service), [`.timer`](live-wallpaper-watchdog.timer) | `~/.config/systemd/user/` |

Outside the repo: the local wallpaper copies in
`~/.local/share/live-wallpapers/` (Install, "Local 1080p copies") and the
stills in `~/Pictures/Wallpapers/live/` (Install, "A still for Noctalia").

## Install

On CachyOS/Arch:

```bash
paru -S linux-wallpaperengine-git   # AUR
sudo pacman -S jq ffmpeg
```

`linux-wallpaperengine-git` is maintained by the author. It builds from source
and installs into `/opt/linux-wallpaperengine`. `live-wallpaper` reads the
monitor list with `jq`. `ffmpeg` makes the local copies and the stills. Steam
comes with CachyOS's gaming bundle (`cachyos-gaming-meta`). `grim` is
optional: it takes a still of what a monitor shows.

1. In Steam, install **Wallpaper Engine** (Properties → Compatibility → force a
   Proton version if Steam doesn't offer it). It never needs to run on Linux:
   the install provides the `assets` folder, and Steam downloads the Workshop
   wallpapers you subscribe to. Subscribe from its UI, then close it; it holds
   about 0.7 GB of GPU memory while open.
2. Set the picks at the top of `live-wallpaper` for your monitors (Notes,
   "Picks").
3. Copy `live-wallpaper` and the service into place, then
   `systemctl --user enable --now live-wallpaper.service`.
4. Make the local 1080p copy of the main video (below), then copy the watchdog
   units and run `systemctl --user enable --now live-wallpaper-watchdog.timer`.
5. Give Noctalia a still of the main wallpaper (below).

### Local 1080p copies

A 1080p copy of a video wallpaper goes in
`~/.local/share/live-wallpapers/<name>-1080p/`, outside Steam's folder, so
Workshop updates or unsubscribing don't touch it. `live-wallpaper` uses it
instead of the Workshop original when it exists. The 4K original goes next to
it in `<name>-4k/`, for a 4K monitor later. A copy needs only the video and a
`project.json` with `"type" : "video"` and its `"file"`, so videos from
outside the Workshop work the same way. This example encodes with NVENC (an
NVIDIA GPU) and keeps 60 fps, so the same file suits mpvpaper too:

```bash
src=~/.local/share/Steam/steamapps/workshop/content/431960/3314492008
dst=~/.local/share/live-wallpapers/3314492008-1080p
mkdir -p "$dst" && cp -p "$src/project.json" "$src/preview.gif" "$dst/"
f=$(jq -r .file "$src/project.json")
ffmpeg -i "$src/$f" -vf scale=1920:1080:flags=lanczos -c:v h264_nvenc -preset p7 \
    -tune hq -rc vbr -cq 19 -b:v 0 -profile:v high -pix_fmt yuv420p -c:a copy "$dst/$f"
```

### A still for Noctalia

Noctalia builds its colours from its own wallpaper setting, not from what
linux-wallpaperengine draws. Give it a still frame of the main wallpaper. The
stills live in `~/Pictures/Wallpapers/live/` (not in this repo):

```bash
noctalia msg wallpaper-set ~/Pictures/Wallpapers/live/ayanami-rei.jpg
```

Ways to get a still:

- **Scene:** `linux-wallpaperengine --window 0x0x1920x1080 --screenshot out.png --screenshot-delay 30 <id>`.
  The file is 1920x1080 even though Hyprland tiles the window. It keeps
  running afterwards, so wrap it in `timeout 25`.
- **Video:** `ffmpeg -ss 1.5 -i <video> -frames:v 1 out.png`.
- **What the monitor shows:** switch it to an empty workspace, `grim -o DP-1`,
  then crop off the bar and the rounded corners. Use this for Elaina, which
  crashes in window mode.

## Notes

`live-wallpaper.service` runs the script with the graphical session
(`live-wallpaper --run`, in the foreground). `Restart=always` brings it back
whenever it exits: right after login, Hyprland sometimes closes the
wallpaper's layer surface while outputs and workspaces settle ("Compositor
closed our LS" in the log). Plain `live-wallpaper` restarts the service by
hand. linux-wallpaperengine only draws on the outputs it saw at start, so
[`linux/hypr/hypr-user.lua`](../hypr/hypr-user.lua) restarts the service on
Hyprland's `monitor.added` event (`try-restart`, so not at login). That covers
a replugged monitor, and a DisplayPort monitor that reconnects as a new output
when the screens wake from DPMS. Stop the wallpapers with
`systemctl --user stop live-wallpaper`. Output goes to the journal:
`journalctl --user -u live-wallpaper`.

### Picks

The list at the top of `live-wallpaper` maps monitors to wallpapers: a Workshop
ID, or the name of a local copy. Only connected monitors get a wallpaper.
Change a pick there, then rerun it.

| Monitor | Wallpaper | ID |
|---|---|---|
| DP-1 (main, middle) | Ayanami Rei, "effects": video, 30 fps, a local copy of Workshop `3407977762` (also the login video) | `ayanami-rei-effects` |
| HDMI-A-1 (right) | [4K]CITRUS - go to class | `2704773569` |
| DP-2 (left) | Rain 雨 [4K] | `2511663284` |

### What works

Tested with build r627:

| Works | Problems |
|---|---|
| Ayanami Rei 『night』 (scene, `3258032485`; lighter than a video: 5.6% CPU and 310 MiB against 7.4% and 438 MiB), Elaina (prompt box off, see "Wallpaper settings"), Citrus (some character animations don't move: "Unsupported puppet model header MDLV0013"), Rain 雨 [4K], Your name, Kayn (video), Futari Dake No Hanabi (video), 世界很温柔 (video), Nami Dark Background, Frieren - Pagoda of flowers | Dream View. and Dream View. 3: stars render as lines. Nico Robin 4k: crashes on load (`json type_error.302`). Ayanami Rei 『Starry』 (`3571376089`): shader compile errors, broken. Ayanami Rei 綾波レイ・丽 (`3299982340`): partly broken |

**Video** wallpapers are plain `.mp4`/`.webm` files and play exactly as on
Windows. **Scene** wallpapers are re-implemented, so some effects are missing
or wrong. mpvpaper can play the video ones if linux-wallpaperengine stops
working. It doesn't avoid the memory leak below: it draws through the same
libmpv OpenGL path, and its own issues (#101, #116, #117) report the same
growth on Hyprland with NVIDIA.

### Memory

On 1080p monitors a 4K wallpaper only costs memory. With a local 1080p copy
the process starts at about 430 MiB instead of 2 GiB or more.

With an NVIDIA GPU, linux-wallpaperengine leaks about 10 MiB a minute with
video wallpapers (upstream issue #416, traced to mpv's OpenGL render path: mpv
issues #15099 and #8516). The fix, mpv PR #17303, is merged but not in mpv
0.41. The watchdog timer runs `live-wallpaper --if-over 1500` every 10
minutes: above 1500 MiB (PSS) it restarts the service, which flickers for
about a second. It never starts the wallpapers if they aren't running. Check
whether the watchdog is still needed once mpv 0.42 ships.

### Wallpaper settings

Each wallpaper's options are in `project.json` (`general.properties`) in its
Workshop folder, `~/.local/share/Steam/steamapps/workshop/content/431960/<id>/`.
Override one with `--set-property name=value` (1/0 for on/off); `live-wallpaper`
keeps them in its `PROPERTIES` list. Elaina's notice box hides itself after 5
seconds through a Wallpaper Engine script that linux-wallpaperengine doesn't
run, so
`fontcolorff4848bigbpromptbox=0` turns it off.

### Things to know

- **Layers:** linux-wallpaperengine uses the `bottom` layer, so it stays below
  windows and above any shell wallpaper on `background`. Noctalia's wallpaper
  drawing is off, so stopping linux-wallpaperengine
  (`pkill -f '^\./linux-wallpaperengine'`) leaves the plain background.
- **Accents:** in dark mode the accents are always a light tone of the
  wallpaper's main hue, so a red wallpaper gives pink accents whatever the
  scheme variant.
- **Performance** with two screens on an NVIDIA RTX 5070: about 6% of one CPU
  core, 0.7 GB RAM and 1.1 GB of GPU memory. It runs at 30 fps and pauses while
  an app is fullscreen.
- **Preview** a wallpaper in a window: `linux-wallpaperengine --silent <id>`.
- **Login screen:** the SDDM theme can loop a video too; see
  [`linux/sddm`](../sddm/SETUP.md).

## Verify

```bash
./status.sh | grep live-wallpaper   # ok on all four lines
systemctl --user is-active live-wallpaper.service live-wallpaper-watchdog.timer   # active, twice
pgrep -af '^\./linux-wallpaperengine' | grep -o -- '--screen-root [^ ]*'          # one line per connected monitor
```

Every connected monitor plays its wallpaper from "Picks".
