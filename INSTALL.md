# Install

Setup is done by hand, one package at a time. Each package's `SETUP.md` says
where its files go, what to install first, and how to check the result.

## Before you start

- **Pick the machine.** The gaming PC (CachyOS) takes `linux/` and `shared/`.
  The Mac takes `mac/` and `shared/`.
- **Package names** are for CachyOS (pacman) and macOS (Homebrew). On another
  distro, translate them.
- **Read the diff before you overwrite.** If a file already exists and differs,
  compare it or back it up before you copy over it.
- **The repo is private for now.** Sign in with `gh auth login` before you
  clone it.

## Checking progress

Do the steps in order, and check each one before the next. Open a new shell
before you check anything that depends on the shell.

[`./status.sh`](status.sh) prints one line for each file the repo installs:

| Label | Meaning |
|---|---|
| `ok` | the live file matches the repo |
| `differs` | the live file differs from the repo |
| `missing` | not copied yet |
| `seeded` | differs, but the app rewrites this file itself |
| `skipped` | the app isn't installed |
| `leftover` | an old file still exists; remove it |

A step is done when its files print `ok` or `seeded`.

## CachyOS

1. **Packages.** Install everything in [`linux/packages.md`](linux/packages.md).
   Check: `pacman -Q` with the table's package names prints a version for each.
2. **Shell and git.** Copy [`shared/fish`](shared/fish/SETUP.md),
   [`linux/fish`](linux/fish/SETUP.md) and [`shared/git`](shared/git/SETUP.md).
   Check: `./status.sh`.
3. **Terminal.** Copy [`shared/kitty`](shared/kitty/SETUP.md). Noctalia writes
   its colours in step 6. Check: `./status.sh`.
4. **Prompt and greeting.** Copy [`shared/starship`](shared/starship/SETUP.md)
   and [`shared/fastfetch`](shared/fastfetch/SETUP.md), then open a new kitty
   window. Check: it shows the starship prompt and the greeting.
5. **Claude Code.** Copy [`shared/agents`](shared/agents/SETUP.md),
   [`shared/claude`](shared/claude/SETUP.md) and
   [`shared/ccstatusline`](shared/ccstatusline/SETUP.md). Check:
   `rtk init --show` reports everything as configured.
6. **Desktop**, in this order: [`linux/hypr`](linux/hypr/SETUP.md) with
   [`linux/uwsm`](linux/uwsm/SETUP.md) and the split-monitor-workspaces clone,
   [`linux/hyprmod`](linux/hyprmod/SETUP.md),
   [`linux/noctalia`](linux/noctalia/SETUP.md), [`linux/sddm`](linux/sddm/SETUP.md)
   and [`linux/wallpaper`](linux/wallpaper/SETUP.md). Check: `./status.sh`, then
   log out and back in. The custom login screen shows, Noctalia's bar appears,
   and every monitor plays its wallpaper.
7. **The rest:** [`linux/hyprsunset`](linux/hyprsunset/SETUP.md),
   [`linux/pipewire`](linux/pipewire/SETUP.md), [`linux/mpv`](linux/mpv/SETUP.md),
   [`linux/btop`](linux/btop/SETUP.md), [`linux/equibop`](linux/equibop/SETUP.md),
   [`linux/ssh`](linux/ssh/SETUP.md), [`linux/snapshots`](linux/snapshots/SETUP.md),
   then [`shared/nvim`](shared/nvim/SETUP.md),
   [`shared/vscode`](shared/vscode/SETUP.md),
   [`shared/cursor`](shared/cursor/SETUP.md) and
   [`shared/orca`](shared/orca/SETUP.md). Check: the Verify section of each.

## Mac

1. **Packages.** Install Homebrew, then run `brew bundle --file mac/Brewfile`
   ([`mac/Brewfile`](mac/Brewfile)). Karabiner-Elements asks for your password.
   Check: `brew bundle check --file mac/Brewfile` reports everything as
   satisfied.
2. **Shell and git.** Copy [`shared/fish`](shared/fish/SETUP.md),
   [`mac/fish`](mac/fish/SETUP.md) and [`shared/git`](shared/git/SETUP.md).
   Check: `./status.sh`.
