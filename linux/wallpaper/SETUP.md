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
comes with CachyOS's gaming bundle (`cachyos-gaming-meta`). `grim` is
optional: it takes a still of what a monitor shows.

1. In Steam, install **Wallpaper Engine** (Properties → Compatibility → force a
   Proton version if Steam doesn't offer it). It never needs to run on Linux:
   the install provides the `assets` folder, and Steam downloads the Workshop
   wallpapers you subscribe to. Subscribe from its UI, then close it; it holds
   about 0.7 GB of GPU memory while open.
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
Override one with a `property name=value` line in the picks file (1/0 for
on/off); `live-wallpaper` passes each to every wallpaper as `--set-property`.
linux-wallpaperengine doesn't run Wallpaper Engine scripts, so an element that
a script hides after a few seconds stays on screen; turn it off with its
property.

### Things to know

- **Layers:** linux-wallpaperengine uses the `bottom` layer, so it stays below
  windows and above any shell wallpaper on `background`. Noctalia's wallpaper
  drawing is off, so stopping linux-wallpaperengine
  (`pkill -f '^\./linux-wallpaperengine'`) leaves the plain background.
- **Accents:** in dark mode the accents are always a light tone of the
  wallpaper's main hue, so a red wallpaper gives pink accents whatever the
  scheme variant.
- **Performance**, measured with two monitors on an NVIDIA RTX 5070: about 6% of one CPU
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

Every connected monitor plays its wallpaper from the picks file.
