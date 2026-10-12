# kitty

Terminal on Linux (replaced caelestia's foot so the fastfetch image logos work).
Also the terminal on macOS, where Ghostty stays configured as a second terminal.
On the Mac, AeroSpace's Super+T opens new windows through kitty's remote control
(`allow_remote_control` in `kitty.conf`, the `listen_on` path in
[`mac/kitty/macos.conf`](../../mac/kitty/macos.conf)), so keep both.

## Files

| Repo | Destination | Note |
|---|---|---|
| `kitty.conf` | `~/.config/kitty/kitty.conf` | shared |
| [`../../mac/kitty/colors.conf`](../../mac/kitty/colors.conf) | `~/.config/kitty/colors.conf` | **macOS** only; on Linux colours come from Noctalia (below) |
| [`../../mac/kitty/macos.conf`](../../mac/kitty/macos.conf) | `~/.config/kitty/macos.conf` | **macOS**; socket path for remote control |
| — | `~/.config/kitty/local.conf` | per-machine overrides, e.g. `font_size 18`; create empty if absent |

## Remote control socket

`kitty.conf` listens on `unix:@kitty`, an abstract socket. Abstract sockets
exist only on Linux. On macOS, `macos.conf` overrides it with `unix:/tmp/kitty`
through the `globinclude ${KITTY_OS}.conf` line; kitty appends `-PID` to both.
Linux has no `linux.conf`, and `globinclude` skips a missing file silently.
Copy `macos.conf` on the Mac, or kitty starts without remote control there.

## Install

- CachyOS: `pacman -S kitty`, then set `terminal = "kitty"` in
  `~/.config/hypr/hypr-vars.lua` (see [`linux/hypr`](../../linux/hypr/SETUP.md))
- macOS: `brew install --cask kitty`

## Linux colours

Live colours come from Noctalia's wallpaper palette: a Noctalia template
([`linux/noctalia/templates/kitty.conf`](../../linux/noctalia/templates/kitty.conf)) writes `~/.config/kitty/themes/noctalia.conf`
and reloads kitty, and `kitty.conf` loads it with `globinclude`, so the Mac,
which has no such file, loads nothing. The template is a copy of Noctalia's
built-in kitty template; the built-in one also appends an `include` line to
`kitty.conf`, which would reach the Mac. Nothing prints colour escape codes at
shell start any more (caelestia's fish config did; [`linux/fish`](../../linux/fish/SETUP.md) replaced it).
On Linux `colors.conf` is optional: Noctalia's file loads after it and sets
every colour, and kitty skips a missing `include` without an error. This
machine still has an old one (caelestia's last scheme, from before caelestia
was uninstalled on 2026-10-09) as a fallback; it isn't in the repo, and a fresh
Linux machine doesn't need one.

Hyprland treats kitty as opaque (rule in [`linux/hyprmod`](../../linux/hyprmod/SETUP.md)) because kitty handles
its own transparency and Hyprland blurs behind it. Hyprland's focus fading
(90% / 75%) would fade the text and fastfetch images too; a kitty watcher that
fades only the background on focus was tried and dropped (2026-10-08).

**Scrollbar** (kitty 0.43+): shown only while the mouse is at the window's
right edge (`scrollbar hovered`; the default `scrolled` shows it whenever the
view isn't at the bottom, which a window resize can leave behind). Handle and
track use the theme's `selection_background`, at 80% and 25% (hovered),
fully round (`scrollbar_radius 0.5`, half the hover width).

## Verify

```bash
# kitty's own config loader (kitty 0.49.2 has no --debug-config). Linux: unix:@kitty,
# macOS: unix:/tmp/kitty
kitty +runpy "import os; from kitty.config import load_config; print(load_config(os.path.expanduser('~/.config/kitty/kitty.conf')).listen_on)"
```
