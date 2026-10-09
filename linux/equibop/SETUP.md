# Equibop

Equibop (`equibop-bin`, AUR) is the Discord app here; see `linux/packages.md`.

| File | Destination | Why |
|---|---|---|
| `equibop.desktop` | `~/.local/share/applications/equibop.desktop` | A copy of the package's launcher entry with `Icon=discord`, so the launcher, the bar's app icons and window lists show Discord's logo (installed by the official `discord` package). A user copy wins over `/usr/share/applications`. |

Equibop has no setting for Discord's own icons (Vesktop #448 and #801 were
refused). The splash and the normal, unread and speaking tray icons are set by
hand in Equibop → Settings → Equibop Settings → User Assets, from Discord's app
icon and Papirus-Dark's `discord-tray*` icons, cropped tight so they don't look
small in the tray. The muted, deafened and idle-voice icons stay Equibop's on
purpose.

**After an Equibop update** that changes its launcher entry, refresh the copy:
`sed 's/^Icon=equibop$/Icon=discord/' /usr/share/applications/equibop.desktop > ~/.local/share/applications/equibop.desktop`.
