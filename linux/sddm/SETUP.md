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
| `sddm-theme.conf` | `~/.config/caelestia/templates/sddm-theme.conf` |

## Install

1. Copy `sddm-theme.conf` into place first. The package's install script copies
   its own default template there only if none exists.
2. Install the theme. It goes into `/usr/share/sddm/themes/caelestia`, and
   `/etc/sddm.conf.d/caelestia.conf` makes it the active theme:
   ```bash
   paru -S caelestia-sddm-locklike-git
   ```
3. Copy the override: `sudo cp x11.conf /etc/sddm.conf.d/x11.conf`
4. Sync your wallpaper, colours, avatar (`~/.face`) and settings onto the theme:
   ```bash
   sudo /usr/share/sddm/themes/caelestia/scripts/sync.sh
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
- **Session picker:** off in the theme's default template; ours sets
  `sessionPicker=true`. Even when hidden, Up/Down on the login screen change the
  session. It always starts on the first session in the list (Hyprland), not the
  last one used.
- **Settings:** change them in the template, then run the sync.
  `/usr/share/sddm/themes/caelestia/theme.conf` is overwritten on every sync.
  The template's colour lines are placeholders caelestia fills in, and the sync
  sets `os` and `host`.
- **The scheme is dynamic,** so the login screen shows the wallpaper and colours
  from the last sync. Run the sync again after changing wallpaper. Automatic
  syncing is possible (a caelestia `postHook` plus a passwordless sudo rule for
  `sync.sh`) but isn't set up.

## Verify

```bash
systemctl status display-manager | head -2                       # sddm.service
grep sessionPicker /usr/share/sddm/themes/caelestia/theme.conf  # sessionPicker=true
```
