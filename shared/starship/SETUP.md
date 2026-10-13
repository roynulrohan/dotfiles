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

Left: OS icon; `✳` only in shells spawned by Claude Code; `user@host` and the
local IP only over SSH (or as root); the path with a folder icon, truncated to
the repo, repo folder bold, lock when read-only; git branch always shown, cut at
24; dirty markers with counts in p10k's alphabet (`⇡⇣ ~ * + ! ? » ✘`); dim
`+added -deleted` line counts; hash and tag when detached; background jobs; a
sudo indicator while the password is cached; `➜` green on success, red on
failure, `❮` in vi mode. Right: exit code only on failure, duration only past
3 s, a `zsh`/`bash` tag when not in fish, language and tool badges, battery,
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
