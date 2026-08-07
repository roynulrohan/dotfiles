# ghostty

The terminal. Transparent background, JetBrainsMono Nerd Font, Raycast Dark theme.

## Files

**The config path is different on each OS.** This is the main reason this package
can't be blindly symlinked.

| Repo | macOS | Linux |
|---|---|---|
| `config` | `~/Library/Application Support/com.mitchellh.ghostty/config` | `~/.config/ghostty/config` |
| `auto/theme.ghostty` | `…/com.mitchellh.ghostty/auto/theme.ghostty` | `~/.config/ghostty/auto/theme.ghostty` |

Symlink `config`. **Copy** `auto/theme.ghostty` — Ghostty rewrites that file when
the theme changes, and a symlink would either get clobbered or push surprise
commits into this repo. The copy here is a record of the intended theme.

## Install

- macOS: `brew install --cask ghostty`
- Linux: no official apt package. Check
  [ghostty.org/docs/install](https://ghostty.org/docs/install) for current
  options — there are community builds for several distros, otherwise build from
  source with Zig. If Ghostty won't build on the target machine, use the `kitty`
  package instead; it's configured to look near enough.

Requires JetBrainsMono Nerd Font — see `shell/SETUP.md`.

**Skip this package on WSL.** There's no GUI terminal inside the distro; the
rendering is done by Windows Terminal on the host. Configure that instead —
see `../windows-terminal/SETUP.md`.

## Platform notes

Four keys in `config` are macOS-only. Ghostty warns about unknown keys on Linux
but still loads the rest of the file, so leaving them in is safe — don't strip
them, or the config stops round-tripping between machines.

| Key | On Linux |
|---|---|
| `macos-titlebar-style = transparent` | ignored |
| `background-blur = macos-glass-regular` | ignored — no blur |
| `window-colorspace = "display-p3"` | ignored |
| `background-opacity = 0.0` | works, but with no blur behind it this is fully transparent and usually unreadable — **set it to ~0.9 on Linux** |

That last one is the only change worth making. Fully transparent with a blur
behind it looks intentional; fully transparent without one looks broken.

`config-file = ?auto/theme.ghostty` is a relative include — the `?` means
"optional, don't error if absent". It resolves next to `config`, so both files
must live in the same directory.

## Verify

```bash
ghostty +show-config | head -20      # dumps the effective config
ghostty +validate-config             # non-zero exit on a syntax error
```

Visually: transparent background, block cursor, no tofu in the prompt.
