# uwsm

Environment variables for the Hyprland session. uwsm starts Hyprland here and
exports these files to the session's systemd user environment. Apps that
systemd or D-Bus start read the variables from there, not from Hyprland's
`hyprland/env.lua` (`linux/hypr`).

| Repo | Destination |
|---|---|
| `env` | `~/.config/uwsm/env` |
| `env-hyprland` | `~/.config/uwsm/env-hyprland` |

uwsm sources `env` for every compositor, then `env-hyprland` for Hyprland only
(`man uwsm`, Files). Both are shell files of `export` lines.

- `env`: the Qt theme (`qtengine`) and Qt window settings, and the cursor
  theme and size. The cursor values must match the Hyprland config:
  `cursorTheme` in `linux/hypr/hypr-vars.lua` and `cursorSize` in
  `linux/hypr/variables.lua`.
- `env-hyprland`: the toolkit backends (Wayland first, X11 as fallback) and
  the XDG session variables.

`hyprland/env.lua` sets the same variables for apps Hyprland starts itself.
Change both when a variable changes.

## Install

```bash
sudo pacman -S uwsm
```

Copy both files. They take effect at the next log in. The login screen picks
the uwsm session (`linux/sddm/SETUP.md`).

## Verify

After logging out and back in:

```bash
systemctl --user show-environment | grep -E 'QT_QPA_PLATFORMTHEME|XCURSOR_THEME|XDG_CURRENT_DESKTOP'
```

It prints `qtengine`, `breeze_cursors` and `Hyprland`.
