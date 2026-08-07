# kitty

Fallback terminal, for machines where Ghostty won't build. Ghostty is the primary
— see `ghostty/SETUP.md`.

## Files

| Repo | Destination |
|---|---|
| `kitty.conf` | `~/.config/kitty/kitty.conf` |
| `theme.conf` | `~/.config/kitty/theme.conf` |

Same path on both platforms. Symlink both — `kitty.conf` does `include theme.conf`,
a relative include, so they have to end up in the same directory.

## Install

- macOS: `brew install --cask kitty`
- Debian/Ubuntu: `apt install kitty`, or the upstream installer
  (`curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin`) for a
  current version — distro packages lag, and `cursor_trail` needs kitty ≥0.33.

## Platform notes

Fully portable. No macOS-specific keys.

**`kitty.conf` sets no `font_family`.** It only sets `bold_font`/`italic_font` to
`auto`, so kitty falls back to the system monospace default — which on a fresh
Linux box is not a Nerd Font, and the powerline tab bar (`tab_bar_style powerline`,
`tab_powerline_style slanted`) will render as tofu. If you're actually going to
use kitty, add:

```
font_family JetBrainsMono Nerd Font
```

Left out of the committed file deliberately: on macOS it currently inherits a
working default, and changing it is a taste decision, not a portability fix.

Also note `font_size 18.0` here versus `font-size = 14` in the Ghostty config.
Not a mistake, just different displays — adjust to the machine.

## Verify

```bash
kitty --debug-config | head -30    # dumps the effective config
```

Tab bar should render slanted powerline separators, not boxes.
