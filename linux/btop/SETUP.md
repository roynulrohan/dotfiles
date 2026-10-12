# btop

System monitor in the terminal. `btop.conf` is caelestia's (revision
`1ee7a98`), adopted unchanged on 2026-10-08 so the setup no longer needs
caelestia's installer for it. It holds no machine-specific values: disks,
network interface, sensors and GPUs are all left on auto.

| Repo | Destination |
|---|---|
| `btop.conf` | `~/.config/btop/btop.conf` |

## Install

```bash
sudo pacman -S btop
```

## Colours

Noctalia's btop template ([`linux/noctalia/templates/btop.theme`](../noctalia/templates/btop.theme)) writes the
wallpaper palette to `~/.config/btop/themes/noctalia.theme` and signals a
running btop to reload it. `btop.conf` selects it (`color_theme = "noctalia"`;
it was `"caelestia"` until 2026-10-09). Renaming it means changing
`color_theme` here and the template's `output_path` in
[`linux/noctalia/config.toml`](../noctalia/config.toml) together. `theme_background = false` keeps kitty's
transparent background.

## Notes

- `save_config_on_exit = true`: btop rewrites `btop.conf` whole when it exits,
  so settings changed in its menu reach the live file, and comments added by
  hand are lost. Copy the file back when `./status.sh` shows it differs.

## Verify

```bash
./status.sh | grep btop                       # ok
grep '^color_theme' ~/.config/btop/btop.conf  # color_theme = "noctalia"
ls ~/.config/btop/themes/noctalia.theme       # the file exists: Noctalia's template wrote it
```
