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

- **CachyOS is the reference machine.** The Mac adapts the shared configs, not
  the other way round. When the Mac needs a different value, put it behind an OS
  guard (`CLAUDE.md` rule 4), so CachyOS behaves the same as before.
- **fish + starship**, everywhere. Not zsh, not powerlevel10k.
- **Terminal**: kitty on both machines; Ghostty stays configured on the Mac as a
  second terminal. Both speak the kitty graphics protocol, which the greeting's
  image logo needs.
- **JetBrainsMono Nerd Font**, or the prompt, greeting and eza icons break.
- **Modern CLI replacements**: eza, bat, fd, ripgrep, fzf, zoxide. Aliases only
  activate when the tool exists, so install them.
- **bun over npm/npx**. `bunx`, not `npx`.
- **Desktop (Linux)**: caelestia dots, unmodified, with overrides in
  `linux/caelestia`. Binds and rules go through HyprMod (`linux/hyprmod`) so
  they're editable in its GUI; HyDE-style keybinds layered on caelestia's, with
  caelestia's originals unbound first. Terminal, browser (Zen) and Discord are
  opaque; workspaces show as numbers in the bar. Default apps: Zen for web
  pages and PDFs, Dolphin for folders, mpv for images and videos (Gwenview for
  SVG and editing); see `linux/packages.md`. Login screen: SDDM with the
  caelestia "locklike" theme (`linux/sddm`). Discord: Equibop, caelestia-themed,
  is the default (Super+D, `discord://` links); the official app stays installed.
- **Desktop (Mac)**: AeroSpace + SketchyBar (`mac/wm`). Super is the key second
  from the spacebar, as on Linux; Karabiner sends Ctrl+Option for it, so every
  Cmd shortcut stays native. The Mac binds are a minimal subset of the Hyprland
  ones. Never change Hyprland to match the Mac.
- **Theming follows the terminal.** The prompt and greeting use named ANSI
  colours, never hex, so they follow whatever sets the palette: caelestia's
  wallpaper scheme on Linux, the Ghostty/kitty theme on the Mac. **No theming
  changes on the Mac**: nothing in this repo overrides its terminal palette.
- **Claude Code is the primary agent.** `shared/agents` holds the global
  instructions every agent reads, copied to `~/.claude/CLAUDE.md` and
  `~/.codex/AGENTS.md`; `shared/claude` holds Claude Code's own settings, hooks
  and skills. Both matter; get them right.

## Layout

| Directory | Applies to | Contents |
|---|---|---|
| `shared/` | both | fish, starship, fastfetch, kitty, ghostty, git, agents, claude, ccstatusline, nvim, vscode, cursor, orca |
| `linux/` | CachyOS desktop | caelestia overrides, HyprMod file, snapshots setup, mpv, `packages.md` |
| `mac/` | Mac | fish entry point, kitty colours, `wm/` (AeroSpace, SketchyBar, Karabiner, LinearMouse, macOS settings script), `Brewfile` |

Each package has a `SETUP.md`: files and destinations, install commands per OS,
gotchas, how to verify.

## Order

`shared/fish` and `shared/git` first, then the terminal, then `shared/starship`
and `shared/fastfetch`, then Claude, then the platform packages. On Linux,
caelestia's installer runs before any of this. Start a new shell before
verifying anything shell-dependent.

## Not in this repo

Agent tools, plugins and skills: see `shared/agents`.
Credentials (SSH keys, `~/.claude.json`, tool auth files), shell history,
caches, and the fastfetch logo images. After setup these need doing by hand, so surface
them as a checklist: `gh auth login`, Claude Code sign-in, new SSH key, images
into `~/.config/fastfetch/logo/`.

## Commits

Every commit subject ends with the device it was made on, in parentheses. Then
`git log --oneline` shows which machine each change came from:

    kitty: abstract socket on Linux, path socket only on macOS (cachy-os)

| Tag | Device |
|---|---|
| `cachy-os` | CachyOS desktop (hostname `cachyos`) |
| `macbook-pro` | the Mac |

A new machine picks a short kebab-case tag and adds it to this table in its
first commit. Commits before 2026-10-07 have no tag.

## When you're done

Report what you copied, what you skipped and why, what you backed up, and the
manual steps outstanding. If a `SETUP.md` was wrong, fix it.
