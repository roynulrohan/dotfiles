# ghostty

Ghostty, a second terminal on macOS. It supports the kitty graphics protocol,
so the fastfetch greeting's image logo works in it too.

## Files

| Repo | macOS | Linux |
|---|---|---|
| [`config`](config) | `~/Library/Application Support/com.mitchellh.ghostty/config` | `~/.config/ghostty/config` |
| [`auto/theme.ghostty`](auto/theme.ghostty) | `~/Library/Application Support/com.mitchellh.ghostty/auto/theme.ghostty` | `~/.config/ghostty/auto/theme.ghostty` |

`auto/theme.ghostty` is a `seed` file: copy it once. Ghostty rewrites it, so
`./status.sh` may report it as `seeded`. `config` loads it with
`config-file = ?auto/theme.ghostty`; the `?` makes it optional.

## Install

- macOS: `brew install --cask ghostty font-jetbrains-mono-nerd-font`
- CachyOS/Arch: `sudo pacman -S ghostty ttf-jetbrains-mono-nerd`. Optional:
  kitty is the terminal that Super+T opens on Linux, and `./status.sh` skips
  the Ghostty rows while `ghostty` is not installed.

## Notes

- The macOS-only keys (`macos-titlebar-style`, the glass blur) are ignored on
  Linux.
- `font-codepoint-map` sends the Nerd Font icon ranges to the non-Mono variant,
  so icons draw at two cells instead of being squeezed into one. Text stays
  JetBrainsMono NFM. Remove the two lines to draw icons at one cell.

## Verify

```bash
./status.sh | grep ghostty   # config: ok; auto/theme.ghostty: ok or seeded
ghostty +validate-config     # no output: the config is valid
```

Run the `ghostty` line in a Ghostty window: Ghostty adds its own command to
`PATH` there. The Homebrew cask does not link it. A new window shows the
fastfetch greeting with its image logo.
