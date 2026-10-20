# Install

These are my dotfiles, set up for my machines. You can take the whole setup or
only the parts you like. Nothing installs itself: you copy files into place,
package by package. Read what you copy, and back up any file it replaces. Use
it at your own risk.

## Ways to install

- **The whole Linux desktop:** [Base: Linux](#base-linux),
  [Shell and terminal](#shell-and-terminal), [Linux desktop](#linux-desktop),
  then any of the [apps](#apps).
- **The whole Mac setup:** [Base: macOS](#base-macos),
  [Shell and terminal](#shell-and-terminal), [Mac desktop](#mac-desktop), then
  any of the [apps](#apps).
- **Only the terminal:** [Shell and terminal](#shell-and-terminal), on either
  system.
- **One app's config:** go straight to its package below.

## How it works

```bash
git clone https://github.com/roynulrohan/dotfiles.git
cd dotfiles
```

Each package is a folder with a `SETUP.md`: what it is, the files and where
they go, what to install, notes, and a Verify section. Copy the files to the
destinations it lists. [`manifest.tsv`](manifest.tsv) lists every file and
its destination, and [`./status.sh`](status.sh) shows what you have copied so
far:

| Label | Meaning |
|---|---|
| `ok` | your file matches the repo |
| `differs` | your file differs from the repo |
| `missing` | not copied yet |
| `seeded` | differs, but the app rewrites this file itself |
| `skipped` | the app isn't installed |
| `leftover` | an old file still exists; remove it |

`status.sh` checks every package for your system, so expect `missing` lines
for the parts you skip.

Settings for one machine only go in local files that stay out of the repo:
`~/.config/fish/local.fish`, `~/.gitconfig.local` and kitty's `local.conf`.

## Base: Linux

I use [CachyOS](https://cachyos.org). Plain Arch works too. The few
CachyOS-only packages are marked.

1. Install the packages in [`linux/packages.md`](linux/packages.md).
2. Install the packages each component below names in its `SETUP.md`.

## Base: macOS

1. Install [Homebrew](https://brew.sh).
2. Read [`mac/Brewfile`](mac/Brewfile) and remove the apps you don't want. It
   holds my whole Mac, not only what these dotfiles need.
3. Run `brew bundle --file mac/Brewfile`. Karabiner-Elements asks for your
   password.

## Shell and terminal

Both systems.

1. fish: [`shared/fish`](shared/fish/SETUP.md), plus
   [`linux/fish`](linux/fish/SETUP.md) or [`mac/fish`](mac/fish/SETUP.md).
2. Prompt and greeting: [`shared/starship`](shared/starship/SETUP.md) and
   [`shared/fastfetch`](shared/fastfetch/SETUP.md). The greeting's logo images
   aren't in the repo. Bring your own.
3. Terminal: [`shared/kitty`](shared/kitty/SETUP.md), plus
   [`mac/kitty`](mac/kitty/SETUP.md) on macOS.
   [`shared/ghostty`](shared/ghostty/SETUP.md) is optional.
4. Git: [`shared/git`](shared/git/SETUP.md). It carries my name, email and
   signing key. Put your own `[user]` section in `~/.gitconfig.local`, which
   overrides them.

## Linux desktop

Hyprland with the Noctalia shell. Do these in order, then log out and back in.

1. Hyprland: [`linux/hypr`](linux/hypr/SETUP.md) with
   [`linux/uwsm`](linux/uwsm/SETUP.md).
2. Binds and rules: [`linux/hyprmod`](linux/hyprmod/SETUP.md).
3. Desktop shell (bar, launcher, lock screen, notifications):
   [`linux/noctalia`](linux/noctalia/SETUP.md).
4. Login screen: [`linux/sddm`](linux/sddm/SETUP.md).
5. Live wallpapers: [`linux/wallpaper`](linux/wallpaper/SETUP.md). They need
   Wallpaper Engine from Steam.

Bring your own wallpapers, lock-screen GIFs, lock-screen avatar and profile
picture. Each `SETUP.md` says where they go.

The config names my three monitors. Change these for yours (`hyprctl monitors`
lists the output names):

- the monitor layout in [`linux/hyprmod/hyprland-gui.lua`](linux/hyprmod/hyprland-gui.lua)
- `monitor_priority` in [`linux/hypr/hypr-user.lua`](linux/hypr/hypr-user.lua),
  for the workspaces on each monitor
- `M` and the side monitors in
  [`linux/noctalia/lock/scripts/gen.py`](linux/noctalia/lock/scripts/gen.py),
  for the lock screen
- the monitor names in your wallpaper picks file
  ([`linux/wallpaper`](linux/wallpaper/SETUP.md), Picks)
- `MAIN_MODEL` and `ORDER` (EDID model names) in
  [`linux/sddm/Xsetup`](linux/sddm/Xsetup), for the login screen

## Mac desktop

AeroSpace, SketchyBar, Karabiner and LinearMouse: [`mac/wm`](mac/wm/SETUP.md),
following its numbered steps.

## Apps

Take any of these on their own.

| App | Package | System |
|---|---|---|
| Night light | [`linux/hyprsunset`](linux/hyprsunset/SETUP.md) | Linux |
| Headset EQ (Logitech G432) | [`linux/pipewire`](linux/pipewire/SETUP.md) | Linux |
| Corsair fan hub and AIO cooler: fans follow the coolant and GPU temperatures | [`linux/openlinkhub`](linux/openlinkhub/SETUP.md) | Linux |
| OpenRGB, kept away from the Corsair fan hub and cooler | [`linux/openrgb`](linux/openrgb/SETUP.md) | Linux |
| RAM lighting: CPU and RAM usage as levels in the wallpaper accent | [`linux/case-lights`](linux/case-lights/SETUP.md) | Linux |
| mpv as video player and image viewer | [`linux/mpv`](linux/mpv/SETUP.md) | Linux |
| btop | [`linux/btop`](linux/btop/SETUP.md) | Linux |
| Equibop (Discord) | [`linux/equibop`](linux/equibop/SETUP.md) | Linux |
| SSH key unlocked at login | [`linux/ssh`](linux/ssh/SETUP.md) | Linux |
| Btrfs snapshots | [`linux/snapshots`](linux/snapshots/SETUP.md) | Linux |
| Neovim (LazyVim) | [`shared/nvim`](shared/nvim/SETUP.md) | both |
| VS Code | [`shared/vscode`](shared/vscode/SETUP.md) | both |
| Cursor | [`shared/cursor`](shared/cursor/SETUP.md) | both |
| Orca | [`shared/orca`](shared/orca/SETUP.md) | both |
| Claude Code | [`shared/claude`](shared/claude/SETUP.md), [`shared/ccstatusline`](shared/ccstatusline/SETUP.md) | both |
| Instructions for coding agents | [`shared/agents`](shared/agents/SETUP.md) | both |

The agent instructions are mine. Read them and write your own.

## Not in this repo

Credentials, shell history, caches and personal media. The steps above say
where to put your own media.
