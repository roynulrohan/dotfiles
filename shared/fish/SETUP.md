# fish

The shell on Linux and macOS. fish has autosuggestions, syntax highlighting and
completions built in, so there are no plugins to install. Starship draws the
prompt.

## Files

| Repo | Destination | Note |
|---|---|---|
| [`conf.d/`](conf.d) | `~/.config/fish/conf.d/` | both OSes; fish sources these files automatically |
| `config.fish` | `~/.config/fish/config.fish` | the entry point for each OS, in its own package: [`linux/fish`](../../linux/fish/SETUP.md), [`mac/fish`](../../mac/fish/SETUP.md) |
| not in the repo | `~/.config/fish/local.fish` | lines for one machine only; both `config.fish` files source it last if it exists |

## Install

CachyOS/Arch:

```bash
sudo pacman -S fish starship eza bat zoxide direnv
chsh -s /usr/bin/fish    # only if fish is not your login shell yet
```

macOS:

```bash
brew install fish starship eza bat zoxide direnv fzf fd
echo "$(brew --prefix)/bin/fish" | sudo tee -a /etc/shells
chsh -s "$(brew --prefix)/bin/fish"
```

The config also uses these tools when they exist, and skips them quietly when
they don't:

- `lazygit` for the `lg` abbreviation, `micro` for `EDITOR`, and `neovim` for
  `VISUAL` ([`shared/nvim`](../nvim/SETUP.md)). Arch: `sudo pacman -S lazygit
  micro neovim`. macOS: `brew install lazygit micro neovim`.
- `fastfetch` for the greeting ([`shared/fastfetch`](../fastfetch/SETUP.md)).
- bun for the `dev`, `build` and `npx` abbreviations. Its installer is in
  [`shared/claude`](../claude/SETUP.md).
- Linux: `neo-matrix` (AUR, `paru -S neo-matrix`) for the `neo-matrix` and
  `cmatrix` aliases.

After copying: when an installer appends to `config.fish` (a PATH line, for
example), move those lines into `local.fish`, so `config.fish` matches the repo
again.

## Notes

- The `conf.d` files do the work: `00` environment, `05` starship, zoxide (as
  `cd`) and direnv, `10` aliases and abbreviations, `20` the fastfetch
  greeting, `30` syntax colours. fish sources `conf.d` before `config.fish`, so
  each OS's `config.fish` only adds what must come later.
- `05` exits on macOS. The Mac's `config.fish` starts starship, zoxide and
  direnv itself, after its conda hook ([`mac/fish`](../../mac/fish/SETUP.md)).
- `nvm` does not work in fish. Use `n` (in the Brewfile) or bun.
- `ll` is eza's long listing and `gl` a short graph log on both OSes. The short
  `l`, `la` and `lla` abbreviations are Linux only, so the Mac keeps fish's own
  `la` (`ls -lAh`).
- `conf.d/30` sets the autosuggestion colour on macOS only. Its comments give
  the reason.

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
