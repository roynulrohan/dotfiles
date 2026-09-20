# dotfiles

Config for a CachyOS + Hyprland desktop (caelestia dots, HyprMod) and a Mac
(AeroSpace, SketchyBar, kitty), sharing fish, starship, a fastfetch greeting,
kitty, git and Claude Code config between them.

No install script, no symlinks. Files get copied to where the app expects them
and copied back when they change. Every package has a `SETUP.md` saying where its
files go and how to install its dependencies; `manifest.tsv` lists the same
mapping for scripts; `./status.sh` shows which live files differ from the repo.

## Fresh machine

```bash
gh auth login && gh repo clone roynulrohan/dotfiles ~/dotfiles
cd ~/dotfiles && claude
```

Then: "Read AGENTS.md and set up this machine. It's the CachyOS desktop" (or the
Mac). Or do it by hand from the `SETUP.md` files.

## Layout

```
shared/   fish  starship  fastfetch  kitty  ghostty  git  agents  claude  ccstatusline  nvim  vscode  cursor
linux/    caelestia (overrides only)  hyprmod  packages.md
mac/      fish  kitty  wm (aerospace, sketchybar, karabiner, linearmouse)  Brewfile
```

## Keeping it current

Edit the live file, check with `./status.sh --diff`, copy into the repo, commit.
Or tell the agent "sync my kitty config into dotfiles".

## Not in here

Credentials, shell history, caches, and the greeting's logo images. `.gitignore`
blocks the obvious filenames as a backstop.
