# btop

System monitor in the terminal, coloured with the wallpaper palette by
Noctalia. It holds no machine-specific values: disks, network interface,
sensors and GPUs are all left on auto.

## Files

| Repo | Destination |
|---|---|
| [`btop.conf`](btop.conf) | `~/.config/btop/btop.conf` |

Outside the repo: `~/.config/btop/themes/noctalia.theme`, which Noctalia
writes (Notes, "Colours").

## Install

On CachyOS or Arch:

```bash
sudo pacman -S btop
```

The colours need [`linux/noctalia`](../noctalia/SETUP.md) and its btop
template.

## Notes

### Colours

Noctalia's btop template ([`linux/noctalia/templates/btop.theme`](../noctalia/templates/btop.theme))
writes the wallpaper palette to `~/.config/btop/themes/noctalia.theme` and
signals a running btop to reload it. `btop.conf` selects it
(`color_theme = "noctalia"`). Renaming it means changing `color_theme` here
and the template's `output_path` in
[`linux/noctalia/config.toml`](../noctalia/config.toml) together.
`theme_background = false` keeps kitty's transparent background.

### Saved on exit

`save_config_on_exit = true`: btop rewrites `btop.conf` whole when it exits,
so settings changed in its menu reach the live file, and comments added by
hand are lost. Copy the file back when `./status.sh` shows it differs.

## Verify

```bash
./status.sh | grep btop                       # ok
grep '^color_theme' ~/.config/btop/btop.conf  # color_theme = "noctalia"
ls ~/.config/btop/themes/noctalia.theme       # the file exists: Noctalia's template wrote it
```
