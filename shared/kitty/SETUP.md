# kitty

The terminal on Linux and macOS. kitty draws the fastfetch greeting's image
logos, including animated GIFs. On macOS, AeroSpace's Super+T opens new windows
through kitty's remote control, so keep `allow_remote_control` in `kitty.conf`
and the `listen_on` path in [`mac/kitty/macos.conf`](../../mac/kitty/macos.conf).

## Files

| Repo | Destination | Note |
|---|---|---|
| [`kitty.conf`](kitty.conf) | `~/.config/kitty/kitty.conf` | both OSes |
| `colors.conf`, `macos.conf` | `~/.config/kitty/` | macOS only, in their own package: [`mac/kitty`](../../mac/kitty/SETUP.md). On Linux the colours come from Noctalia (see Notes) |
| not in the repo | `~/.config/kitty/local.conf` | overrides for one machine, such as `font_size 18` |

## Install

- CachyOS/Arch: `sudo pacman -S kitty ttf-jetbrains-mono-nerd`.
  [`linux/hypr/hypr-vars.lua`](../../linux/hypr/hypr-vars.lua) sets
  `terminal = "kitty"`, so Super+T opens kitty (see
  [`linux/hypr`](../../linux/hypr/SETUP.md)).
- macOS: `brew install --cask kitty font-jetbrains-mono-nerd-font`.

After copying, create `local.conf` if it doesn't exist:
`touch ~/.config/kitty/local.conf`. kitty logs "Could not find included config
file" for a missing `include` file and carries on.

## Notes

### Remote control socket

`kitty.conf` listens on `unix:@kitty`, an abstract socket. Abstract sockets
exist only on Linux. On macOS, `macos.conf` overrides it with `unix:/tmp/kitty`
through the `globinclude ${KITTY_OS}.conf` line. kitty appends `-PID` to both.
Copy `macos.conf` on the Mac, or kitty starts without remote control there.

### Linux colours

Live colours come from Noctalia's wallpaper palette. A Noctalia template
([`linux/noctalia/templates/kitty.conf`](../../linux/noctalia/templates/kitty.conf))
writes `~/.config/kitty/themes/noctalia.conf` and reloads kitty. `kitty.conf`
loads that file with `globinclude`, so the Mac, which has no such file, loads
nothing. The template is a copy of Noctalia's built-in kitty template. Don't
use the built-in one: it also appends an `include` line to `kitty.conf`, which
would reach the Mac.

On Linux, `colors.conf` is optional. Noctalia's file loads after it and sets
every colour.

### Transparency

Hyprland treats kitty as opaque (a rule in
[`linux/hyprmod`](../../linux/hyprmod/SETUP.md)), because kitty handles its own
transparency and Hyprland blurs behind it. Hyprland's focus fading (90% / 75%)
would fade the text and the fastfetch images too.

### Scrollbar

The scrollbar settings need kitty 0.43 or later.

## Verify

```bash
# kitty's own config loader. Linux: unix:@kitty, macOS: unix:/tmp/kitty
kitty +runpy "import os; from kitty.config import load_config; print(load_config(os.path.expanduser('~/.config/kitty/kitty.conf')).listen_on)"
```
