# sddm

The login screen on CachyOS: SDDM with our own theme, `noctalia-card`
(`themes/noctalia-card`), modelled on our Noctalia lock screen. It is a fork of
the caelestia "locklike" theme
([ItsABigIgloo/caelestia-sddm](https://github.com/ItsABigIgloo/caelestia-sddm));
see its `README.md`. SDDM replaces KDE's Plasma Login Manager, which came with
the Plasma install profile.

| Repo | Destination |
|---|---|
| `themes/noctalia-card/` | `/usr/share/sddm/themes/noctalia-card/` (root), plus the `theme.conf.user` link below |
| `noctalia-card.conf` | `/etc/sddm.conf.d/noctalia-card.conf` (root) |
| `x11.conf` | `/etc/sddm.conf.d/x11.conf` (root) |
| `Xsetup` | `/etc/sddm/Xsetup` (root, executable) |
| `sddm-sync` | `~/.local/bin/sddm-sync` |

`noctalia-card.conf` selects the theme, clears CachyOS's `InputMethod` (Qt's
on-screen keyboard would open on the password field) and sets the greeter's
environment. It sets nothing about sessions: the theme preselects the first
session with "uwsm" in its name.

## How it stays in sync

The greeter runs as user `sddm` and cannot read your home folder. So
everything personal it shows lives in `/var/lib/sddm-assets`: a folder you
own, readable by everyone. The theme reads it through `assetsDir` in its
`theme.conf`, and its colours through `theme.conf.user`, a link to
`colours.conf` there (SDDM reads `theme.conf.user` over `theme.conf`).

| File | What | Kept fresh by |
|---|---|---|
| `colours.conf` | Noctalia's palette, in the theme's key names | Noctalia's `sddm` colour template (`linux/noctalia`), at every palette change |
| `background` | the wallpaper the palette comes from | the same template's `post_hook` |
| `current.gif` | the lock screen's GIF card | `reroll.py` after every unlock, so the login shows the GIF the next lock would |
| `background.mp4` | `~/Pictures/Wallpapers/live/login.mp4` | `sddm-sync`, by hand |
| `faces/<user>.face.icon` | `~/.face` | `sddm-sync`, by hand |
| `location.json` | Noctalia's weather location | `sddm-sync`, by hand |

No root at run time, and no `[hooks]` keys: the still rides on the template
and the GIF on `reroll.py`, so nothing merges with `lock.toml`'s
`session_unlocked`. Run `sddm-sync` after changing the video, `~/.face` or the
weather location; it also asks Noctalia to render its templates again
(`noctalia msg templates-apply`), which rewrites the colours and the still.
`SDDM_ASSETS=<dir> sddm-sync` copies into another folder, for a dry run, and
skips that last step.

**Security:** the theme's QML stays root-owned in `/usr/share`, so the folder
can change colours and pictures, never code. Any program running as you can
change the login screen's pictures. On this single-user PC that is acceptable.

## Install

Needs the packages in the theme's `README.md` (Requirements) and `linux/noctalia`
set up first (its lock screen makes `current.gif`). Run these once, from this
folder, in your own terminal; the commands work in fish and bash:

```bash
# 1. Back up the files this replaces. Not into /etc/sddm.conf.d: SDDM reads
#    every file there. (A new machine has nothing to back up; skip this.)
sudo install -d /etc/sddm/before-noctalia-card
sudo cp -a /etc/sddm/Xsetup /etc/sddm.conf.d/x11.conf /etc/sddm/before-noctalia-card/
# 2. The synced assets folder: yours, readable by the greeter.
sudo install -d -o "$USER" -g "$USER" -m 755 /var/lib/sddm-assets
# 3. The theme, and its link to the synced colours.
sudo cp -rT themes/noctalia-card /usr/share/sddm/themes/noctalia-card
sudo ln -sfn /var/lib/sddm-assets/colours.conf /usr/share/sddm/themes/noctalia-card/theme.conf.user
# 4. Monitor layout and SDDM config.
sudo install -m 755 Xsetup /etc/sddm/Xsetup
sudo install -m 644 x11.conf noctalia-card.conf /etc/sddm.conf.d/
# 5. As you, no sudo: Noctalia's side (linux/noctalia), then the first sync.
# These overwrite live files: on a machine that already has them, run
# ../../status.sh first and copy back anything newer before continuing.
# Atomic: Noctalia watches config.toml and could read a half-copied file.
cp ../noctalia/config.toml ~/.config/noctalia/config.toml.new && mv ~/.config/noctalia/config.toml.new ~/.config/noctalia/config.toml
cp ../noctalia/templates/sddm-theme.conf ~/.config/noctalia/templates/
cp ../noctalia/lock/scripts/reroll.py ~/.local/share/noctalia/lock/scripts/
install -Dm 755 sddm-sync ~/.local/bin/sddm-sync
sddm-sync
```

Check: `ls -l /var/lib/sddm-assets` lists `background`, `background.mp4`,
`colours.conf`, `current.gif`, `faces` and `location.json`, every file
`-rw-r--r--`. `sudo -u sddm cat /var/lib/sddm-assets/colours.conf` proves the
greeter's user can read them.

On a machine that still runs Plasma Login Manager, switch login managers,
then reboot:

```bash
sudo systemctl disable plasmalogin.service && sudo systemctl enable sddm.service
```

**Updating the theme** after a change in the repo: step 3's `cp` again. It
keeps the link. A file deleted from the repo stays in `/usr/share` until you
delete it there.

## Preview

Before logging out, in a full-screen window on every monitor (close it with
Ctrl+C in its terminal):

```bash
QML_XHR_ALLOW_FILE_READ=1 QT_QPA_PLATFORM=xcb sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/noctalia-card
```

Test mode runs as you, not as `sddm`, so it can't prove the folder's
permissions (the `sudo -u sddm` check above does). SDDM reports the power
actions unavailable in test mode, so the power buttons show dimmed, and
`sddm.login()` does nothing. The greeter logs to the journal
(`journalctl --user -t sddm-greeter-qt6`). The real test: log out (`uwsm
stop`), log in, and check that KDE Wallet unlocks.

## The way back

If the login screen is black or broken: Ctrl+Alt+F3 for a text login, log in,
then switch to Breeze, the theme CachyOS's
`/usr/lib/sddm/sddm.conf.d/general.conf` selects, and put the old monitor setup
back:

```bash
sudo sed -i 's/^Current=noctalia-card$/Current=breeze/' /etc/sddm.conf.d/noctalia-card.conf
sudo cp /etc/sddm/before-noctalia-card/Xsetup /etc/sddm/Xsetup
sudo cp /etc/sddm/before-noctalia-card/x11.conf /etc/sddm.conf.d/x11.conf
sudo systemctl restart sddm
```

The old Xsetup turns the side monitors off, so the login shows on one
monitor. To drop our config completely, delete
`/etc/sddm.conf.d/noctalia-card.conf` instead of the `sed` line: CachyOS's
defaults then apply alone, Breeze included, with Qt's on-screen keyboard back
on the password field. Until 2026-10-09 the way back was caelestia's login
theme; it was uninstalled with caelestia.

Back to Plasma Login Manager:

```bash
sudo systemctl disable sddm.service && sudo systemctl enable plasmalogin.service && sudo reboot
```

## Things to know

- **Why `x11.conf`:** `cachyos-kde-settings` ships
  `/usr/lib/sddm/sddm.conf.d/zz-wayland.conf`, which draws the login screen with
  KWin on Wayland. The theme runs on X11 (`noctalia-card.conf` sets
  `QT_QPA_PLATFORM=xcb`), so without the override the login screen fails at
  boot. Files in `/etc/sddm.conf.d` win over `/usr/lib/sddm/sddm.conf.d`
  (`sddm.conf(5)`). The preview works either way, because it runs inside
  Hyprland.
- **Monitors:** X11 mirrors every monitor at the login screen. `x11.conf`
  makes SDDM run `Xsetup` first, which places every connected monitor side by
  side in the order its `ORDER` line gives (VG248, VG279QM, HP 27es, by EDID
  model name; unlisted monitors go on the right) and makes the main monitor
  X's primary output. The `noctalia-card` theme shows the login on the primary
  monitor and, on every other monitor, the lock screen's side view: the clock
  and date over the blurred still. Only the main monitor plays the login video.
  Xsetup finds the main monitor by the model name in its EDID
  (`MAIN_MODEL=VG279QM`, read from `xrandr --verbose`). Output names don't
  work, because the NVIDIA driver names them differently under X11 (the left
  VG248 is X's `DP-2`). Refresh rate doesn't either: on 2026-10-07 X11 gave
  the VG248 a higher one, so the login screen landed on the left monitor. With
  no matching monitor it falls back to the highest refresh rate.
  `XSETUP_DRY_RUN=1 ./Xsetup` prints the `xrandr` command instead of running
  it. Hyprland sets its own layout after login.
  - **Main monitor unplugged at boot:** the monitor with the highest refresh
    rate becomes primary (the VG248 today) and gets the full login.
  - **One monitor:** it becomes primary and gets the full login.
  - **Keyboard:** keys always go to the login's password field. The side
    windows refuse focus, so a click on a side monitor changes nothing; the
    greeter logs a harmless "requestActivate() called for ... which has
    Qt::WindowDoesNotAcceptFocus set" for each side window at start.
  - **Monitor plugged in after the login screen appears:** Xsetup has already
    run, so nothing turns the new monitor on; it stays dark until the next
    time SDDM starts X (after a log out, or a reboot). If something does turn
    it on, SDDM opens a window there and it shows the side view.
  - **Main monitor unplugged while the login screen shows:** untested on real
    hardware. Nothing reruns `xrandr`, so X most likely keeps the output in
    its layout and the login stays on the dark monitor; typing the password
    and pressing Enter still logs in, because the keyboard stays on the
    login's password field. If X does drop the screen, the theme moves the
    login to the new primary monitor.
- **Settings** (12-hour clock, blur, tint, video on/off) are in the theme's
  `theme.conf`; change them in the repo, then update the theme (Install, step
  3). Don't put them in `colours.conf`: Noctalia rewrites it.
- **Colours** follow the lock screen: each key takes the Noctalia role the lock
  uses (`primary` is Noctalia's `primary`, `text` its `on_surface`), from the
  palette the shell uses, scheme included. The fallback colours in `theme.conf`
  show only while `colours.conf` is missing.
- **The old `sddm-sync`** copied caelestia's root-owned theme with sudo, fed
  by a caelestia template. Both are retired, and caelestia's theme was
  uninstalled on 2026-10-09.
- **Frozen screen after logging out:** happened twice on 2026-10-07. caelestia's
  logout button (the shell in use then) killed the whole login session, `sddm-helper` included, so SDDM
  logged "Process crashed" and never showed the login screen again (Hyprland
  also segfaults in `libaquamarine` while closing, an upstream bug). Log out
  with `uwsm stop`, which the Hyprland wiki recommends for uwsm sessions: it
  brings the graphical session down in order and lets SDDM's helper exit
  normally. Noctalia's own log out exits Hyprland directly, so its session menu
  runs `uwsm stop` instead (`linux/noctalia/config.toml`). Verified on
  2026-10-08: log out returned to the login screen and the next login was clean. If it freezes anyway, Ctrl+Alt+Delete reboots (systemd treats
  it as a reboot request); Ctrl+Alt+F2, the terminal SDDM's login screen runs
  on, may bring it back.


## Login video

The theme loops `background.mp4` from the assets folder (or `.webm`, `.mkv`,
`.mov`, `.m4v`, `.avi`) over the still, silently, on the main monitor only.
`sddm-sync` copies it from `~/Pictures/Wallpapers/live/login.mp4` (not in this
repo; `LOGIN_VIDEO` overrides it): a 1080p copy without audio of the main live
wallpaper, since the login screen shows on one 1080p monitor and may decode on
the CPU:

```bash
ffmpeg -i <video> -vf scale=1920:1080 -an -c:v libx264 -crf 22 -pix_fmt yuv420p -movflags +faststart ~/Pictures/Wallpapers/live/login.mp4
```

## Verify

```bash
systemctl status display-manager | head -2                      # sddm.service
grep -h '^Current' /etc/sddm.conf.d/*.conf | tail -1            # Current=noctalia-card
readlink /usr/share/sddm/themes/noctalia-card/theme.conf.user   # /var/lib/sddm-assets/colours.conf
```
