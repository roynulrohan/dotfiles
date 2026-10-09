# fastfetch

The terminal greeting: HyDE's two-box layout with caelestia-style right-aligned
values, coloured from the terminal palette, and a random image logo on the left.

`fastfetch` on PATH is a wrapper script (`fastfetch` here, installed as
`~/.local/bin/fastfetch`) that applies this config, picks the logo and falls back
to the ASCII logo where the terminal can't draw images, so typing `fastfetch` in
any shell matches the greeting. Arguments bypass the wrapper. fish's greeting
just calls it.

## Files

| Repo | Destination | Note |
|---|---|---|
| `greeting.jsonc` | `~/.config/fastfetch/greeting.jsonc` | invoked by the wrapper, not fastfetch's default config |
| `fastfetch` | `~/.local/bin/fastfetch` | wrapper script, `chmod +x`; `~/.local/bin` must precede the binary on PATH |
| `logo/` | `~/.config/fastfetch/logo/` | **images are not committed**; drop your own in (png, jpg, webp, `.icon`, gif) |

Keep the filename `greeting.jsonc`. `config.jsonc` is fastfetch's own default,
which caelestia's installer writes on Linux; nothing here uses it, so delete it.
`fastfetch` with arguments skips the wrapper and then shows fastfetch's built-in
layout.

## Install

- CachyOS: `pacman -S fastfetch imagemagick`
- macOS: `brew install fastfetch imagemagick`

ImageMagick is optional; it lets the greeting size the logo to each image's
aspect ratio. Without it every logo is drawn 40 columns wide.

## Notes

- Images need a terminal that can draw them. The wrapper picks the logo type
  from the environment: kitty protocol in kitty, Ghostty and WezTerm; iTerm2's
  own inline images in iTerm2; the built-in ASCII logo everywhere else (VS Code's
  terminal, Terminal.app, tmux, a pipe), so the two-column layout survives.
- Rows whose value is built from several parts (`mem`, `age`, `uptime`,
  `display`) are shell commands gated with `"condition": {"system": ...}`; the
  Linux set uses `free`/`hyprctl`, the macOS set `vm_stat`/`sysctl`. Both sets are
  verified. `condition` needs **fastfetch ≥ 2.48.1**; older builds ignore it and
  run both sets, so a Mac on Homebrew's stale 2.36.1 showed `free`/`hyprctl` errors
  until `brew upgrade fastfetch`.
- Accent colours are plain ANSI blue, magenta and cyan, so the greeting follows
  whatever the terminal theme defines: Noctalia's wallpaper palette on Linux (`shared/kitty`), the
  Ghostty or kitty theme on macOS. Nothing in this repo overrides the palette.
- **Animated GIFs** work in kitty. fastfetch's own icat mode shows one frame, so
  the wrapper follows the recipe from fastfetch issue #1423: `kitten icat -n
  --place ...` piped into `fastfetch --raw -`. Ghostty has no animation support
  in the protocol, so expect a still frame there. GIFs from video converters
  often contain 1x1 "no change" frames that make icat fail with a shared-memory
  error; rebuild them with
  `magick in.gif -coalesce -layers RemoveDups -resize 400x500 +repage -fuzz 3% -colors 128 -layers Optimize out.gif`
  (also shrinks them a lot).
- `age` is time since the OS was installed, `2y 340d` (or `340d` under a year):
  root filesystem birth on Linux, the Data volume's birth on macOS. `wm` on macOS
  names the running window-manager app (yabai, Rectangle, ...) or `Aqua`, since
  "Quartz Compositor" is always true and says nothing.
- Logo width is computed from the image's aspect ratio and the terminal's real
  cell shape (pixel size via TIOCGWINSZ, through `kitten` or python3); kitty
  stretches to fill the requested box exactly, so a guessed cell shape shows.
  `FASTFETCH_CELL_ASPECT` overrides, 2.2 is the fallback.
- The logo is 18 rows tall on Linux and 17 on macOS, whose layout has one row
  fewer (no `display`), so the image ends on the colour-dots row and the blank
  line above the prompt survives. `FASTFETCH_LOGO_ROWS` overrides either.
- Square images work best. Pad a portrait to a transparent square with
  `magick in.png -background none -gravity center -extent '%[fx:max(w,h)]x%[fx:max(w,h)]' out.png`.

## Verify

```fish
fastfetch -c ~/.config/fastfetch/greeting.jsonc --logo none   # boxes aligned, no errors
fastfetch                                                     # wrapper: layout + random image, any shell
env TERM=xterm TERM_PROGRAM= KITTY_WINDOW_ID= fastfetch       # the ASCII fallback path
```
