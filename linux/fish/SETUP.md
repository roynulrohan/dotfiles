# fish (Linux entry point)

See [`shared/fish/SETUP.md`](../../shared/fish/SETUP.md). This `config.fish` only keeps two PATH lines and
sources `local.fish` (machine-only lines, not in the repo); [`shared/fish/conf.d`](../../shared/fish/conf.d)
does the rest. It replaced caelestia's `config.fish` on
2026-10-08, which also printed caelestia's frozen terminal colours
(`~/.local/state/caelestia/sequences.txt`) into every new shell.

| Repo | Destination |
|---|---|
| `config.fish` | `~/.config/fish/config.fish` |

On a machine where caelestia's installer once ran, `~/.config/fish/config.fish`
is still caelestia's: replace it, and delete its `functions/fish_greeting.fish`
too (a banner that `conf.d/20` overrides anyway).
