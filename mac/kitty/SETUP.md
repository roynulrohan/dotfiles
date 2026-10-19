# kitty (macOS)

The macOS-only kitty files: the Catppuccin Frappé colour theme and the
remote-control socket path. Linux doesn't use them: its colours come from
Noctalia (see [`shared/kitty`](../../shared/kitty/SETUP.md)).

## Files

| Repo | Destination |
|---|---|
| [`colors.conf`](colors.conf) | `~/.config/kitty/colors.conf` |
| [`macos.conf`](macos.conf) | `~/.config/kitty/macos.conf` |

## Install

Install kitty and the shared `kitty.conf` first
([`shared/kitty`](../../shared/kitty/SETUP.md)). These two files need nothing
else.

## Notes

- `macos.conf` sets the remote-control socket to the path `unix:/tmp/kitty`,
  because macOS has no abstract sockets. kitty appends `-PID`. AeroSpace's
  Super+T ([`mac/wm`](../wm/SETUP.md)) connects to `/tmp/kitty-<pid>`, so keep
  this path. `kitty.conf` loads the file through its
  `globinclude ${KITTY_OS}.conf` line.
- `colors.conf` is Catppuccin's Frappé theme for kitty. Its header links the
  upstream file.

## Verify

```bash
# kitty's own config loader: unix:/tmp/kitty
kitty +runpy "import os; from kitty.config import load_config; print(load_config(os.path.expanduser('~/.config/kitty/kitty.conf')).listen_on)"
./status.sh | grep kitty    # kitty.conf, colors.conf, macos.conf: ok
```
