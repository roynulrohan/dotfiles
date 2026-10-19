# fish (Linux entry point)

The Linux `config.fish`. It keeps two PATH lines and sources `local.fish`.
[`shared/fish/conf.d`](../../shared/fish/conf.d) does the rest. The shell
itself is set up in [`shared/fish`](../../shared/fish/SETUP.md).

## Files

| Repo | Destination |
|---|---|
| [`config.fish`](config.fish) | `~/.config/fish/config.fish` |

Outside the repo: `~/.config/fish/local.fish`, for lines that belong to one
machine only. `config.fish` sources it last if it exists, so it can override
anything.

## Install

On CachyOS or Arch:

```bash
sudo pacman -S fish
```

The other packages the config uses (starship, eza and the rest) are in
[`shared/fish`](../../shared/fish/SETUP.md), Install. The bun lines expect bun
in `~/.bun`, where bun's own installer puts it.

Copying replaces any existing `config.fish`. If
`~/.config/fish/functions/fish_greeting.fish` exists from an earlier setup,
delete it: [`conf.d/20-roynul-greeting.fish`](../../shared/fish/conf.d/20-roynul-greeting.fish)
defines the greeting.

## Notes

- fish sources `conf.d/` before `config.fish`, so the shared settings load
  first and `local.fish` loads last.
- [`conf.d/00-roynul-env.fish`](../../shared/fish/conf.d/00-roynul-env.fish)
  already adds `~/.local/bin` and `~/.bun/bin` to PATH. The two lines in
  `config.fish` put both in front again, with bun ahead of `~/.local/bin`.

## Verify

```bash
./status.sh | grep fish/config               # ok
fish -n ~/.config/fish/config.fish           # no output: the syntax is valid
fish -c 'echo $PATH[1]'                      # ~/.bun/bin, unless local.fish adds something in front
fish -c 'functions -D fish_greeting'         # ~/.config/fish/conf.d/20-roynul-greeting.fish
```
