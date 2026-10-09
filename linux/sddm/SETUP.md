# sddm

The login screen on CachyOS: SDDM with the caelestia "locklike" theme, which
imitates caelestia's own lock screen. caelestia ships no login screen, and the
theme is a third-party project:
[ItsABigIgloo/caelestia-sddm](https://github.com/ItsABigIgloo/caelestia-sddm).
It replaces KDE's Plasma Login Manager, which came with the Plasma install
profile.

| Repo | Destination |
|---|---|
| `x11.conf` | `/etc/sddm.conf.d/x11.conf` (root) |
| `Xsetup` | `/etc/sddm/Xsetup` (root, executable) |
| `sddm-sync` | `~/.local/bin/sddm-sync` |
| `sddm-theme.conf` | `~/.config/caelestia/templates/sddm-theme.conf` |

## Install

1. Copy `sddm-theme.conf` into place first. The package's install script copies
   its own default template there only if none exists.
2. Install the theme. It goes into `/usr/share/sddm/themes/caelestia`, and
   `/etc/sddm.conf.d/caelestia.conf` makes it the active theme:
   ```bash
   paru -S caelestia-sddm-locklike-git
   ```
3. Copy the override and the setup script it runs:
   ```bash
   sudo cp x11.conf /etc/sddm.conf.d/x11.conf
   sudo install -Dm755 Xsetup /etc/sddm/Xsetup
   ```
4. Sync your wallpaper, colours, avatar (`~/.face`), settings and login video
   onto the theme (it asks for sudo):
   ```bash
   sddm-sync
   ```
5. Preview it in a window, without logging out:
   ```bash
   QML_XHR_ALLOW_FILE_READ=1 QT_QPA_PLATFORM=xcb sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/caelestia
   ```
6. Switch login managers, then reboot:
   ```bash
   sudo systemctl disable plasmalogin.service && sudo systemctl enable sddm.service
   ```

## The way back

If the login screen is black or broken: Ctrl+Alt+F3 for a text login, log in,
then:

```bash
sudo systemctl disable sddm.service && sudo systemctl enable plasmalogin.service && sudo reboot
```

## Things to know

- **Why `x11.conf`:** `cachyos-kde-settings` ships
  `/usr/lib/sddm/sddm.conf.d/zz-wayland.conf`, which draws the login screen with
  KWin on Wayland. The theme forces X11 (`QT_QPA_PLATFORM=xcb`), so without the
  override the login screen fails at boot. Files in `/etc/sddm.conf.d` win over
  `/usr/lib/sddm/sddm.conf.d` (`sddm.conf(5)`). The preview works either way,
  because it runs inside Hyprland.
- **Main monitor only:** X11 mirrors every monitor at the login screen. `x11.conf`
  makes SDDM run `Xsetup` first, which keeps the main monitor and turns the
  others off. It finds the main monitor by the model name in its EDID
  (`MAIN_MODEL=VG279QM`, read from `xrandr --verbose`). Output names don't work,
  because the NVIDIA driver names them differently under X11 (the left VG248 is
  X's `DP-2`). Refresh rate doesn't either: on 2026-10-07 X11 gave the VG248 a
  higher one, so the login screen landed on the left monitor. With no matching
  monitor it falls back to the highest refresh rate. `XSETUP_DRY_RUN=1 ./Xsetup`
  prints the `xrandr` command instead of running it. Hyprland sets its own
  layout after login.
- **Session picker:** off in the theme's default template; ours sets
  `sessionPicker=true`. Even when hidden, Up/Down on the login screen change the
  session. It always starts on the first session in the list (Hyprland), not the
  last one used.
- **Settings:** change them in the template, then run the sync.
  `/usr/share/sddm/themes/caelestia/theme.conf` is overwritten on every sync.
  The template's colour lines are placeholders caelestia fills in, and the sync
  sets `os` and `host`.
- **The login screen shows the wallpaper and colours from the last sync.**
  Since the switch to Noctalia (2026-10-08) a Noctalia template writes the
  colour file `sddm-sync` reads (`linux/noctalia`, Colour templates), so run
  `sddm-sync` after changing wallpaper to bring the login screen along. The
  still is Noctalia's wallpaper (`noctalia msg wallpaper-get`), not caelestia's
  stale `wallpaper/current` link. `sddm-sync` runs the theme's `sync.sh` with
  `--posthook`: without it, `sync.sh` runs `caelestia scheme set`, which
  rewrites Noctalia's colour outputs (this colour file, Hyprland, GTK, Qt,
  btop, Spicetify) with caelestia's old palette. `SDDM_SYNC_DRY_RUN=1 sddm-sync`
  prints the commands instead. Noctalia has its own
  greeter (for greetd, not SDDM); not tried yet.
- **Frozen screen after logging out:** happened twice on 2026-10-07. caelestia's
  logout button killed the whole login session, `sddm-helper` included, so SDDM
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

The theme loops `assets/background.mp4` (or `.webm`, `.mkv`, `.mov`, `.m4v`,
`.avi`) over the still, silently: its player has no audio output. The theme's
`sync.sh` deletes every `background.*` other than the wallpaper it copies, so
`sddm-sync` runs it and then installs the video again. Use `sddm-sync` instead of
the plain `sync.sh`, and rerun it after the theme package updates, which wipes
the theme folder.

The video is `~/Pictures/Wallpapers/live/login.mp4` (not in this repo;
`LOGIN_VIDEO` overrides it): a 1080p copy without audio of the main live
wallpaper, since the login screen shows on one 1080p monitor and may decode on
the CPU:

```bash
ffmpeg -i <video> -vf scale=1920:1080 -an -c:v libx264 -crf 22 -pix_fmt yuv420p -movflags +faststart ~/Pictures/Wallpapers/live/login.mp4
```

## Verify

```bash
systemctl status display-manager | head -2                       # sddm.service
grep sessionPicker /usr/share/sddm/themes/caelestia/theme.conf  # sessionPicker=true
```
