# fish

Shell on every machine. Fish has autosuggestions, highlighting and completions
built in, so there are no plugins to install. Starship draws the prompt.

## Files

| Repo | Destination | Note |
|---|---|---|
| `conf.d/*.fish` | `~/.config/fish/conf.d/` | fish sources these automatically, on both OSes |
| `../../mac/fish/config.fish` | `~/.config/fish/config.fish` | **macOS only** |

On Linux, caelestia owns `~/.config/fish/config.fish` and `functions/`; don't
replace them. The `conf.d` files layer on top: `00` environment, `10` aliases and
abbreviations, `20` the fastfetch greeting, `30` syntax colours (macOS only). Our
`fish_greeting` is defined in `conf.d`, so caelestia's autoloaded one never runs.

## Install

- CachyOS: `pacman -S fish starship eza bat zoxide direnv`
- macOS: `brew install fish starship eza bat zoxide direnv`, then
  `echo $(brew --prefix)/bin/fish | sudo tee -a /etc/shells` and
  `chsh -s $(brew --prefix)/bin/fish`

## Notes

- Fish is not POSIX. Paste bash one-liners as `bash -c '...'`.
- `nvm` does not work in fish; use `n` or bun (both in the Brewfile).
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
set -S fish_color_autosuggestion  # macOS: white --dim, global scope (not universal)
```
