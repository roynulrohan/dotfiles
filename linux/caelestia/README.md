# caelestia (history and reference)

Until 2026-10-08 the CachyOS desktop ran on
[caelestia dots](https://github.com/caelestia-dots/caelestia): caelestia's
shell (bar, launcher, lock screen, notifications, idle), its CLI for
wallpapers and colour schemes, and its Hyprland config, all set up by its
installer. This folder held the override files on top of it.

On 2026-10-08 the shell became Noctalia (`linux/noctalia`), mainly for the top
bar and plugins, and `~/.config/hypr` became ours (`linux/hypr`), so
`caelestia update` could no longer overwrite it. On 2026-10-09 caelestia was
uninstalled: its shell, CLI, Firefox theme and login theme, the packages only
they needed, and `~/.config/caelestia`. Nothing in this repo needs it now.

## What we adopted

- **Hyprland config**: caelestia's tree at revision `1ee7a98`, now
  `linux/hypr`, including the `caelestia` animation preset still in use. The
  override layers `hypr-vars.lua` and `hypr-user.lua` started in this folder
  and moved to `linux/hypr` on 2026-10-09; the pop-up workspace apps moved from
  caelestia's `cli.json` into `hypr-vars.lua` (`toggles`).
- **Looks**, ported to Noctalia colour templates (`linux/noctalia`, Colour
  templates): the Spotify colour scheme, the GTK and Thunar CSS, and the key
  names of the Hyprland scheme file.
- **Lock and login screens**: Noctalia's lock screen is modelled on
  caelestia's (`linux/noctalia`, Lock screen), and our SDDM theme is a fork of
  the caelestia "locklike" theme (`linux/sddm`).
- **Behaviour**: the idle timings and launcher actions in Noctalia's
  `config.toml`, `btop.conf` (`linux/btop`), the short `ls` aliases
  (`shared/fish`).

caelestia's `shell.json` (bar, idle, launcher actions) is retired; Noctalia's
`config.toml` covers the same ground.

## Reference copy

`hypr-reference/` holds a copy of caelestia's `~/.config/hypr` at revision
`1ee7a98`. Nothing loads it. Its README lists what our layers changed, which
keys and tools needed caelestia, and the user's key preferences, so the
Hyprland setup can be rebuilt from scratch. It is a snapshot from 2026-10-08:
where it says `linux/caelestia/SETUP.md` or `~/.config/caelestia`, read
`linux/hypr/SETUP.md` and `~/.config/hypr`.
