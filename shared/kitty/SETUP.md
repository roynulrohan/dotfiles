# kitty

Terminal on Linux (replaces caelestia's foot so the fastfetch image logos work).
On macOS Ghostty is primary and kitty is optional.

## Files

| Repo | Destination | Note |
|---|---|---|
| `kitty.conf` | `~/.config/kitty/kitty.conf` | shared |
| `../../mac/kitty/colors.conf` | `~/.config/kitty/colors.conf` | **macOS**; on Linux generate it (below) |
| — | `~/.config/kitty/local.conf` | per-machine overrides, e.g. `font_size 18`; create empty if absent |

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
kitty --debug-config | head       # no errors
```
