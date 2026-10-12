# dotfiles

My desktop setup: a CachyOS gaming PC running Hyprland with the Noctalia shell,
and a MacBook Pro running AeroSpace and SketchyBar. Both share fish, starship,
kitty, git and editor config.

<!-- Screenshots go here. -->

## Highlights

On the gaming PC:

- **Colours follow the wallpaper.** Noctalia builds a palette from the main
  wallpaper and writes it to kitty, Hyprland's borders, GTK and Qt apps,
  Thunar, btop, Spotify, Discord (Equibop) and the login screen.
- **Live wallpapers** from Wallpaper Engine on all three monitors. The main one
  also plays behind the login screen.
- **Own login theme**, `noctalia-card`: a welcome page, then a login card that
  matches the lock screen.
- **Workspaces per monitor**, 1 to 10 on each, shown as animated pills on the
  bar.
- **One set of keys for moving things**: arrows move, Shift resizes, Alt makes
  the step fine. Window mode and mpv's image viewer both follow it.
- **Headset EQ** in PipeWire's own filter chain, without EasyEffects.

## What's in it

| | Gaming PC | MacBook Pro |
|---|---|---|
| OS | CachyOS | macOS |
| Window manager | Hyprland | AeroSpace |
| Bar and launcher | Noctalia | SketchyBar, Raycast |
| Login screen | SDDM with `noctalia-card` | |
| Terminal | kitty | kitty, Ghostty |
| Shell | fish, starship, fastfetch | fish, starship, fastfetch |
| Editors | VS Code, Neovim (LazyVim) | VS Code, Neovim (LazyVim) |
| Files and media | Dolphin, mpv | |
| Font | JetBrains Mono Nerd Font | JetBrains Mono Nerd Font |

The hardware is in [`machines.md`](machines.md).

## Install

Install `gh` (`sudo pacman -S github-cli` on CachyOS, `brew install gh` on the
Mac), then clone:

```bash
gh auth login
gh repo clone roynulrohan/dotfiles ~/Coding/setup/dotfiles
```

Then follow [`INSTALL.md`](INSTALL.md).

## How it works

- Each folder in `shared/`, `linux/` and `mac/` is a package with a
  `SETUP.md`: where its files go, what to install, the gotchas, and how to
  verify it.
- Files are copied to where each app expects them, not symlinked.
  `manifest.tsv` maps every repo file to its live destination.
- `./status.sh` compares the live files with the repo. `./check.sh` checks the
  syntax, the manifest and secrets before a commit.
- Lines for one machine only go in local files that stay out of the repo:
  `~/.config/fish/local.fish`, `~/.gitconfig.local` and kitty's `local.conf`.

To keep it current: edit the live file, check it with `./status.sh --diff`,
copy it into the repo, run `./check.sh`, and commit.

## Layout

| Folder | For | Packages |
|---|---|---|
| `shared/` | both machines | [fish](shared/fish/SETUP.md) · [starship](shared/starship/SETUP.md) · [fastfetch](shared/fastfetch/SETUP.md) · [kitty](shared/kitty/SETUP.md) · [ghostty](shared/ghostty/SETUP.md) · [git](shared/git/SETUP.md) · [agents](shared/agents/SETUP.md) · [claude](shared/claude/SETUP.md) · [ccstatusline](shared/ccstatusline/SETUP.md) · [nvim](shared/nvim/SETUP.md) · [vscode](shared/vscode/SETUP.md) · [cursor](shared/cursor/SETUP.md) · [orca](shared/orca/SETUP.md) |
| `linux/` | the gaming PC | [fish](linux/fish/SETUP.md) · [hypr](linux/hypr/SETUP.md) · [noctalia](linux/noctalia/SETUP.md) · [hyprmod](linux/hyprmod/SETUP.md) · [sddm](linux/sddm/SETUP.md) · [wallpaper](linux/wallpaper/SETUP.md) · [mpv](linux/mpv/SETUP.md) · [pipewire](linux/pipewire/SETUP.md) · [hyprsunset](linux/hyprsunset/SETUP.md) · [btop](linux/btop/SETUP.md) · [equibop](linux/equibop/SETUP.md) · [uwsm](linux/uwsm/SETUP.md) · [ssh](linux/ssh/SETUP.md) · [snapshots](linux/snapshots/SETUP.md) · [packages.md](linux/packages.md) |
| `mac/` | the MacBook | [fish](mac/fish/SETUP.md) · [kitty](mac/kitty/SETUP.md) · [wm](mac/wm/SETUP.md) (AeroSpace, SketchyBar, Karabiner, LinearMouse) · [Brewfile](mac/Brewfile) |
| `history/` | reference only | [caelestia](history/caelestia/README.md): the desktop's base until 2026-10-09, and a copy of its Hyprland config |

| File | What |
|---|---|
| [`INSTALL.md`](INSTALL.md) | setting up a machine |
| [`machines.md`](machines.md) | the hardware and the desk |
| [`CREDITS.md`](CREDITS.md) | inspirations, and the work included from others |
| [`AGENTS.md`](AGENTS.md) | instructions for coding agents |
| [`manifest.tsv`](manifest.tsv), [`status.sh`](status.sh), [`check.sh`](check.sh) | the file map and its two checks |

## Not in here

Credentials, shell history, caches, and personal media such as wallpapers.
`.gitignore` blocks the obvious filenames as a backstop.
