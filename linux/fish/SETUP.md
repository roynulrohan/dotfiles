# fish (Linux entry point)

See `shared/fish/SETUP.md`. This `config.fish` only keeps two PATH lines;
`shared/fish/conf.d` does the rest. It replaced caelestia's `config.fish` on
2026-10-08, which also printed caelestia's frozen terminal colours
(`~/.local/state/caelestia/sequences.txt`) into every new shell.

| Repo | Destination |
|---|---|
| `config.fish` | `~/.config/fish/config.fish` |

If caelestia's installer has already written `~/.config/fish/config.fish`,
replace it; delete its `functions/fish_greeting.fish` too (a banner that
`conf.d/20` overrides anyway).
