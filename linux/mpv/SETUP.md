# mpv

The video player and the default image viewer on CachyOS. Videos get
[uosc](https://github.com/tomasklaen/uosc) controls with
[thumbfast](https://github.com/po5/thumbfast) timeline thumbnails; images get
their own bindings. Gwenview stays installed for editing and for SVG.

## Files

| Repo | Destination |
|---|---|
| [`mpv.conf`](mpv.conf) | `~/.config/mpv/mpv.conf` |
| [`input.conf`](input.conf) | `~/.config/mpv/input.conf` |
| [`mpv-image.desktop`](mpv-image.desktop) | `~/.local/share/applications/mpv-image.desktop` |
| [`scripts/dolphin-sort.lua`](scripts/dolphin-sort.lua) | `~/.config/mpv/scripts/dolphin-sort.lua` |
| [`script-opts/uosc.conf`](script-opts/uosc.conf) | `~/.config/mpv/script-opts/uosc.conf` |
| [`script-opts/thumbfast.conf`](script-opts/thumbfast.conf) | `~/.config/mpv/script-opts/thumbfast.conf` |

## Install

On CachyOS/Arch:

```bash
sudo pacman -S mpv gwenview attr
paru -S mpv-uosc mpv-thumbfast-git   # AUR
```

mpv must be 0.40 or newer, for its built-in `positioning` script. `attr`
provides `getfattr`, which `dolphin-sort.lua` needs. Gwenview opens SVG and
edits images.

After copying, make mpv the default for images and videos. `mpv.desktop`
declares no image types, so KDE doesn't accept it as their default;
`mpv-image.desktop` declares them.

```bash
for t in $(grep '^MimeType=' ~/.local/share/applications/mpv-image.desktop | cut -d= -f2 | tr ';' ' '); do
    xdg-mime default mpv-image.desktop "$t"; done
for t in $(grep '^MimeType=' /usr/share/applications/mpv.desktop | cut -d= -f2 | tr ';' '\n' | grep '^video/'); do
    xdg-mime default mpv.desktop "$t"; done
xdg-mime default org.kde.gwenview.desktop image/svg+xml  # mpv rasterises SVG once, so it blurs when zoomed
kbuildsycoca6                                           # Dolphin sees the change now
```

Run `xdg-mime default` once per type. Given several types at once, it writes
them all into one broken line of `~/.config/mimeapps.list`.

`dolphin-sort.lua` follows Dolphin's sort order (Notes, "Next / previous in
Dolphin's order"): a folder's own view settings when Dolphin remembers them
per folder (Configure → View → General → **Remember display style for each
folder**), otherwise Dolphin's global default.

## Notes

### mpv.conf

- Start at 30% volume, cap at 100, resume where you stopped, loop single
  files.
- Decode video on the GPU (`hwdec=auto`). With an NVIDIA GPU this cuts a
  playing video from 39% to about 3% of a CPU core.
- Render through OpenGL (`gpu-api=opengl`). With an NVIDIA GPU a window appears
  in about 0.2 s instead of 1.2 s with Vulkan, and decoding stays on NVDEC.
- The read-ahead cache is capped at 32 MiB ahead and 16 MiB behind
  (`demuxer-max-bytes`, `demuxer-max-back-bytes`). mpv counts SMB and FUSE
  paths as network streams and otherwise holds up to 200 MiB per window. Each
  mpv window also carries about 80 MiB for the NVIDIA driver, so many open
  windows add up.
- Opening a file loads the rest of its folder, same kind only
  (`autocreate-playlist=same`).
- The image setup follows
  [guidocella/mpv-image-config](https://github.com/guidocella/mpv-image-config),
  trimmed to mpv's built-in `positioning` script. The `[image]` auto profile
  switches on the `{image}` bindings in `input.conf`, hides the on-screen
  controls and skips resume files. `[non-image]` switches the bindings off
  again, so videos keep mpv's defaults.

### Next / previous in Dolphin's order

`autocreate-playlist` sorts the folder by name only, which differs from
Dolphin's order when Dolphin sorts the folder another way.
[`scripts/dolphin-sort.lua`](scripts/dolphin-sort.lua) reorders that playlist
the way Dolphin sorts the folder: name (natural), modified, created, accessed,
size or type, ascending or descending.

It reads Dolphin 26.08's view settings (`src/views/viewproperties.cpp`):

- With **Remember display style for each folder** on (`GlobalViewProps=false`
  in `dolphinrc`), each folder keeps its own sort. Dolphin stores it in the
  folder's `user.kde.fm.viewproperties#1` extended attribute (a `.directory`
  file where attributes aren't supported). Settings for folders outside home
  and for network folders live under
  `~/.local/share/dolphin/view_properties/local` and `/remote`.
- Folders without their own settings use the global default
  (`SortRole` and `SortOrder` in `view_properties/global`).

It runs once per window, when the first image loads. A folder re-sorted while
mpv is open takes effect on the next image you open from Dolphin. If anything
is missing, mpv's name order stays.

### uosc and thumbfast

Videos get uosc controls (AUR `mpv-uosc`) with thumbfast timeline thumbnails
(AUR `mpv-thumbfast-git`, provider 1, not `-noenabled`). The controls stay
hidden until the cursor nears them; there is no always-visible progress line.
uosc installs to `/usr/share/mpv`, which mpv doesn't search, so `mpv.conf`
loads it from there. Images get no uosc at all (`[image]` disables every
element). `thumbfast.conf` sets `network=yes`, because mpv counts SMB files as
network streams and thumbfast skips those by default.

### Keys

Same convention as the Hyprland window keys
([`linux/hypr`](../hypr/SETUP.md), Window mode): arrows move, Alt makes the
step fine. `video-zoom` is a power of 2, so 0.1 is about 7% and ten presses
double the size. Alt+arrows and Alt+-/= replace mpv's own Alt pan and zoom
(steps of 0.1) while an image is open.

Videos: mpv's defaults (Left/Right seek, wheel is volume) plus these. Panning
adds Ctrl because plain Left/Right seek.

| Input (videos) | Action |
|---|---|
| `=` / `-` | Zoom 0.1 |
| Alt+= / Alt+- | Zoom 0.01 |
| Ctrl+arrows / Ctrl+Alt+arrows | Pan 10% / 1% of the window (replaces mpv's subtitle seek on Ctrl+Left/Right) |
| Alt+Backspace | Reset zoom and pan (mpv's default; `0` is volume) |
| Up / Down, Alt+Up / Alt+Down | Volume ±5% / ±1% (replaces mpv's one-minute seek) |
| Tab | Keep uosc's controls up until pressed again |
| Right-click, Menu key | uosc's menu: tracks, chapters, playlist (Space still pauses) |

Images:

| Input | Action |
|---|---|
| Wheel | Zoom towards the cursor, 0.05 per notch |
| Left-drag | Pan |
| Middle button (hold) | Sweep across the whole image |
| `n` / `p`, PgDn / PgUp | Next / previous image in the folder (hold to flip through) |
| Arrows / Alt+arrows | Pan 10% / 1% of the window |
| `=` / `-` | Zoom 0.1 |
| Alt+= / Alt+- | Zoom 0.01 |
| `0` | Reset the view |
| `u` | Actual pixels / fit to window |
| `r` / `t` | Rotate counterclockwise / clockwise |

## Verify

```bash
./status.sh | grep mpv                      # ok on all six lines
mpv --version | head -1                     # mpv v0.40 or newer
xdg-mime query default image/png            # mpv-image.desktop
xdg-mime query default video/mp4            # mpv.desktop
xdg-mime query default image/svg+xml        # org.kde.gwenview.desktop
```
