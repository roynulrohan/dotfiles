# starship

One prompt config for every machine. Started from caelestia's file and being
ported step by step toward HyDE's single-line layout: distro icon, full path in
the primary colour, git info, prompt character; time on the right.

## Files

| Repo | Destination |
|---|---|
| `starship.toml` | `~/.config/starship/starship.toml` |

`shared/fish/conf.d/00-roynul-env.fish` sets `STARSHIP_CONFIG` to that path, so
caelestia's `~/.config/starship.toml` on Linux is left alone and unused.

## Notes

Colours are ANSI numbers (`16`, `17`), not hex, so the prompt follows the
terminal palette: caelestia's wallpaper scheme on Linux, the kitty/ghostty theme
on macOS. Keep it that way when editing.

## Verify

```fish
starship prompt | cat -v      # icon, path, character; no errors
```
