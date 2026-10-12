# Setting up a machine for Roynul

This repo holds real config files plus per-package instructions. There is no
install script. Each package's `SETUP.md` says where its files go, and
`manifest.tsv` lists the same mapping. `./status.sh` shows which live files
differ from the repo. The setup steps for each machine are in `INSTALL.md`.
Read "Editing this repo" before you change anything here.

## Before you start

1. **Ask what the machine is** (`INSTALL.md`, Before you start).
2. **Detect the platform** with `uname -s`. Packages are written for
   CachyOS/pacman and macOS/Homebrew. Other distros: translate the package names.
3. **Never clobber silently.** If a destination exists and differs, show the
   diff or back it up before copying over it.

## Preferences

These explain why the configs look the way they do. Honour them when you hit a
decision the repo doesn't cover. Dates, history and details are in the package
docs each line points to.

### Both machines

- **CachyOS is the reference machine.** The Mac adapts the shared configs, not
  the other way round. When the Mac needs a different value, put it behind an
  OS guard (rule 4 in "Editing this repo"), so CachyOS behaves the same as
  before.
- **fish + starship**, everywhere. Not zsh, not powerlevel10k.
- **kitty is the terminal** on both machines. Ghostty stays configured on the
  Mac as a second terminal. Both speak the kitty graphics protocol, which the
  greeting's image logo needs.
- **JetBrainsMono Nerd Font**, or the prompt, greeting and eza icons break.
- **Modern CLI replacements**: eza, bat, fd, ripgrep, fzf, zoxide. Aliases only
  activate when the tool exists, so install them.
- **bun over npm/npx**: `bunx`, not `npx`. Exception: in a repo with its own
  lockfile and scripts, use what that repo uses.
- **The prompt and greeting follow the terminal palette.** They use named ANSI
  colours, never hex. On Linux a Noctalia template writes kitty's theme from
  the wallpaper palette (`shared/kitty/SETUP.md`).
- **No new theming on the Mac.** It keeps the palettes this repo ships for it:
  Catppuccin Frappé for kitty (`mac/kitty/colors.conf`) and Raycast Dark for
  Ghostty (`shared/ghostty/auto/theme.ghostty`). Don't add a palette
  generator or recolour them.
- **Claude Code is the primary agent.** `shared/agents` holds the global
  instructions every agent reads; `shared/claude` holds Claude Code's own
  `settings.json`. Plugins and skills are installed per machine. Setup is right
  when `rtk init --show` reports everything as configured, and `./status.sh`
  shows no difference for these files except the expected ones in step 5 of
  `INSTALL.md`.

### CachyOS desktop

- **Hyprland with the Noctalia shell** (`linux/hypr`, `linux/noctalia`).
  Noctalia is the top bar, launcher, lock, idle and notifications. The desktop
  ran on caelestia before; that history is in `history/caelestia/README.md`.
- **HyprMod first.** Binds and rules go through HyprMod (`linux/hyprmod`) where
  it can express them. The rest goes in `hypr-user.lua` (`linux/hypr/SETUP.md`).
- **HyDE-style keybinds on top of caelestia's.** Unbind caelestia's original
  before you replace it, or both fire (`linux/hyprmod/SETUP.md`).
- **One convention for window and image-viewer controls**: arrows move, Shift
  resizes, Alt makes the step fine (`linux/hypr/SETUP.md`, Window mode;
  `linux/mpv`). New binds of that kind follow it.
- **Workspace and monitor keys keep caelestia's meanings**: Shift takes the
  window along, Alt sends it without following (`linux/hypr/SETUP.md`).
- **Each monitor has its own workspaces 1–10**, shown as numbers in the bar
  (`linux/hypr/SETUP.md`, Per-monitor workspaces).
- **Terminal, browser (Zen) and Discord are opaque.** Other windows keep the
  default transparency (`linux/hyprmod/SETUP.md`).
- **Default apps**: Zen for web pages and PDFs, Dolphin for folders, mpv for
  images and videos, Gwenview for SVG and editing (`linux/packages.md`).
- **Equibop is the Discord app** (Super+D, `discord://` links). The official
  `discord` package stays installed (`linux/packages.md`, `linux/equibop`).
- **Live wallpapers on every monitor**, from Wallpaper Engine. Noctalia gets a
  still of the main one only for its colours (`linux/wallpaper/SETUP.md`).
- **Login screen: SDDM** with our `noctalia-card` theme, which follows
  Noctalia's colours (`linux/sddm`).
- **No EasyEffects.** PipeWire's own filter-chain runs the G432 headset's EQ
  (`linux/pipewire`).
- **Night light always on**, through hyprsunset (`linux/hyprsunset`).

### Mac desktop

- **AeroSpace + SketchyBar** (`mac/wm`).
- **Super is the key second from the spacebar**, as on Linux. Karabiner sends
  Ctrl+Option for it, so every Cmd shortcut stays native.
- **The Mac binds are a smaller copy of the Hyprland ones.** One pair differs
  because Super on the Mac already includes Ctrl: Super+Shift+arrows moves a
  window (Ctrl+Super+Shift+arrows on Linux), and Super+Minus and Super+Equal
  resize (Super+Shift+arrows on Linux) (`mac/wm/SETUP.md`, Binds). Never change
  Hyprland to match the Mac.

### Key roles (CachyOS)

