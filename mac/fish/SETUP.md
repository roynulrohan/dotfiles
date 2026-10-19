# fish (macOS entry point)

The macOS `config.fish`. It holds the Mac's PATH, conda and fzf setup, and
starts starship, zoxide and direnv after conda's hook. Everything shared is in
[`shared/fish`](../../shared/fish/SETUP.md).

## Files

| Repo | Destination |
|---|---|
| [`config.fish`](config.fish) | `~/.config/fish/config.fish` |

It sources `~/.config/fish/local.fish` last if that file exists. Lines for one
machine only, such as an installer's PATH addition, go there.

## Install

First install fish and the shared tools ([`shared/fish`](../../shared/fish/SETUP.md),
Install). This file also uses:

```bash
brew install fzf fd bat eza
```

Every other PATH entry is guarded, so a missing tool is skipped quietly. Examples
are Rust, the python.org Python 3.12, Homebrew's openjdk, the Android SDK,
nvm's default node and miniconda.

## Notes

- starship, zoxide and direnv start here, not in
  [`shared/fish/conf.d/05-roynul-init.fish`](../../shared/fish/conf.d/05-roynul-init.fish),
  so they come after the conda hook. conda's hook wraps whatever `fish_prompt`
  exists when it runs, so moving starship ahead of it would change the prompt.
- On Linux, `conf.d/05` starts those three, and
  [`linux/fish/config.fish`](../../linux/fish/config.fish) is the entry point.
- `cat` is an alias for `bat`, on macOS only.
- fzf lists files with `fd` (hidden files included, `.git` excluded), previews
  with `bat` and `eza`, and binds Ctrl+T, Ctrl+R and Alt+C.
- nvm itself does not run in fish, but nvm's default node stays on PATH, so
  global npm packages (tsc, yarn, ...) still resolve.
- kitty.app's `Contents/MacOS` goes at the end of PATH, so the fastfetch
  wrapper finds `kitten` for animated GIF logos.

## Verify

```fish
type -t cd                  # function: zoxide's cd
type -t cat                 # function: the bat alias
echo $FZF_DEFAULT_COMMAND   # fd --hidden --strip-cwd-prefix --exclude .git
```
