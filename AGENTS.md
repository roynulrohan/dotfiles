# Setting up a machine for Roynul

This repo holds real config files plus per-package instructions. There is no
install script and nothing is symlinked: you **copy** files to the destinations
in each package's `SETUP.md` (also listed in `manifest.tsv`), and copy them back
when they change on a machine. `./status.sh` shows what differs.

## Before you start

1. **Ask what the machine is.** The CachyOS desktop wants everything in
   `linux/` plus `shared/`. The Mac wants `mac/` plus `shared/`. A headless box
   wants `shared/fish`, `shared/git`, `shared/claude` and nothing visual.
2. **Detect the platform** with `uname -s`. Packages are written for
   CachyOS/pacman and macOS/Homebrew. Other distros: translate the package names.
3. **Never clobber silently.** If a destination exists and differs, show the
   diff or back it up before copying over it.

## Preferences

These explain why the configs look the way they do. Honour them when you hit a
decision the repo doesn't cover.

- **fish + starship**, everywhere. Not zsh, not powerlevel10k (that's in `legacy/`).
- **Terminal**: kitty on Linux, Ghostty on macOS. Both speak the kitty graphics
  protocol, which the greeting's image logo needs.
- **JetBrainsMono Nerd Font**, or the prompt, greeting and eza icons break.
- **Modern CLI replacements**: eza, bat, fd, ripgrep, fzf, zoxide. Aliases only
  activate when the tool exists, so install them.
- **bun over npm/npx**. `bunx`, not `npx`.
- **Desktop (Linux)**: caelestia dots, unmodified, with overrides in
  `linux/caelestia`. Binds and rules go through HyprMod (`linux/hyprmod`) so
  they're editable in its GUI; HyDE-style keybinds layered on caelestia's, with
  caelestia's originals unbound first. Terminal, browser (Zen) and Discord are
  opaque; workspaces show as numbers in the bar.
- **Theming follows the wallpaper.** caelestia sets terminal colours 0–18; the
  prompt and greeting reference palette indices, never hex, so they follow. On the
  Mac the terminal theme defines slots 16–18 to stand in.
- **Claude Code is the primary agent**; `shared/claude` is the most important
  package to get right.

## Layout

| Directory | Applies to | Contents |
|---|---|---|
| `shared/` | both | fish, starship, fastfetch, kitty, ghostty, git, claude, ccstatusline, ai-tools, nvim, vscode, cursor |
| `linux/` | CachyOS desktop | caelestia overrides, HyprMod file, `packages.md` |
| `mac/` | Mac | fish entry point, kitty colours, `wm/` (yabai, sketchybar, borders, linearmouse), `Brewfile` |
| `legacy/` | nobody | old zsh setup, delete after the Mac migrates |

Each package has a `SETUP.md`: files and destinations, install commands per OS,
gotchas, how to verify.

## Order

`shared/fish` and `shared/git` first, then the terminal, then `shared/starship`
and `shared/fastfetch`, then Claude, then the platform packages. On Linux,
caelestia's installer runs before any of this. Start a new shell before
verifying anything shell-dependent.

## Not in this repo

Credentials (SSH keys, `~/.claude.json`, tool auth files), shell history, caches,
and the fastfetch logo images. After setup these need doing by hand, so surface
them as a checklist: `gh auth login`, Claude Code sign-in, new SSH key, images
into `~/.config/fastfetch/logo/`.

## When you're done

Report what you copied, what you skipped and why, what you backed up, and the
manual steps outstanding. If a `SETUP.md` was wrong, fix it.