The user ranked the desktop's keys by role. The role matters, not the app or
the exact key. Copied from the Preferences in
`history/caelestia/hypr-reference/README.md`, which recorded them against
caelestia's keys.

- **Must:** Super+T terminal, Super+E file manager, Super+B browser; Super+M
  music, Super+D chat and Super+S scratch (pop-up workspaces), and Super+Alt+S
  to send a window to scratch.
- **Use:** the launcher; lock; clipboard history; the keyboard's own media
  keys (through Fn), volume knob and mute; Super+Shift+S region screenshot on
  a frozen screen; colour picker; restarting the shell (Ctrl+Super+Alt+R).
- **Nice to have:** session menu, emoji picker, editor on Super+C, system
  monitor pop-up (Ctrl+Shift+Esc).
- **Not used, or didn't come up:** Print and Super+P screenshots; todo pop-up
  (Super+R, "don't care"); F10–F12 volume (the keyboard has its own keys, and
  these take F11 fullscreen and F12 developer tools away from apps).
- **Didn't know about, open to whatever the shell offers:** sidebar, all
  panels, clear notifications, restart and lock, recording, deleting
  clipboard entries, Ctrl+Super+Space media keys, audio mixer.
- **Pop-up workspaces** other than music, chat and scratch are "messy and
  unused". Windows come back with the workspace number keys. Open to
  rethinking them.

## Layout

| Directory | Applies to | Packages |
|---|---|---|
| `shared/` | both | `fish`, `starship`, `fastfetch`, `kitty`, `ghostty`, `git`, `agents`, `claude`, `ccstatusline`, `nvim`, `vscode`, `cursor`, `orca` |
| `linux/` | CachyOS desktop | `fish` (entry point), `hypr` (Hyprland), `noctalia` (shell), `hyprmod`, `sddm` (login screen), `wallpaper` (live wallpapers), `mpv`, `pipewire` (headset EQ), `hyprsunset` (night light), `btop`, `equibop` (Discord), `uwsm` (session environment), `ssh` (key unlock), `snapshots`, `packages.md` |
| `mac/` | Mac | `fish` (entry point), `kitty` (colours), `wm` (AeroSpace, SketchyBar, Karabiner, LinearMouse, macOS settings script), `Brewfile` |
| `history/` | nothing; reference only | `caelestia` (the previous desktop base and a copy of its Hyprland config) |

Each package has a `SETUP.md`: files and destinations, install commands per OS,
gotchas, how to verify. `history/` holds what the setup no longer uses; its
folders are not packages and have a `README.md` instead.

## Setting up a machine

Follow `INSTALL.md` step by step, and check each step before the next. When
you're done, give the user the manual steps still open as a checklist.

## Editing this repo

These rules apply to every edit, by any agent.

1. **Never commit a credential.** Some configs are committed *because* their
   key fields are empty. If a machine fills one in, don't copy that key back.
2. **Copy, don't symlink.** Machines keep normal files in normal places. This
   repo is the source to copy from and the place to copy changes back to.
   `manifest.tsv` maps repo paths to destinations; `./status.sh` shows drift.
   Its header explains the modes: `seed` for a file the app rewrites, the
   `needs` column for an app a machine may not have, `manual` for a file that
   is run or applied in place, and a `gone` row when you retire a destination.
3. **Own what you adopt; never mix in a framework's live tree.**
   `~/.config/hypr` started as caelestia's and is now ours (`linux/hypr`);
   caelestia's original stays as a reference copy in
   `history/caelestia/hypr-reference`. `~/.config/fish` is ours too: `conf.d`
   (`shared/fish`) and `config.fish` (`linux/fish`, `mac/fish`). Other files a
   framework or tool drops in there stay out of `manifest.tsv`.
   When you copy someone else's work into the repo, credit it in `CREDITS.md`.
4. **Keep shared configs portable.** No hardcoded home paths. Guard OS-specific
   bits so the other OS skips them. Document OS differences in the package's
   `SETUP.md`.
5. **Tag every commit with its device.** End the subject with the device tag in
   parentheses, so `git log --oneline` shows which machine each change came
   from. The tags are below.

Example subject:

    kitty: abstract socket on Linux, path socket only on macOS (cachy-os)

| Tag | Device | Hostname |
|---|---|---|
| `cachy-os` | CachyOS desktop | `cachyos` |
| `macbook-pro` | the Mac | TODO: ask the user |

A new machine picks a short kebab-case tag and adds a row to this table, and a
section to `machines.md`, in its first commit. Commits before 2026-10-07 have no tag.

6. **Read the diff before you copy a live file back.** Copy back only the lines
   that belong in the repo. Lines for one machine only, such as an installer's
   PATH addition, go in that file's local slot, which stays out of the repo:
   `~/.config/fish/local.fish`, `~/.gitconfig.local` or kitty's `local.conf`.
   Never copy a whole live file over its repo copy without reading the
   difference first.
7. **Run `./check.sh` after `git add` and before every commit.** It checks
   syntax (JSON, TOML, Python, Lua, shell, fish), the manifest rows, that every
   file has a manifest row, and secrets through gitleaks. Commit only when it
   prints no `FAIL` line.

## When you're done

Report what you copied, what you skipped and why, what you backed up, and the
manual steps outstanding. If a `SETUP.md` was wrong, fix it.