3. **Terminal.** Copy [`shared/kitty`](shared/kitty/SETUP.md) with
   [`mac/kitty`](mac/kitty/SETUP.md), and
   [`shared/ghostty`](shared/ghostty/SETUP.md). Check: `./status.sh`.
4. **Prompt and greeting.** Copy [`shared/starship`](shared/starship/SETUP.md)
   and [`shared/fastfetch`](shared/fastfetch/SETUP.md), then open a new kitty
   window. Check: it shows the starship prompt and the greeting.
5. **Claude Code.** The same as CachyOS step 5.
6. **Desktop:** [`mac/wm`](mac/wm/SETUP.md), following its numbered steps.
   Check: its Verify section.
7. **The rest:** [`shared/nvim`](shared/nvim/SETUP.md),
   [`shared/vscode`](shared/vscode/SETUP.md),
   [`shared/cursor`](shared/cursor/SETUP.md) and
   [`shared/orca`](shared/orca/SETUP.md). Check: `./status.sh`.

## Manual steps

These need a password, a sign-in, or files the repo doesn't hold. Tick them off
after the steps above.

Both machines:

- [ ] A new SSH key with a passphrase, then `gh auth login` ([`shared/git`](shared/git/SETUP.md)).
- [ ] Register that key for commit signing before the first commit ([`shared/git`](shared/git/SETUP.md)).
- [ ] Sign in to Claude Code: run `claude` ([`shared/claude`](shared/claude/SETUP.md)).
- [ ] Sign in to Orca ([`shared/orca`](shared/orca/SETUP.md)).
- [ ] Greeting logo images into `~/.config/fastfetch/logo/` ([`shared/fastfetch`](shared/fastfetch/SETUP.md)).

CachyOS:

- [ ] Wallpaper stills into `~/Pictures/Wallpapers` ([`linux/hypr`](linux/hypr/SETUP.md)).
- [ ] The main wallpaper's still and `login.mp4` into `~/Pictures/Wallpapers/live` ([`linux/wallpaper`](linux/wallpaper/SETUP.md), [`linux/sddm`](linux/sddm/SETUP.md)).
- [ ] Lock-screen GIFs into `~/Pictures/lock-gifs` ([`linux/noctalia`](linux/noctalia/SETUP.md)).
- [ ] A profile picture at `~/.face`, then run `sddm-sync` ([`linux/sddm`](linux/sddm/SETUP.md)).
- [ ] Wallpaper Engine through Steam, with the Workshop wallpapers subscribed ([`linux/wallpaper`](linux/wallpaper/SETUP.md)).
- [ ] Local copies of the live wallpapers in `~/.local/share/live-wallpapers` ([`linux/wallpaper`](linux/wallpaper/SETUP.md)).
- [ ] Clone split-monitor-workspaces at the pinned commit ([`linux/hypr`](linux/hypr/SETUP.md)).
- [ ] Make Spotify writable and run `spicetify backup apply`, again after every Spotify update ([`linux/hypr`](linux/hypr/SETUP.md)).
- [ ] Enable the Noctalia plugins once with `noctalia msg plugins enable` ([`linux/noctalia`](linux/noctalia/SETUP.md)).
- [ ] Write `~/.config/code-flags.conf` for VS Code ([`shared/vscode`](shared/vscode/SETUP.md)).
- [ ] Answer the SSH key's passphrase dialog once and tick "Remember password" ([`linux/ssh`](linux/ssh/SETUP.md)).
- [ ] Set Equibop's tray and splash icons in its User Assets settings ([`linux/equibop`](linux/equibop/SETUP.md)).

Mac:

- [ ] Run [`mac/wm/macos-settings.sh`](mac/wm/macos-settings.sh), then log out and back in ([`mac/wm`](mac/wm/SETUP.md)).
- [ ] Grant AeroSpace Accessibility on its first start ([`mac/wm`](mac/wm/SETUP.md)).
- [ ] Allow Karabiner-Elements' driver and Input Monitoring, and pick ANSI if asked ([`mac/wm`](mac/wm/SETUP.md)).

## Not in this repo

Credentials, shell history, caches, and personal media: the greeting's logo
images, wallpapers, lock-screen GIFs and `~/.face`.
