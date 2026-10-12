# Install

There is no install script. Every package folder has a `SETUP.md` that says
where its files go, what to install first, and how to check the result.
`manifest.tsv` lists the same file mapping, and `./status.sh` shows which live
files differ from the repo. Files are copied, never symlinked.

## Before you start

- **Pick the machine.** The gaming PC (CachyOS) takes `linux/` and `shared/`.
  The Mac takes `mac/` and `shared/`. A headless box takes only steps 2 and 5
  below, and nothing visual.
- **Package names** are for CachyOS (pacman) and macOS (Homebrew). On another
  distro, translate them.
- **Never overwrite silently.** If a destination exists and differs, read the
  diff or back the file up before you copy over it.

## Checking progress

Do the steps in order, and check each one before the next. Start a new shell
before you check anything that depends on the shell.

`./status.sh` prints one line for each destination in `manifest.tsv`:

| Label | Meaning |
|---|---|
| `ok` | the live file matches the repo |
| `differs` | the live file differs from the repo |
| `missing` | not copied yet |
| `seeded` | differs, but the app rewrites this file itself |
| `skipped` | the app isn't installed |
| `leftover` | a retired file still exists; remove it |

A copy step is done when its files print `ok` or `seeded`.

## CachyOS

1. **Packages.** Install everything in [`linux/packages.md`](linux/packages.md). Check: `pacman -Q`
   with the table's package names prints a version for each.
2. **Shell and git.** Copy [`shared/fish`](shared/fish/SETUP.md), [`linux/fish`](linux/fish/SETUP.md) and [`shared/git`](shared/git/SETUP.md).
   Check: `./status.sh`.
3. **Terminal.** Copy [`shared/kitty`](shared/kitty/SETUP.md). Linux skips [`mac/kitty/colors.conf`](mac/kitty/colors.conf);
   Noctalia writes kitty's colours in step 6. Check: `./status.sh`.
4. **Prompt and greeting.** Copy [`shared/starship`](shared/starship/SETUP.md) and [`shared/fastfetch`](shared/fastfetch/SETUP.md), then
   open a new kitty window. Check: it shows the starship prompt and the
   greeting.
5. **Claude Code.** `rtk` must be on `PATH` first ([`shared/claude/SETUP.md`](shared/claude/SETUP.md),
   Dependencies). Copy [`shared/agents`](shared/agents/SETUP.md) (to `~/.claude/CLAUDE.md` and
   `~/.codex/AGENTS.md`), [`shared/claude`](shared/claude/SETUP.md) and [`shared/ccstatusline`](shared/ccstatusline/SETUP.md). Then run
   `rtk init -g`: it adds an `@RTK.md` line to the end of `~/.claude/CLAUDE.md`.
   Check: `rtk init --show` reports the hook, `RTK.md` and `@RTK.md` as
   configured. From then on `./status.sh` reports `~/.claude/CLAUDE.md` as
   `seeded` because of that line, and `~/.claude/settings.json` too once you
   enable plugins.
6. **Desktop**, in this order: [`linux/hypr`](linux/hypr/SETUP.md) with [`linux/uwsm`](linux/uwsm/SETUP.md) and the
   split-monitor-workspaces clone, [`linux/hyprmod`](linux/hyprmod/SETUP.md), [`linux/noctalia`](linux/noctalia/SETUP.md),
   [`linux/sddm`](linux/sddm/SETUP.md), [`linux/wallpaper`](linux/wallpaper/SETUP.md). Check: `./status.sh`, then log out and back
   in. The login screen shows the `noctalia-card` theme, Noctalia's bar
   appears, and every monitor plays its wallpaper.
7. **The rest:** [`linux/hyprsunset`](linux/hyprsunset/SETUP.md), [`linux/pipewire`](linux/pipewire/SETUP.md), [`linux/mpv`](linux/mpv/SETUP.md),
   [`linux/btop`](linux/btop/SETUP.md), [`linux/equibop`](linux/equibop/SETUP.md), [`linux/ssh`](linux/ssh/SETUP.md), [`linux/snapshots`](linux/snapshots/SETUP.md), then
   [`shared/nvim`](shared/nvim/SETUP.md), [`shared/vscode`](shared/vscode/SETUP.md), [`shared/cursor`](shared/cursor/SETUP.md), [`shared/orca`](shared/orca/SETUP.md), and
   [`shared/ghostty`](shared/ghostty/SETUP.md) if wanted. Check: `./status.sh`, and the Verify section of
   each package's `SETUP.md`.

## Mac

1. **Homebrew packages.** Install Homebrew, then run
   `brew bundle --file mac/Brewfile` in a real terminal: the Brewfile includes
   Karabiner-Elements, which asks for your password. Check:
   `brew bundle check --file mac/Brewfile` reports the dependencies as
   satisfied.
2. **Shell and git.** Copy [`shared/fish`](shared/fish/SETUP.md), [`mac/fish`](mac/fish/SETUP.md) and [`shared/git`](shared/git/SETUP.md). Check:
   `./status.sh`.
