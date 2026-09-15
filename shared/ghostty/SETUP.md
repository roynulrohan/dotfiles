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

- The macOS-only keys (`macos-titlebar-style`, glass blur) are ignored on Linux.
- `font-codepoint-map` sends the Nerd Font icon ranges to the non-Mono variant, so
  icons draw at two cells instead of being squeezed into one; text stays NFM.
  Remove the two lines to go back.
