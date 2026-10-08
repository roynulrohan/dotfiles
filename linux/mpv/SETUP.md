# mpv

The video player and the default image viewer on CachyOS. Gwenview stays
installed for editing and for SVG.

| Repo | Destination |
|---|---|
| `mpv.conf` | `~/.config/mpv/mpv.conf` |
| `input.conf` | `~/.config/mpv/input.conf` |
| `mpv-image.desktop` | `~/.local/share/applications/mpv-image.desktop` |
| `scripts/dolphin-sort.lua` | `~/.config/mpv/scripts/dolphin-sort.lua` |

`mpv.conf`: start at 30% volume, cap at 100, resume where you stopped, loop
single files, decode video on the GPU (`hwdec=auto`; a playing video dropped from
39% to about 3% of a CPU core). The read-ahead cache is capped at 32 MiB ahead and 16 MiB behind: mpv counts
SMB and FUSE paths as network streams and otherwise holds up to 200 MiB per
window (`demuxer-max-bytes`, `demuxer-max-back-bytes`). Each mpv window also
carries about 80 MiB for the NVIDIA driver, so many open windows add up. Opening a file loads the rest of its folder, same kind only
(`autocreate-playlist=same`). The image setup follows
[guidocella/mpv-image-config](https://github.com/guidocella/mpv-image-config),
trimmed to mpv's built-in `positioning` script (mpv 0.40 or newer). The
`[image]` auto profile switches on the `{image}` bindings in `input.conf`,
hides the on-screen controls and skips resume files; `[non-image]` switches the
bindings off again, so videos keep mpv's defaults.

## Next / previous in Dolphin's order

`autocreate-playlist` sorts the folder by name only, so ← / → jumped around
when Dolphin showed the folder sorted another way. `scripts/dolphin-sort.lua`
reorders that playlist the way Dolphin sorts the folder: name (natural),
modified, created, accessed, size or type, ascending or descending.

It reads Dolphin 26.08's view settings (`src/views/viewproperties.cpp`):

- Dolphin → Configure → View → General → **Remember display style for each
  folder** is on (`GlobalViewProps=false` in `dolphinrc`), so each folder keeps
  its own sort. Dolphin stores it in the folder's `user.kde.fm.viewproperties#1`
  extended attribute (a `.directory` file where attributes aren't supported);
  folders outside home and network folders live under
  `~/.local/share/dolphin/view_properties/local` and `/remote`.
- Folders without their own settings use the global default, here
  **Modified, newest first** (`SortRole=modificationtime`, `SortOrder=1` in
  `view_properties/global`). Set it once from Dolphin's View menu.

It runs once per window, when the first image loads. A folder re-sorted while
mpv is open takes effect on the next image you open from Dolphin. It needs
`getfattr` (package `attr`). If anything is missing, mpv's name order stays.

## Image bindings

Same convention as the Hyprland window keys (`linux/caelestia`, Window mode):
arrows move, Alt makes the step fine. `video-zoom` is a power of 2, so 0.1
is about 7% and ten presses double the size. Alt+arrows and Alt+-/= replace
mpv's own Alt pan and zoom (steps of 0.1) while an image is open; videos keep
mpv's defaults.

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

## Default apps

`mpv.desktop` declares no image types, so KDE wouldn't accept it as their
default; `mpv-image.desktop` declares them. Then:

```bash
for t in $(grep '^MimeType=' ~/.local/share/applications/mpv-image.desktop | cut -d= -f2 | tr ';' ' '); do
    xdg-mime default mpv-image.desktop "$t"; done
for t in $(grep '^MimeType=' /usr/share/applications/mpv.desktop | cut -d= -f2 | tr ';' '\n' | grep '^video/'); do
    xdg-mime default mpv.desktop "$t"; done
xdg-mime default org.kde.gwenview.desktop image/svg+xml  # mpv rasterises SVG once, so it blurs when zoomed
kbuildsycoca6                                           # Dolphin sees the change now
```

Run `xdg-mime default` once per type: given several types at once, it wrote
them all into one broken line of `~/.config/mimeapps.list`.

## Verify

```bash
xdg-mime query default image/png   # mpv-image.desktop
xdg-mime query default video/mp4   # mpv.desktop
```
