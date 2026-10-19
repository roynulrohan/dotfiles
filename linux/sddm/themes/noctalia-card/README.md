# noctalia-card

My SDDM login theme, installed as `/usr/share/sddm/themes/noctalia-card`. It
is a fork of the "locklike" theme from
[Caelestia SDDM](https://github.com/ItsABigIgloo/caelestia-sddm) by AkhiLeith
(ItsABigIgloo), taken at commit `dd69abb` (2026-10-01), the version the AUR
package `caelestia-sddm-locklike-git` r188 installed. Setup and sync are in
`../../SETUP.md`.

## Licence

The upstream theme is GPL-3.0, so this fork is too: `LICENSE` is upstream's
copy. Google Sans Flex in `assets/google-sans-flex`, and "GSF Lock Clock", a
renamed instance of it, are under the SIL Open Font License 1.1, with their
own `LICENSE`.

## Changes from upstream

- Renamed in `metadata.desktop`. `theme.conf` holds only the keys the theme
  reads (12-hour clock `ap=true`, blur and tint amounts, video on/off,
  `assetsDir`, fallback colours).
- Page 1 (`components/Greeting.qml`): "Good morning/afternoon/evening/night"
  and the user name on a second line, both 86 px Google Sans Flex (rounded,
  `ROND` 100), with the date and time and a "press any key or click" hint, on
  one frosted card tinted with `surface`. It greets the selected user. A click
  opens page 2 too.
- Page 2 (`components/LoginScreen.qml`) is rebuilt after my Noctalia lock screen: a 1500x840
  card laid out at 1920x1080 and scaled to the screen.
  - Left: `WeatherCard.qml` (Open-Meteo, current weather and 3 days, for
    `location.json`; retries every 3 s for its first 90 s, then every 30 s, and says it is waiting until a fetch works) and
    `CalendarCard.qml` (this month, today marked).
  - Centre: `ClockGroup.qml` (the lock screen's main clock and date, 1:1:
    same boxes, font, colours and chip), `UserAvatar.qml` (the face cut to
    Material's ClamShell shape, arrows only with more than one user), the
    name, and `PasswordField.qml` (a real text field; Enter logs in, Escape
    goes back, Up/Down change the session, Left/Right change the user while
    empty). A line under it says "Wrong password" or "Caps Lock is on".
  - Right: the lock screen's GIF, `SessionCard.qml` (selects the first
    session with "uwsm" in its name, else SDDM's last one; Caps Lock and
    keyboard layout chips), and `PowerRow.qml` (suspend, reboot, shut down;
    dimmed when SDDM says it can't) directly below it.
- One window per screen (SDDM's way): `Main.qml` loads the login on X's
  primary screen and `SideScreen.qml` on the others: my lock screen's side
  monitors, 1:1. `ClockGroup.qml` uses the lock's boxes from
  `linux/noctalia/lock` and its font, "GSF Lock Clock"; `LockText.qml` sizes
  and places text the way Noctalia 5.2.1 does. The blurred still uses the
  lock's blur (three Gaussian rounds, sigma 20 px). No video, no input.
  Side windows refuse keyboard focus, and the login window takes it back if
  it loses it to one, so keys always reach the password field.
- User files come from `assetsDir` (default `/var/lib/sddm-assets`), not the
  theme folder: `background` (still), `background.<video>`, `current.gif`,
  `location.json`, `faces/<user>.face.icon`. The face falls back to the one
  SDDM finds, then to the user's initial. The colours come from
  `theme.conf.user`, which the install links to `colours.conf` in that
  folder; Noctalia writes it. caelestia's `sync.sh` and its root-owned copies
  are gone.
- Left out: caelestia's `scripts/sync.sh` and `theme.conf.template`, the
  sample `background.png` and `avatar.jpg`, the Qt Design Studio project file,
  an editor backup, and upstream's page 2 parts (fetch card, quote, dino,
  `PasswordInput.qml`, `SessionPicker.qml`, `SystemButtons.qml` and others).

## Requirements

`qt6-declarative`, `qt6-5compat`, `qt6-multimedia` (video) and
`ttf-material-symbols-variable` (icons, a system font). Google Sans Flex ships
in `assets/`. SDDM must not load Qt's on-screen keyboard: CachyOS sets
`InputMethod=qtvirtualkeyboard`, and our SDDM config (`../../noctalia-card.conf`)
clears it.

## Preview

Without sudo, in a window. `<dir>` can be this folder: the greeter only reads
it. The repo has no wallpaper or avatar, so those show the fallback colour
there, and the fallback colours from `theme.conf`. To see the synced files,
point a copy's `assetsDir` at a folder that has them and link its
`theme.conf.user` to that folder's `colours.conf`.

```bash
QML_XHR_ALLOW_FILE_READ=1 QT_QPA_PLATFORM=xcb sddm-greeter-qt6 --test-mode --theme <dir>
```

The greeter opens a full-screen window on every monitor: the login on the
primary one, the clock on the others. Escape doesn't close them; close the
greeter with Ctrl+C in its terminal.

Test mode runs as you, not as `sddm`, and `sddm.login()` does nothing. The
greeter logs to the journal (`journalctl --user -t sddm-greeter-qt6`), not to
the terminal.
