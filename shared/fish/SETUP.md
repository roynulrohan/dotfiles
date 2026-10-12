# fish

Shell on every machine. Fish has autosuggestions, highlighting and completions
built in, so there are no plugins to install. Starship draws the prompt.

## Files

| Repo | Destination | Note |
|---|---|---|
| `conf.d/*.fish` | `~/.config/fish/conf.d/` | fish sources these automatically, on both OSes |
| `../../mac/fish/config.fish` | `~/.config/fish/config.fish` | **macOS only** |
| `../../linux/fish/config.fish` | `~/.config/fish/config.fish` | **Linux only**; replaced caelestia's |

The `conf.d` files do the work: `00` environment, `05` starship, zoxide (as
`cd`) and direnv (Linux; the Mac's `config.fish` does these itself, after its
conda hook), `10` aliases and abbreviations, `20` the fastfetch greeting, `30`
syntax colours (macOS only). fish sources `conf.d` before `config.fish`, so each
OS's `config.fish` only adds what must come later.

## Install

- CachyOS: `pacman -S fish starship eza bat zoxide direnv`
- macOS: `brew install fish starship eza bat zoxide direnv`, then
  `echo $(brew --prefix)/bin/fish | sudo tee -a /etc/shells` and
  `chsh -s $(brew --prefix)/bin/fish`

## Notes

- Fish is not POSIX. Paste bash one-liners as `bash -c '...'`.
- `nvm` does not work in fish; use `n` (in the Brewfile) or bun.
- `ll` is eza's long listing and `gl` a short graph log on both OSes. The
  short `l`, `la` and `lla` abbreviations are Linux only, so the Mac keeps
  fish's own `la` (`ls -lAh`).
- The SSH agent line only applies when the systemd user socket exists (Linux).
- `conf.d/30` names ANSI colours only, never hex, so the terminal's own palette
  still decides the shade. It sets the one fish default that does not survive a
  transparent background; everything else is left to the theme. It runs on macOS
  only: on CachyOS, the wallpaper palette maps `brblack` to a mid grey that
  already reads, so the file exits at its OS guard.

## Verify

```fish
echo $STARSHIP_CONFIG        # ~/.config/starship/starship.toml
functions fish_greeting      # defined, from conf.d/20-roynul-greeting.fish
abbr | grep gs               # git abbreviations loaded
abbr --show | grep ' gl '    # git log --oneline --graph -20
type cd                      # Linux: zoxide's cd function
echo $STARSHIP_SHELL         # fish: the prompt is initialised
set -S fish_color_autosuggestion  # macOS: white --dim, global scope (not universal)
```