3. **Terminal.** Copy [`shared/kitty`](shared/kitty/SETUP.md) with [`mac/kitty`](mac/kitty/SETUP.md), and [`shared/ghostty`](shared/ghostty/SETUP.md).
   Check: `./status.sh`.
4. **Prompt and greeting.** Copy [`shared/starship`](shared/starship/SETUP.md) and [`shared/fastfetch`](shared/fastfetch/SETUP.md), then
   open a new kitty window. Check: it shows the starship prompt and the
   greeting.
5. **Claude Code.** The same as CachyOS step 5.
6. **Desktop:** [`mac/wm`](mac/wm/SETUP.md), following its numbered steps. Check: the Verify
   section of [`mac/wm/SETUP.md`](mac/wm/SETUP.md).
7. **The rest:** [`shared/nvim`](shared/nvim/SETUP.md), [`shared/vscode`](shared/vscode/SETUP.md), [`shared/cursor`](shared/cursor/SETUP.md),
   [`shared/orca`](shared/orca/SETUP.md). Check: `./status.sh`.

## Manual steps

These are not plain copies: they need a person, a password, files this repo
doesn't hold, or a command outside `manifest.tsv`. Tick them off after the
steps above.

Both machines:

- [ ] New SSH key with a passphrase, then `gh auth login` ([`shared/git/SETUP.md`](shared/git/SETUP.md)).
- [ ] Register that key for commit signing before the first commit ([`shared/git/SETUP.md`](shared/git/SETUP.md)).
- [ ] Claude Code sign-in: run `claude` ([`shared/claude/SETUP.md`](shared/claude/SETUP.md), Auth).
- [ ] Orca sign-in to its cloud account ([`shared/orca/SETUP.md`](shared/orca/SETUP.md), Install).
- [ ] Greeting logo images into `~/.config/fastfetch/logo/` ([`shared/fastfetch/SETUP.md`](shared/fastfetch/SETUP.md)).

CachyOS:

- [ ] Wallpaper stills into `~/Pictures/Wallpapers` ([`linux/hypr/SETUP.md`](linux/hypr/SETUP.md), Install).
- [ ] The main wallpaper's still and `login.mp4` into `~/Pictures/Wallpapers/live` ([`linux/wallpaper/SETUP.md`](linux/wallpaper/SETUP.md), [`linux/sddm/SETUP.md`](linux/sddm/SETUP.md), Login video).
- [ ] Lock-screen GIFs into `~/Pictures/lock-gifs` ([`linux/noctalia/SETUP.md`](linux/noctalia/SETUP.md), Lock screen).
- [ ] Profile picture at `~/.face`, then run `sddm-sync` ([`linux/sddm/SETUP.md`](linux/sddm/SETUP.md)).
- [ ] Wallpaper Engine through Steam, with the Workshop wallpapers subscribed ([`linux/wallpaper/SETUP.md`](linux/wallpaper/SETUP.md), Install).
- [ ] Local live-wallpaper copies in `~/.local/share/live-wallpapers` ([`linux/wallpaper/SETUP.md`](linux/wallpaper/SETUP.md), Memory).
- [ ] Clone split-monitor-workspaces at the pinned commit ([`linux/hypr/SETUP.md`](linux/hypr/SETUP.md), Per-monitor workspaces).
- [ ] Make Spotify writable and run `spicetify backup apply`, again after every Spotify update ([`linux/hypr/SETUP.md`](linux/hypr/SETUP.md), Install).
- [ ] Enable the Noctalia plugins once with `noctalia msg plugins enable` ([`linux/noctalia/SETUP.md`](linux/noctalia/SETUP.md), Install and Update widget).
- [ ] Write `~/.config/code-flags.conf` for VS Code ([`shared/vscode/SETUP.md`](shared/vscode/SETUP.md)).
- [ ] Answer the SSH key's passphrase dialog once and tick "Remember password" ([`linux/ssh/SETUP.md`](linux/ssh/SETUP.md)).
- [ ] Set Equibop's tray and splash icons in its User Assets settings ([`linux/equibop/SETUP.md`](linux/equibop/SETUP.md)).

Mac:

- [ ] Run [`mac/wm/macos-settings.sh`](mac/wm/macos-settings.sh), then log out and back in ([`mac/wm/SETUP.md`](mac/wm/SETUP.md)).
- [ ] Grant AeroSpace Accessibility on its first start ([`mac/wm/SETUP.md`](mac/wm/SETUP.md)).
- [ ] Allow Karabiner-Elements' driver and Input Monitoring, and pick ANSI if asked ([`mac/wm/SETUP.md`](mac/wm/SETUP.md)).

## Not in this repo

Credentials (SSH keys, `~/.claude.json`, tool auth files), shell history,
caches, agent plugins and skills ([`shared/agents`](shared/agents/SETUP.md)), and personal media: the
fastfetch logo images, wallpapers, lock-screen GIFs and `~/.face`.
