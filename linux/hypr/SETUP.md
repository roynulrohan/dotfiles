# Hyprland config

`~/.config/hypr`, owned by this repo since the switch from caelestia's shell to
Noctalia (2026-10-08). It started as caelestia's tree at revision `1ee7a98`;
the untouched original is in `linux/caelestia/hypr-reference`, with notes on
what needs caelestia.

**Never run `caelestia update` again.** It rewrites `~/.config/hypr` with
caelestia's files and would undo the changes below.

## Files

Every file is in `manifest.tsv` with its destination under `~/.config/hypr`.

| Repo | What |
|---|---|
| `hyprland.lua` | entry point: loads the modules, then the override layers (below) |
| `variables.lua` | key names, apps, colours read by the modules; `linux/caelestia/hypr-vars.lua` overrides values |
| `hyprland/*.lua` | env, general, input, misc, animations, decoration, group, autostart (`execs.lua`), rules, gestures, binds |
| `utils/functions.lua`, `utils/json.lua` | helpers the binds and autostart use (pop-up workspaces, picture-in-picture) |
| `scheme/default.lua`, `scheme/current.lua` | colours for borders, shadows and group bars. `current.lua` is the last palette caelestia generated from the wallpaper; nothing regenerates it now |

`hyprland-gui.lua` (HyprMod, `linux/hyprmod`) and `hyprsunset.conf`
(`linux/hyprsunset`) also live in `~/.config/hypr` but belong to those packages.
`scheme/current.conf` is a leftover caelestia generated; nothing reads it.

## Load order

`hyprland.lua` loads `~/.config/caelestia/hypr-vars.lua`, the `hyprland/*.lua`
modules, `~/.config/caelestia/hypr-user.lua` (window mode, per-monitor
workspaces), then HyprMod's `hyprland-gui.lua`. The two override files keep
their caelestia path; see `linux/caelestia/SETUP.md`.

## Changes from caelestia's original

- **Autostart** (`hyprland/execs.lua`): starts Noctalia
  (`uwsm app -- noctalia`) instead of `caelestia shell -d`. The gammastep and
  geoclue lines are gone: neither was installed, and the night light is
  hyprsunset.
- **Shell keys** (`hyprland/keybinds.lua`) call `noctalia msg …` instead of
  caelestia's shell. See `linux/noctalia/SETUP.md` for the list. caelestia's
  recording keys, "show all panels", "restart and lock" and "delete clipboard
  entry" have no Noctalia counterpart and are removed.
- **Rules** (`hyprland/rules.lua`): Noctalia's recommended blur for its bar,
  panels and notifications, a floating settings window, and no Hyprland
  animation on any Noctalia layer. caelestia's slide-in for layers otherwise
  made the screenshot overlay drop in from the top. Hyprland matches the whole
  namespace, so the pattern is `^noctalia-.*$`, not `^noctalia-`.
