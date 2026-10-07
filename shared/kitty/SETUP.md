# kitty

Terminal on Linux (replaces caelestia's foot so the fastfetch image logos work).
Also the terminal on macOS, where Ghostty stays configured as a second terminal.
On the Mac, AeroSpace's Super+T opens new windows through kitty's remote control
(`allow_remote_control` in `kitty.conf`, the `listen_on` path in
`mac/kitty/macos.conf`), so keep both.

## Files

| Repo | Destination | Note |
|---|---|---|
| `kitty.conf` | `~/.config/kitty/kitty.conf` | shared |
| `../../mac/kitty/colors.conf` | `~/.config/kitty/colors.conf` | **macOS**; on Linux generate it (below) |
| `../../mac/kitty/macos.conf` | `~/.config/kitty/macos.conf` | **macOS**; socket path for remote control |
| — | `~/.config/kitty/local.conf` | per-machine overrides, e.g. `font_size 18`; create empty if absent |

## Remote control socket

`kitty.conf` listens on `unix:@kitty`, an abstract socket. Abstract sockets
exist only on Linux. On macOS, `macos.conf` overrides it with `unix:/tmp/kitty`
through the `globinclude ${KITTY_OS}.conf` line; kitty appends `-PID` to both.
Linux has no `linux.conf`, and `globinclude` skips a missing file silently.
Copy `macos.conf` on the Mac, or kitty starts without remote control there.

## Install

- CachyOS: `pacman -S kitty`, then set `terminal = "kitty"` in
  `~/.config/caelestia/hypr-vars.lua` (see `linux/caelestia`)
- macOS: `brew install --cask kitty`

## Linux colours

Live colours come from caelestia's escape sequences printed by fish on startup.
`colors.conf` is only the fallback; generate it once from the current scheme:

```fish
python3 -c '
import json,os
s=json.load(open(os.path.expanduser("~/.local/state/caelestia/scheme.json")))["colours"]
l=[f"foreground #{s[\"onBackground\"]}",f"background #{s[\"background\"]}",f"cursor #{s[\"secondary\"]}"]
l+=[f"color{i} #{s[f\"term{i}\"]}" for i in range(16)]
open(os.path.expanduser("~/.config/kitty/colors.conf"),"w").write("\n".join(l)+"\n")'
```

Hyprland treats kitty as opaque (rule in `linux/hyprmod`) because kitty handles
its own transparency and Hyprland blurs behind it.

## Verify

```bash
# kitty's own config loader (kitty 0.49.2 has no --debug-config). Linux: unix:@kitty,
# macOS: unix:/tmp/kitty
kitty +runpy "import os; from kitty.config import load_config; print(load_config(os.path.expanduser('~/.config/kitty/kitty.conf')).listen_on)"
```
