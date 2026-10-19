# starship

One prompt config for every machine, laid out like a powerlevel10k prompt: path
and git state on the left, status, duration, tool badges and the clock on the
right.

## Files

| Repo | Destination |
|---|---|
| [`starship.toml`](starship.toml) | `~/.config/starship/starship.toml` |

[`shared/fish/conf.d/00-roynul-env.fish`](../fish/conf.d/00-roynul-env.fish)
sets `STARSHIP_CONFIG` to that path, so starship ignores its default
`~/.config/starship.toml`. Delete that file if it exists, so nobody edits the
wrong one.

## Install

- CachyOS/Arch: `sudo pacman -S starship ttf-jetbrains-mono-nerd`
- macOS: `brew install starship` and
  `brew install --cask font-jetbrains-mono-nerd-font`

fish starts starship ([`shared/fish`](../fish/SETUP.md)), so there is no
separate init step.

## Notes

### Layout

```
  󰀵  portfolio-v4/apps on  main ⇡3 !1 ?2 +12 -4 ➜            ✘ 127 took 5s  24.10.0 at 08:40:12 PM
```

Left side, in order:

- The OS icon, and `✳` in shells that Claude Code starts.
- The user name as root or over SSH. `@host` and the local IP show only over
  SSH.
- The path, truncated to the repo root. The repo folder is bold, and a lock
  shows when the folder is read-only.
- The git branch, cut at 24 characters, or the hash and tag when detached.
- Git status markers with counts, in powerlevel10k's symbols
  (`⇡⇣ ~ * + ! ? » ✘`), then dim `+added -deleted` line counts.
- Background jobs, and a sudo icon while the sudo password is cached.
- `➜`, green after success and red after failure, or `❮` in vi mode.

Right side: the exit code only after a failure, the duration only past 3 s, a
`zsh` or `bash` tag outside fish, language and tool badges, the battery and the
clock. A blank line separates prompts.

### Colours and icons

- Colours are ANSI names (`blue`, `purple`), never hex or 256-colour numbers,
  so the prompt follows the terminal palette: Noctalia's wallpaper palette on
  Linux ([`shared/kitty`](../kitty/SETUP.md)), the kitty or Ghostty theme on
  macOS. Badge icons take the nearest colour name to their brand colour. Keep
  it that way when editing.
- Icons are literal Nerd Font glyphs. The badge symbols and their formats come
  from `starship preset nerd-font-symbols` and `starship print-config
  --default`. The folder, lock, branch, tag and globe are Font Awesome
  codepoints. This needs a v3 Nerd Font: the v2-era MesloLGS NF lacks the bun
  glyph, for example.
- Transient prompt is off on purpose. `enable_transience` after
  `starship init fish` turns it on.

## Verify

```fish
starship prompt | cat -v                                    # icon, path, arrow; no errors
starship prompt --right --status=127 --cmd-duration=5000    # ✘ 127 took 5s
starship timings                                            # nothing slow
```
