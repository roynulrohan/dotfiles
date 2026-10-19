# Equibop

Equibop is the Discord app in this setup, with Discord's own logo in the
launcher, the bar and the tray. A Noctalia template writes its theme
([`linux/noctalia`](../noctalia/SETUP.md)).

## Files

| Repo | Destination |
|---|---|
| [`equibop.desktop`](equibop.desktop) | `~/.local/share/applications/equibop.desktop` |

`equibop.desktop` is a copy of the package's launcher entry with
`Icon=discord`, so the launcher, the bar's app icons and window lists show
Discord's logo. A user copy wins over `/usr/share/applications`.

Outside the repo: `~/.config/equibop/themes/noctalia.theme.css`, which
Noctalia writes, and the splash and tray icons, set by hand in Equibop's
settings (Install).

## Install

On CachyOS or Arch:

```bash
paru -S equibop-bin                           # AUR
sudo pacman -S discord papirus-icon-theme
```

The official `discord` package installs the `discord` icon and stays
installed alongside Equibop. `papirus-icon-theme` has the `discord-tray*`
icons.

After copying:

1. Make Equibop open `discord://` links:
   `xdg-mime default equibop.desktop x-scheme-handler/discord`.
2. Switch on the `noctalia` theme in Equibop → Settings → Themes.
3. Set the splash and the normal, unread and speaking tray icons in Equibop →
   Settings → Equibop Settings → User Assets: Discord's app icon and
   Papirus-Dark's `discord-tray*` icons, cropped tight so they don't look small
   in the tray. The voice-state icons (muted, deafened and the like) stay
   Equibop's.

## Notes

- Equibop has no setting for Discord's own icons, so the User Assets step is
  manual.
- **After an Equibop update** that changes its launcher entry, refresh the
  copy:
  `sed 's/^Icon=equibop$/Icon=discord/' /usr/share/applications/equibop.desktop > ~/.local/share/applications/equibop.desktop`.

## Verify

```bash
./status.sh | grep equibop   # ok
sed 's/^Icon=equibop$/Icon=discord/' /usr/share/applications/equibop.desktop |
    diff - ~/.local/share/applications/equibop.desktop   # no output: the copy is current
xdg-mime query default x-scheme-handler/discord          # equibop.desktop
```

The launcher and the bar show Discord's logo for Equibop.
