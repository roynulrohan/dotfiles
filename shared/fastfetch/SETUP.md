# fastfetch

The terminal greeting: HyDE's two-box layout with caelestia-style right-aligned
values, coloured from the terminal palette, and a random image logo on the left.

In fish, `fastfetch` itself is a wrapper function (`shared/fish/conf.d/20-roynul-greeting.fish`)
that applies this config and picks the logo, so typing `fastfetch` matches the
greeting. Arguments bypass the wrapper. Outside fish you get the plain binary.

## Files

| Repo | Destination | Note |
|---|---|---|
| `greeting.jsonc` | `~/.config/fastfetch/greeting.jsonc` | invoked by the fish greeting, not fastfetch's default config |
| `logo/` | `~/.config/fastfetch/logo/` | **images are not committed**; drop your own in (png, jpg, webp, `.icon`, gif) |

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
  Linux set uses `free`/`hyprctl`, the macOS set `vm_stat`/`sysctl`. Both sets are
  verified. `condition` needs **fastfetch ≥ 2.48.1**; older builds ignore it and
  run both sets, so a Mac on Homebrew's stale 2.36.1 showed `free`/`hyprctl` errors
  until `brew upgrade fastfetch`.
- Accent colours are plain ANSI blue, magenta and cyan, so the greeting follows
  whatever the terminal theme defines: caelestia's wallpaper scheme on Linux, the
  Ghostty or kitty theme on macOS. Nothing in this repo overrides the palette.
- **Animated GIFs** work in kitty. fastfetch's own icat mode shows one frame, so
  the wrapper follows the recipe from fastfetch issue #1423: `kitten icat -n
  --place ...` piped into `fastfetch --raw -`. Ghostty has no animation support
  in the protocol, so expect a still frame there. GIFs from video converters
  often contain 1x1 "no change" frames that make icat fail with a shared-memory
  error; rebuild them with
  `magick in.gif -coalesce -layers RemoveDups -resize 400x500 +repage -fuzz 3% -colors 128 -layers Optimize out.gif`
  (also shrinks them a lot).
- Square images work best. Pad a portrait to a transparent square with
  `magick in.png -background none -gravity center -extent '%[fx:max(w,h)]x%[fx:max(w,h)]' out.png`.

## Verify

```fish
fastfetch -c ~/.config/fastfetch/greeting.jsonc --logo none   # boxes aligned, no errors
fastfetch                                                     # wrapper: layout + random image
```
