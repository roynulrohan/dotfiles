# neofetch

## Files

| Repo | Destination |
|---|---|
| `config.conf` | `~/.config/neofetch/config.conf` |

Same path on both platforms. Symlink it.

## Install

- macOS: `brew install neofetch`
- Debian/Ubuntu: `apt install neofetch`

## Notes

**neofetch is unmaintained** — the upstream repo was archived in 2024 and it's
been dropped from Debian 13 and Ubuntu 24.10+. If `apt install neofetch` fails,
that's why.

`fastfetch` is the maintained successor and is already in the `Brewfile`
(`brew install fastfetch` / `apt install fastfetch`). It does **not** read this
config file — it uses its own JSON format at
`~/.config/fastfetch/config.jsonc`. There's no fastfetch config in this repo yet;
`fastfetch --gen-config` writes a default to start from.

Keep this package for machines that still have neofetch, but don't go out of your
way to install it on a new Linux box.

## Verify

```bash
neofetch
```
