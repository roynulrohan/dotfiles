# uwsm

uwsm (Universal Wayland Session Manager) starts the Hyprland session. These two
files set the session's environment variables. uwsm exports them to the
session's systemd user environment, so apps that systemd or D-Bus start get
them too.

## Files

| Repo | Destination |
|---|---|
| [`env`](env) | `~/.config/uwsm/env` |
| [`env-hyprland`](env-hyprland) | `~/.config/uwsm/env-hyprland` |

## Install

```bash
sudo pacman -S uwsm
```

The values name themes from other packages: the Qt theme engine `qtengine`
([`linux/noctalia`](../noctalia/SETUP.md)) and the cursor theme
`breeze_cursors` ([`linux/hypr`](../hypr/SETUP.md)).

Copy both files. They take effect at the next log in. The login screen starts
the uwsm session ([`linux/sddm`](../sddm/SETUP.md)).

## Notes

uwsm sources `env` for every compositor, then `env-hyprland` for Hyprland only
(`man uwsm`, Files). Both are shell files of `export` lines.

- `env`: the Qt theme (`qtengine`) and Qt window settings, and the cursor
  theme and size. The cursor values must match the Hyprland config:
  `cursorTheme` in [`linux/hypr/hypr-vars.lua`](../hypr/hypr-vars.lua) and
  `cursorSize` in [`linux/hypr/variables.lua`](../hypr/variables.lua).
- `env-hyprland`: the toolkit backends (Wayland first, X11 as fallback) and
  the XDG session variables.

Apps that systemd or D-Bus start read the variables from uwsm, not from
Hyprland's `hyprland/env.lua` ([`linux/hypr`](../hypr/SETUP.md)).
`hyprland/env.lua` sets the same variables for apps that Hyprland starts
itself. Change both when a variable changes.

## Verify

```bash
./status.sh | grep uwsm   # ok on both lines
```

After you log out and back in:

```bash
systemctl --user show-environment | grep -E '^(QT_QPA_PLATFORMTHEME|XCURSOR_THEME|XDG_CURRENT_DESKTOP)='
```

It prints `qtengine`, `breeze_cursors` and `Hyprland`.
