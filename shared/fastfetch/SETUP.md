# fastfetch

The terminal greeting: HyDE's two-box layout with right-aligned values,
coloured from the terminal palette, and a random image logo on the left. A
wrapper script named `fastfetch` applies this config, so typing `fastfetch` in
any shell shows the same greeting. fish's greeting calls it.

## Files

| Repo | Destination | Note |
|---|---|---|
| [`greeting.jsonc`](greeting.jsonc) | `~/.config/fastfetch/greeting.jsonc` | the wrapper loads it; it is not fastfetch's default config |
| [`fastfetch`](fastfetch) | `~/.local/bin/fastfetch` | the wrapper script, executable |
| [`logo/`](logo) (empty) | `~/.config/fastfetch/logo/` | not in `manifest.tsv`; add your own images (png, jpg, webp, `.icon`, gif) |

Keep the filename `greeting.jsonc`. `config.jsonc` is fastfetch's own default
config. Nothing here uses it, so delete `~/.config/fastfetch/config.jsonc` if
it exists.

## Install

- CachyOS/Arch: `sudo pacman -S fastfetch imagemagick`
- macOS: `brew install fastfetch imagemagick`

The config needs **fastfetch 2.48.1 or later** (see Notes). ImageMagick is
optional: it lets the wrapper size the logo to each image's aspect ratio.
Without it, every logo is 40 columns wide. Animated GIF logos need kitty's
`kitten` ([`shared/kitty`](../kitty/SETUP.md)).

After copying:

1. `chmod +x ~/.local/bin/fastfetch`.
2. `~/.local/bin` must come before the real binary on PATH.
   [`shared/fish`](../fish/SETUP.md) does this in `conf.d/00-roynul-env.fish`.
3. Put a few images in `~/.config/fastfetch/logo/`.

## Notes

### The wrapper

- It applies `greeting.jsonc`, picks the logo, and falls back to the ASCII logo
  where the terminal can't draw images.
- It has two flags of its own, in any order. `--os-logo` shows fastfetch's
  built-in logo of the OS instead of an image. `--larp` makes the os, kernel
  and host rows say Arch Linux, an Arch-style kernel name and `archlinux`, with
  the Arch logo wherever a built-in logo shows.
- Any other arguments bypass the wrapper. fastfetch then loads its own default
  config, or its built-in layout if there is none.

### Logo

- Images need a terminal that can draw them. The wrapper picks the logo type
  from the environment: the kitty protocol in kitty, Ghostty and WezTerm;
  iTerm2's own inline images in iTerm2; the built-in ASCII logo everywhere else
  (VS Code's terminal, Terminal.app, tmux, a pipe), so the two-column layout
  survives.
- **Animated GIFs** work in kitty. fastfetch's own icat mode shows one frame,
  so the wrapper follows the recipe from fastfetch issue #1423:
  `kitten icat -n --place ...` piped into `fastfetch --raw -`. Ghostty has no
  animation support in the protocol, so expect a still frame there.
- GIFs from video converters often contain 1x1 "no change" frames that make
  icat fail with a shared-memory error. Rebuild them with
  `magick in.gif -coalesce -layers RemoveDups -resize 400x500 +repage -fuzz 3% -colors 128 -layers Optimize out.gif`
  (this also makes the files smaller).
- Logo width comes from the image's aspect ratio and the terminal's real cell
  shape (pixel size via TIOCGWINSZ, through `kitten` or python3). kitty
  stretches the image to fill the requested box exactly, so a guessed cell
  shape shows. `FASTFETCH_CELL_ASPECT` overrides it; 2.2 is the fallback.
- The logo is 18 rows tall on Linux and 17 on macOS, whose layout has one row
  fewer (no `display`). So the image ends on the colour-dots row and the blank
  line above the prompt survives. `FASTFETCH_LOGO_ROWS` overrides either.
- Square images work best. Pad a portrait to a transparent square with
  `magick in.png -background none -gravity center -extent '%[fx:max(w,h)]x%[fx:max(w,h)]' out.png`.

### Rows and colours

- Rows whose value is built from several parts (`mem`, `age`, `uptime`,
  `display`) are shell commands gated with `"condition": {"system": ...}`. The
  Linux set uses `free` and `hyprctl`, the macOS set `vm_stat` and `sysctl`.
- `condition` needs fastfetch 2.48.1 or later. Older builds ignore it and run
  both sets, so macOS shows `free` and `hyprctl` errors. Run
  `brew upgrade fastfetch` if you see them.
- Accent colours are plain ANSI blue, magenta and cyan, so the greeting follows
  whatever the terminal theme defines: Noctalia's wallpaper palette on Linux
  ([`shared/kitty`](../kitty/SETUP.md)), the kitty or Ghostty theme on macOS.
  Nothing in this repo overrides the palette.
- `age` is the time since the OS was installed, as `2y 340d` (or `340d` under a
  year): the root filesystem's birth on Linux, the Data volume's birth on
  macOS.
- `wm` on macOS names the running window-manager app (yabai, Rectangle, ...) or
  `Aqua`, because "Quartz Compositor" is always true and says nothing.

## Verify

```fish
fastfetch -c ~/.config/fastfetch/greeting.jsonc --logo none   # boxes aligned, no errors
fastfetch                                                     # wrapper: layout + random image, any shell
fastfetch --larp --os-logo                                    # "I use Arch": Arch rows and Arch logo
env TERM=xterm TERM_PROGRAM= KITTY_WINDOW_ID= fastfetch       # the ASCII fallback path
```
