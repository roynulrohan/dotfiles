# hyprsunset

Night light: a warmer screen, always on. hyprsunset is the Hyprland project's
blue-light filter; caelestia and CachyOS's Hyprland setup have none.

| Repo | Destination |
|---|---|
| `hyprsunset.conf` | `~/.config/hypr/hyprsunset.conf` |

`~/.config/hypr` is caelestia's tree, but this file isn't part of it (like
HyprMod's `hyprland-gui.lua`). It sits there because that's the path the stock
service reads.

## Install

```bash
sudo pacman -S hyprsunset
systemctl --user enable --now hyprsunset.service
```

The package ships the user service. It starts with the graphical session, which
this setup gets from uwsm (`wayland-session@hyprland.desktop.target`), so no
`exec` line in Hyprland's config.

## Settings

One profile at `00:00` with `temperature = 5800`. A single profile keeps it on
all day: hyprsunset re-applies it at midnight, and no other profile switches it
off.

hyprsunset keeps red at 100% and scales green and blue with Tanner Helland's
blackbody formula (`matrixForKelvin` in `src/Hyprsunset.cpp`). The screen is
unchanged at about 6600 K, not at the 6000 K default. 5800 K keeps 95% green
and 91% blue: a light, just-visible tint. Tried: 4500 K (85% / 74%) and
5000–5500 K were too yellow; 6250 K (98% / 95%) was too faint to see. Valid
range: 1000 K (deep orange, no blue) to 20000 K (bluish).

Try other values live, then write the one you like into the file and restart
the service:

```bash
hyprctl hyprsunset temperature 4000   # warmer
hyprctl hyprsunset identity           # off until the next profile change
hyprctl hyprsunset reset              # back to the config's value
```

The tint is not captured in screenshots, recordings or screen sharing.
`gamma` can also dim below the monitor's minimum, but the wiki warns it costs
colour accuracy; it's left at 1.0.

Source: [hyprsunset on the Hyprland wiki](https://wiki.hypr.land/Hypr-Ecosystem/hyprsunset/).
