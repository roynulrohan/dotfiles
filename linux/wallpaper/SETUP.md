# Live wallpapers

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

Outside the repo: your picks in `~/.config/live-wallpaper/picks` (Notes,
"Picks"), the local wallpaper copies in
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
comes with CachyOS's gaming bundle (`cachyos-gaming-applications`). `grim` is
optional: it takes a still of what a monitor shows.

1. In Steam, install **Wallpaper Engine** (Properties → Compatibility → force a
   Proton version if Steam doesn't offer it). It never needs to run on Linux:
   the install provides the `assets` folder, and Steam downloads the Workshop
   wallpapers you subscribe to. Subscribe from its UI, then close it, because
   it holds GPU memory while it is open.
2. Write your picks to `~/.config/live-wallpaper/picks` (Notes, "Picks").
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
id=1234567890   # the Workshop ID
src=~/.local/share/Steam/steamapps/workshop/content/431960/$id
dst=~/.local/share/live-wallpapers/$id-1080p
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
noctalia msg wallpaper-set ~/Pictures/Wallpapers/live/<your-still>.jpg
```

Ways to get a still:

- **Scene:** `linux-wallpaperengine --window 0x0x1920x1080 --screenshot out.png --screenshot-delay 30 <id>`.
  The file is 1920x1080 even though Hyprland tiles the window. It keeps
  running afterwards, so wrap it in `timeout 25`.
- **Video:** `ffmpeg -ss 1.5 -i <video> -frames:v 1 out.png`.
- **What the monitor shows:** switch it to an empty workspace, `grim -o DP-1`,
  then crop off the bar and the rounded corners. Use this for a wallpaper that
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

`~/.config/live-wallpaper/picks` maps monitors to wallpapers. It stays on
each machine, so changing a wallpaper needs no commit. One line per monitor:
the output name (`hyprctl monitors`), a Workshop ID or the name of a local
copy, and an optional title. Lines starting with `#` are comments, and
`property` lines set wallpaper options (see Wallpaper settings):

```
# monitor  wallpaper   title
DP-1       1234567890  Main monitor
HDMI-A-1   my-video    A local copy
property   name=0
```

Only connected monitors get a wallpaper. Edit the file, then run
`live-wallpaper` to apply it. Without the file, the service exits with a
message in the journal.

### Video and scene wallpapers

Video wallpapers are plain `.mp4` and `.webm` files and play as on Windows.
linux-wallpaperengine re-implements scene wallpapers, so some of their effects
are missing or wrong.

mpvpaper can play the video wallpapers if linux-wallpaperengine stops working.
It does not fix the memory leak below: it uses the same libmpv render path and
leaks the same way.

### Memory

Use a local 1080p copy on a 1080p monitor. The process then starts at about
430 MiB. With the 4K original it starts at 2 GiB or more.

On an NVIDIA GPU, video wallpapers leak about 10 MiB a minute in mpv's OpenGL
render path (linux-wallpaperengine issue #416). The watchdog timer runs
`live-wallpaper --if-over 1500` every 10 minutes. Above 1500 MiB (PSS), it
restarts the service, and the screens flicker for about a second. It never
starts wallpapers that are not running. mpv PR #17303 fixes the leak. When
mpv 0.42 or later is installed, check the memory, then remove the watchdog if
the leak is gone.

### Wallpaper settings

Each wallpaper's options are in `general.properties` of the `project.json` in
its Workshop folder,
`~/.local/share/Steam/steamapps/workshop/content/431960/<id>/`. To override
one, add a `property name=value` line to the picks file. Use 1 for on and 0
for off. `live-wallpaper` passes each line to every wallpaper as
`--set-property`.

linux-wallpaperengine does not run Wallpaper Engine scripts. An element that a
script hides after a few seconds stays on the screen. Turn it off with its
property.

### Things to know

- linux-wallpaperengine draws on the `bottom` layer, below the windows.
  Noctalia does not draw a wallpaper, so
  `pkill -f '^\./linux-wallpaperengine'` leaves the plain background.
- linux-wallpaperengine pauses while an app is fullscreen.
- To preview a wallpaper in a window: `linux-wallpaperengine --silent <id>`.

## Verify

```bash
./status.sh | grep live-wallpaper   # ok on all four lines
systemctl --user is-active live-wallpaper.service live-wallpaper-watchdog.timer   # active, twice
pgrep -af '^\./linux-wallpaperengine' | grep -o -- '--screen-root [^ ]*'          # one line per connected monitor
```

Every connected monitor plays its wallpaper from the picks file.
