# ghostty

Primary terminal on macOS. Supports the kitty graphics protocol, so the fastfetch
greeting's image logo works here too.

## Files

| Repo | Destination |
|---|---|
| `config` | macOS: `~/Library/Application Support/com.mitchellh.ghostty/config`; Linux: `~/.config/ghostty/config` |
| `auto/theme.ghostty` | same directory, `auto/` subfolder; **copy, don't rely on it** — Ghostty regenerates it |

## Install

macOS: `brew install --cask ghostty`. Linux: distro package (`pacman -S ghostty`),
though on the CachyOS desktop kitty is the terminal caelestia launches.

## Notes

- `palette = 16..18` at the bottom are the accent slots the fastfetch greeting
  colours with. Match them to the theme if you change themes.
- The macOS-only keys (`macos-titlebar-style`, glass blur) are ignored on Linux.
