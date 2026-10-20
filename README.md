# dotfiles

My dotfiles: a CachyOS gaming PC running Hyprland with the Noctalia shell, and
a MacBook Pro running AeroSpace and SketchyBar. This repo is how I set up and
look after both. The two machines are alike where that makes sense: the same
shell, prompt, terminal, editors and font, and Mac keys that follow the
Hyprland ones. If you want to try my setup or take parts of it, start with
[`INSTALL.md`](INSTALL.md).

<!-- Screenshots go here. -->

## What's in it

| | Gaming PC | MacBook Pro |
|---|---|---|
| OS | CachyOS | macOS |
| Window manager | Hyprland | AeroSpace |
| Bar and launcher | Noctalia | SketchyBar, Raycast |
| Login screen | SDDM, custom theme | |
| Terminal | kitty | kitty, Ghostty |
| Shell | fish, starship, fastfetch | fish, starship, fastfetch |
| Editors | VS Code, Neovim (LazyVim) | VS Code, Neovim (LazyVim) |
| Files and media | Dolphin, mpv | |
| Font | JetBrainsMono Nerd Font | JetBrainsMono Nerd Font |

Hardware: [gaming PC](personal/machines/gaming-pc.md),
[MacBook Pro](personal/machines/macbook-pro.md), [desk](personal/machines/desk.md).

## How I work on it

The configs are plain files in package folders, copied to where each app
expects them. Each package has a `SETUP.md`. [`manifest.tsv`](manifest.tsv)
maps every file to its place on the machine, [`status.sh`](status.sh) shows
what differs, and [`check.sh`](check.sh) checks syntax, links and secrets
before each commit.

I make most changes with coding agents, mainly Claude Code. They follow the
rules in [`AGENTS.md`](AGENTS.md) and read my
[`preferences`](personal/preferences.md) before they change how something
works. The commit history tells the story of each change.

## Layout

| Folder | What | Packages |
|---|---|---|
| `shared/` | both machines | [fish](shared/fish/SETUP.md) · [starship](shared/starship/SETUP.md) · [fastfetch](shared/fastfetch/SETUP.md) · [kitty](shared/kitty/SETUP.md) · [ghostty](shared/ghostty/SETUP.md) · [git](shared/git/SETUP.md) · [agents](shared/agents/SETUP.md) · [claude](shared/claude/SETUP.md) · [ccstatusline](shared/ccstatusline/SETUP.md) · [nvim](shared/nvim/SETUP.md) · [vscode](shared/vscode/SETUP.md) · [cursor](shared/cursor/SETUP.md) · [orca](shared/orca/SETUP.md) |
| `linux/` | the gaming PC | [fish](linux/fish/SETUP.md) · [hypr](linux/hypr/SETUP.md) · [noctalia](linux/noctalia/SETUP.md) · [hyprmod](linux/hyprmod/SETUP.md) · [sddm](linux/sddm/SETUP.md) · [wallpaper](linux/wallpaper/SETUP.md) · [mpv](linux/mpv/SETUP.md) · [pipewire](linux/pipewire/SETUP.md) · [openlinkhub](linux/openlinkhub/SETUP.md) · [openrgb](linux/openrgb/SETUP.md) · [case-lights](linux/case-lights/SETUP.md) · [hyprsunset](linux/hyprsunset/SETUP.md) · [btop](linux/btop/SETUP.md) · [equibop](linux/equibop/SETUP.md) · [uwsm](linux/uwsm/SETUP.md) · [ssh](linux/ssh/SETUP.md) · [snapshots](linux/snapshots/SETUP.md) · [packages.md](linux/packages.md) |
| `mac/` | the MacBook | [fish](mac/fish/SETUP.md) · [kitty](mac/kitty/SETUP.md) · [wm](mac/wm/SETUP.md) (AeroSpace, SketchyBar, Karabiner, LinearMouse) · [Brewfile](mac/Brewfile) |
| `personal/` | me and my agents | [preferences](personal/preferences.md) · machines: [gaming PC](personal/machines/gaming-pc.md), [MacBook Pro](personal/machines/macbook-pro.md), [desk](personal/machines/desk.md) |

## Credits and licence

Inspirations, and the work included from others, are in
[`CREDITS.md`](CREDITS.md). My own files are under the MIT licence
([`LICENSE`](LICENSE)); included work keeps its own licence.
