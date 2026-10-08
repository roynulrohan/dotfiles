# Noctalia

The desktop shell since 2026-10-08: bar (top), launcher, notifications, lock
screen, idle timers, on-screen pop-ups, control centre, clipboard history,
screenshots. Replaced caelestia's shell, mainly for the top bar and plugins.
Docs: [docs.noctalia.dev](https://docs.noctalia.dev/).

| Repo | Destination |
|---|---|
| `config.toml` | `~/.config/noctalia/config.toml` |

## Install

```bash
sudo pacman -S noctalia
```

The package is `noctalia`, version 5 (a C++ rewrite). Not `noctalia-shell`,
which is the old Quickshell version 4, and not `cachyos-hypr-noctalia`, a whole
Hyprland preset. Copy `config.toml`, then set the wallpaper the colours come
from:

```bash
noctalia msg wallpaper-set ~/Pictures/Wallpapers/live/eri-uesugi.png
```

Hyprland starts it at login (`linux/hypr`, `hyprland/execs.lua`); not yet verified across a real login.

## Config

All files in `~/.config/noctalia/*.toml` are merged; Noctalia never rewrites
them. Changes made in its settings window go to
`~/.local/state/noctalia/settings.toml`, which loads last and wins. Check with
`noctalia config validate`; apply with `noctalia msg config-reload`. Log:
`~/.cache/noctalia/noctalia.log`.

- **Wallpaper drawing off**: the live wallpapers (`linux/wallpaper`) would be
  covered otherwise. The wallpaper path is still set, for the colours.
- **Colours** from the wallpaper, style `m3-tonal-spot`, caelestia's
  "tonalspot". One palette for the whole shell, from the default wallpaper.
- **Idle**, as under caelestia: lock after 1 h, screens off after 1.5 h, lock
  and suspend after 4 h. Noctalia pauses for idle inhibitors (browsers and mpv
  during video), not for any audio playing as caelestia did.
- **Location** Ottawa by coordinates, for weather (the name also matches US
  towns).
- The bar keeps Noctalia's default layout, at the top.
- **Session menu**: the default five buttons, but log out runs `uwsm stop`.

## Keys

In `linux/hypr/hyprland/keybinds.lua` (and HyprMod's Super+P / Super+Ctrl+P),
most through `noctalia msg`:

| Key | Command |
|---|---|
| Super (tap) | `panel-toggle launcher` |
| Super+L | `session lock` |
| Ctrl+Alt+Delete | `panel-toggle session` |
| Super+N | `panel-toggle control-center` |
| Ctrl+Alt+C | `notification-clear-active` |
| Super+V | `panel-toggle clipboard` |
| Super+Period | `panel-toggle launcher /emo` |
| Print | `screenshot-fullscreen` |
| Super+Shift+S, Super+Shift+Alt+S, Super+P, Super+Ctrl+P | `screenshot-region` |
| media keys, Ctrl+Super+Space / = / - / Backspace | `media toggle` / `next` / `previous` / `stop` |
| brightness keys | `brightness-up` / `brightness-down` |
| Ctrl+Super+Alt+R / Ctrl+Super+Shift+R | restart / stop Noctalia |

Volume keys stay on `wpctl`.

## Things to know

- **Log out with `uwsm stop`.** Noctalia's built-in log out exits Hyprland
  directly, which once froze the login screen (`linux/sddm`); the session menu
  is set to run `uwsm stop` instead.
- **Terminal colours** are still caelestia's last scheme
  (`~/.local/state/caelestia/sequences.txt`, printed by fish). Noctalia's
  terminal templates aren't enabled.
- Bluetooth shows nothing: the BlueZ service isn't running on this PC.
- The login screen is still SDDM with caelestia's theme. Noctalia has its own
  greeter, for greetd instead of SDDM; not tried yet.
- caelestia stays installed as a fallback but doesn't run. Back to it for one
  session: `pkill -x noctalia`, then `caelestia shell -d`. For good: restore
  `~/.config/hypr` from `linux/caelestia/hypr-reference`.
