# fastfetch

The terminal greeting: HyDE's two-box layout with caelestia-style right-aligned
values, coloured from the terminal palette, and a random image logo on the left.

## Files

| Repo | Destination | Note |
|---|---|---|
| `greeting.jsonc` | `~/.config/fastfetch/greeting.jsonc` | invoked by the fish greeting, not fastfetch's default config |
| `logo/` | `~/.config/fastfetch/logo/` | **images are not committed**; drop your own in (png, jpg, webp, `.icon`) |

Keep the filename `greeting.jsonc`. On Linux caelestia owns `config.jsonc` in the
same directory and overwrites it on update.

## Install

- CachyOS: `pacman -S fastfetch imagemagick`
- macOS: `brew install fastfetch imagemagick`

ImageMagick is optional; it lets the greeting size the logo to each image's
aspect ratio. Without it every logo is drawn 40 columns wide.

## Notes

- Needs a terminal with the kitty graphics protocol: kitty or Ghostty. Anywhere
  else the image is skipped.
- Rows whose value is built from several parts (`mem`, `age`, `uptime`,
  `display`) are shell commands gated with `"condition": {"system": ...}`; the
  Linux set uses `free`/`hyprctl`, the macOS set `vm_stat`/`sysctl`. **The macOS
  commands have not been run on a Mac yet**; check them the first time.
- Colours 16, 17, 18 are the accent slots. caelestia sets them live on Linux;
  `mac/kitty/colors.conf` and `shared/ghostty/config` define them on macOS.
- Square images work best. Pad a portrait to a transparent square with
  `magick in.png -background none -gravity center -extent '%[fx:max(w,h)]x%[fx:max(w,h)]' out.png`.

## Verify

```fish
fastfetch -c ~/.config/fastfetch/greeting.jsonc --logo none   # boxes aligned, no errors
fish_greeting                                                 # with an image
```
