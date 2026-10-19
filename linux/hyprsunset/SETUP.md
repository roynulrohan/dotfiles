# hyprsunset

Night light: a warmer screen, always on. hyprsunset is the Hyprland project's
blue-light filter.

## Files

| Repo | Destination |
|---|---|
| [`hyprsunset.conf`](hyprsunset.conf) | `~/.config/hypr/hyprsunset.conf` |

The file is in `~/.config/hypr` because the stock service reads it there. It
isn't part of the Hyprland config ([`linux/hypr`](../hypr/SETUP.md)).

## Install

```bash
sudo pacman -S hyprsunset
systemctl --user enable --now hyprsunset.service
```

The package ships the user service. It starts with the graphical session,
which this setup gets from uwsm (`wayland-session@hyprland.desktop.target`),
so Hyprland's config has no `exec` line for it.

## Notes

One profile at `00:00` with `temperature = 5800`. A single profile keeps it on
all day: hyprsunset re-applies it at midnight, and no other profile switches it
off.

Lower is warmer. The screen is unchanged at about 6600 K, not at hyprsunset's
6000 K default, so 5800 K gives a light tint. The valid range is 1000 K to
20000 K.

Try other values live, then write the one you like into the file and restart
the service:

```bash
hyprctl hyprsunset temperature 4000   # warmer
hyprctl hyprsunset identity           # off until the next profile change
hyprctl hyprsunset reset              # back to the config's value
```

Source: [hyprsunset on the Hyprland wiki](https://wiki.hypr.land/Hypr-Ecosystem/hyprsunset/).

## Verify

```bash
./status.sh | grep hyprsunset                   # ok
systemctl --user is-active hyprsunset.service   # active
hyprctl hyprsunset temperature                  # 5800
```

The screen has a light warm tint. Screenshots, recordings and screen sharing
don't show it, so look at the screen itself.
