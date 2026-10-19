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
- Environment variables override what the wrapper measures:
  `FASTFETCH_COLS` (the measured width of the window),
  `FASTFETCH_LOGO_ROWS` (the logo height, 18 rows on Linux and 17 on macOS) and
  `FASTFETCH_CELL_ASPECT` (cell height divided by cell width).
- The boxes need 35 columns beside the logo. In a narrower window the wrapper
  shrinks the image, or uses the `_small` text logo, or drops the logo and
  centres the boxes. When the layout gets wider, change `TEXT_COLS` in the
  wrapper.
- A window resized afterwards keeps the old layout until `fastfetch` runs
  again.

### Logo

- Images show in kitty, Ghostty, WezTerm and iTerm2. Other terminals, tmux and
  a pipe get the built-in ASCII logo.
- **Animated GIFs** animate only in kitty. Ghostty shows a still frame.
- GIFs from video converters often contain 1x1 "no change" frames that make
  `kitten icat` fail with a shared-memory error. Rebuild them with
  `magick in.gif -coalesce -layers RemoveDups -resize 400x500 +repage -fuzz 3% -colors 128 -layers Optimize out.gif`.
- Square images work best. Pad a portrait to a transparent square with
  `magick in.png -background none -gravity center -extent '%[fx:max(w,h)]x%[fx:max(w,h)]' out.png`.

### Rows and colours

- Some rows are shell commands, with one set for each OS. `condition` selects
  the set, and it needs fastfetch 2.48.1 or later. Older builds run both sets,
  so macOS shows `free` and `hyprctl` errors. Run `brew upgrade fastfetch` if
  you see them.
- The accent colours are plain ANSI colours, so the greeting follows the
  terminal theme: Noctalia's wallpaper palette on Linux
  ([`shared/kitty`](../kitty/SETUP.md)), the kitty or Ghostty theme on macOS.

## Verify

```fish
fastfetch -c ~/.config/fastfetch/greeting.jsonc --logo none   # boxes aligned, no errors
fastfetch                                                     # wrapper: layout + random image, any shell
fastfetch --larp --os-logo                                    # "I use Arch": Arch rows and Arch logo
env TERM=xterm TERM_PROGRAM= KITTY_WINDOW_ID= fastfetch       # the ASCII fallback path
```
