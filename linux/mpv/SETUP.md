# mpv

The video player and the default image viewer on CachyOS. Gwenview stays
installed for editing and for SVG.

| Repo | Destination |
|---|---|
| `mpv.conf` | `~/.config/mpv/mpv.conf` |
| `input.conf` | `~/.config/mpv/input.conf` |
| `mpv-image.desktop` | `~/.local/share/applications/mpv-image.desktop` |

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

## Image bindings

| Input | Action |
|---|---|
| Wheel | Zoom towards the cursor |
| Left-drag | Pan |
| Middle button (hold) | Sweep across the whole image |
| ← / →, `n` / `p`, PgDn / PgUp | Previous / next image in the folder (hold to flip through) |
| ↑ / ↓, Shift+arrows | Pan |
| `=` / `-` | Zoom |
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
