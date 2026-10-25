# SDDM

The login screen on CachyOS: SDDM with this repo's theme, `noctalia-card`, made
to look like the Noctalia lock screen. The theme is a fork of the "locklike"
theme from
[ItsABigIgloo/caelestia-sddm](https://github.com/ItsABigIgloo/caelestia-sddm).
Its [`README.md`](themes/noctalia-card/README.md) lists the changes and the
licence.

## Files

| Repo | Destination |
|---|---|
| [`themes/noctalia-card/`](themes/noctalia-card/README.md) | `/usr/share/sddm/themes/noctalia-card/` (root), plus the `theme.conf.user` link (Install, step 3) |
| [`noctalia-card.conf`](noctalia-card.conf) | `/etc/sddm.conf.d/noctalia-card.conf` (root) |
| [`x11.conf`](x11.conf) | `/etc/sddm.conf.d/x11.conf` (root) |
| [`Xsetup`](Xsetup) | `/etc/sddm/Xsetup` (root, executable) |
| [`sddm-sync`](sddm-sync) | `~/.local/bin/sddm-sync` |

Outside the repo: `/var/lib/sddm-assets`, the folder of pictures and colours
the greeter reads (Notes, "How it stays in sync"), and the login video,
`~/Pictures/Wallpapers/live/login.mp4`.

## Install

On CachyOS or Arch:

```bash
sudo pacman -S sddm qt6-5compat qt6-multimedia ttf-material-symbols-variable xorg-xrandr ffmpeg
```

`qt6-5compat`, `qt6-multimedia` (video) and `ttf-material-symbols-variable`
(icons) are the theme's requirements, listed in its
[`README.md`](themes/noctalia-card/README.md). `Xsetup` runs `xrandr` from
`xorg-xrandr`. `ffmpeg` makes the login video.

Set up [`linux/noctalia`](../noctalia/SETUP.md) first: its lock screen makes
`current.gif`. Before step 4, set `MAIN_MODEL` and `ORDER` in `Xsetup` to your
monitors' EDID model names (Notes, "Monitors"). `hyprctl monitors` shows each
name on its `model:` line. Then run these commands once, from this folder, in
your own terminal. They work in fish and bash:

```bash
# 1. Back up the files this replaces. Not into /etc/sddm.conf.d: SDDM reads
#    every file there. A new machine has nothing to back up: skip this step.
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

If the machine runs Plasma Login Manager (CachyOS's Plasma install profile
ships it), switch login managers and remove it, then reboot:

```bash
sudo systemctl disable plasmalogin.service && sudo systemctl enable sddm.service
sudo pacman -Rns plasma-login-manager
```

### Login video

`sddm-sync` copies the video from `~/Pictures/Wallpapers/live/login.mp4`
(`LOGIN_VIDEO` overrides the path). Make it from the main live wallpaper: a
1080p copy without audio, because the login screen plays it on one 1080p
monitor and without sound. Then run `sddm-sync` again.

```bash
ffmpeg -i <video> -vf scale=1920:1080 -an -c:v libx264 -crf 22 -pix_fmt yuv420p -movflags +faststart ~/Pictures/Wallpapers/live/login.mp4
```

### Updating the theme

After a change in the repo, run step 3's `cp` again. It keeps the link. A file
deleted from the repo stays in `/usr/share` until you delete it there.

## Notes

### How it stays in sync

The greeter runs as user `sddm` and cannot read your home folder. So
everything personal it shows lives in `/var/lib/sddm-assets`, a folder you own
that everyone can read. The theme finds the folder through `assetsDir` in its
`theme.conf`. It reads the colours from `theme.conf.user`, a link to
`colours.conf` in that folder. SDDM reads `theme.conf.user` over `theme.conf`.

| File | What | Kept fresh by |
|---|---|---|
| `colours.conf` | Noctalia's palette, in the theme's key names | Noctalia's `sddm` colour template ([`linux/noctalia`](../noctalia/SETUP.md)), at every palette change |
| `background` | the wallpaper the palette comes from | the same template's `post_hook` |
| `current.gif` | the lock screen's GIF card | `reroll.py` after every unlock, so the login shows the GIF the next lock would |
| `background.mp4` | `~/Pictures/Wallpapers/live/login.mp4` | `sddm-sync`, by hand |
| `faces/<user>.face.icon` | `~/.face` | `sddm-sync`, by hand |
| `location.json` | Noctalia's weather location | `sddm-sync`, by hand |

Nothing needs root at run time. The template carries the still and
`reroll.py` copies the GIF, so the sync needs no `[hooks]` keys that could
clash with `session_unlocked` in `lock.toml`.

Run `sddm-sync` after you change the video, `~/.face` or the weather location.
It also runs `noctalia msg templates-apply`, which writes the colours and the
still again. `SDDM_ASSETS=<dir> sddm-sync` copies into another folder for a
dry run and skips `templates-apply`.

**Security:** the theme's QML stays root-owned in `/usr/share`, so the folder
can change colours and pictures, never code. Any program that runs as you can
change the login screen's pictures. That is acceptable on a single-user
machine.

### SDDM config

- `noctalia-card.conf` selects the theme and sets the greeter's environment.
  It also clears CachyOS's `InputMethod`, because Qt's on-screen keyboard
  opens on the password field. It sets nothing about sessions: the theme
  preselects the first session with "uwsm" in its name.
- **Why `x11.conf`:** `cachyos-kde-settings` ships
  `/usr/lib/sddm/sddm.conf.d/zz-wayland.conf`, which draws the login screen
  with KWin on Wayland. The theme runs on X11 (`noctalia-card.conf` sets
  `QT_QPA_PLATFORM=xcb`), so without the override the login screen fails at
  boot. Files in `/etc/sddm.conf.d` win over `/usr/lib/sddm/sddm.conf.d`
  (`sddm.conf(5)`). The preview works either way, because it runs inside
  Hyprland.

### Monitors

X11 mirrors every monitor at the login screen, so `x11.conf` makes SDDM run
`Xsetup` first. `Xsetup` places the connected monitors side by side in
`ORDER`, by EDID model name, and puts unlisted monitors on the right. The
monitor that matches `MAIN_MODEL` becomes X's primary output. If none
matches, for example when the main monitor is unplugged at boot, the monitor
with the highest refresh rate becomes primary. `XSETUP_DRY_RUN=1 ./Xsetup`
prints the `xrandr` command and does not run it.

The primary monitor shows the login and plays the login video. Every other
monitor shows the lock screen's side view: the clock and date over the
blurred still. Hyprland sets its own layout after login.

- **Keyboard:** keys always go to the login's password field. The side
  windows refuse focus, so a click on a side monitor changes nothing. At
  start, the greeter logs "requestActivate() called for ... which has
  Qt::WindowDoesNotAcceptFocus set" once for each side window. This message
  is harmless.
- **Monitor plugged in after the login screen appears:** `Xsetup` has already
  run, so nothing turns the new monitor on. It stays dark until SDDM starts X
  again, after a log out or a reboot.
- **Monitor removed while the login screen shows:** if X removes the main
  monitor's screen, the theme moves the login to the new primary monitor.

### Settings and colours

- **Settings** (12-hour clock, blur, tint, video on or off) are in the theme's
  `theme.conf`. Change them in the repo, then update the theme (Install,
  "Updating the theme"). Don't put them in `colours.conf`, because Noctalia
  rewrites it.
- **Colours** follow the lock screen. Each key takes the Noctalia role that
  the lock uses, from the palette the shell uses, scheme included. For
  example, `primary` is Noctalia's `primary` and `text` is its `on_surface`.
  The fallback colours in `theme.conf` show only while `colours.conf` is
  missing.

### Logging out

Log out with `uwsm stop`, which the Hyprland wiki recommends for uwsm
sessions. It brings the graphical session down in order and lets SDDM's
helper exit normally. Don't kill the whole login session. That kills
`sddm-helper` too: SDDM logs "Process crashed", and the screen freezes with
no login screen. Noctalia's session menu runs `uwsm stop` for this reason
([`linux/noctalia`](../noctalia/SETUP.md)). Hyprland can also segfault in
`libaquamarine` while it closes, which is an upstream bug.

If the screen freezes anyway, press Ctrl+Alt+Delete to reboot. systemd treats
it as a reboot request. Ctrl+Alt+F2, the terminal that SDDM's login screen
runs on, may bring the login screen back.

### The way back

If the login screen is black or broken, press Ctrl+Alt+F3 for a text login and
log in. Then switch to Breeze, the theme that CachyOS's
`/usr/lib/sddm/sddm.conf.d/general.conf` selects, and put the backed-up
monitor setup back:

```bash
sudo sed -i 's/^Current=noctalia-card$/Current=breeze/' /etc/sddm.conf.d/noctalia-card.conf
sudo cp /etc/sddm/before-noctalia-card/Xsetup /etc/sddm/Xsetup
sudo cp /etc/sddm/before-noctalia-card/x11.conf /etc/sddm.conf.d/x11.conf
sudo systemctl restart sddm
```

The `cp` lines restore the backup from Install, step 1. With no backup, delete
`/etc/sddm/Xsetup` and `/etc/sddm.conf.d/x11.conf` instead. CachyOS's own SDDM
settings then apply.

To remove this repo's SDDM config completely, delete
`/etc/sddm.conf.d/noctalia-card.conf` instead of running the `sed` line.
CachyOS's defaults then apply alone, with Breeze and Qt's on-screen keyboard.

Back to Plasma Login Manager:

```bash
sudo pacman -S plasma-login-manager
sudo systemctl disable sddm.service && sudo systemctl enable plasmalogin.service && sudo reboot
```

## Verify

```bash
systemctl status display-manager | head -2                      # sddm.service
grep -h '^Current' /etc/sddm.conf.d/*.conf | tail -1            # Current=noctalia-card
readlink /usr/share/sddm/themes/noctalia-card/theme.conf.user   # /var/lib/sddm-assets/colours.conf
ls -l /var/lib/sddm-assets                                      # background, background.mp4, colours.conf, current.gif, faces, location.json; each file -rw-r--r--
sudo -u sddm cat /var/lib/sddm-assets/colours.conf              # the colours: the greeter's user can read the folder
```

Preview the theme before you log out. The preview opens a full-screen window
on every monitor: the login on the primary one, the side view on the others.
Escape does not close it. Close it with Ctrl+C in its terminal:

```bash
QML_XHR_ALLOW_FILE_READ=1 QT_QPA_PLATFORM=xcb sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/noctalia-card
```

`--theme` also takes the repo's
[`themes/noctalia-card`](themes/noctalia-card/README.md) folder, because the
greeter only reads it. That folder has no `theme.conf.user`, so the preview
shows the fallback colours from `theme.conf`. The pictures still come from
`assetsDir`.

Test mode runs as you, not as `sddm`, so it can't prove the folder's
permissions. The `sudo -u sddm` check does that. In test mode, SDDM reports
the power actions as unavailable, so the power buttons show dimmed, and
`sddm.login()` does nothing. The greeter logs to the journal, not to the
terminal: `journalctl --user -t sddm-greeter-qt6`. For the real test, log out
with `uwsm stop`, log in, and check that KDE Wallet unlocks.
