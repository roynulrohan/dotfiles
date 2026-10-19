# noctalia-card

My SDDM login theme, installed as `/usr/share/sddm/themes/noctalia-card`. It
is a fork of the "locklike" theme from
[Caelestia SDDM](https://github.com/ItsABigIgloo/caelestia-sddm) by AkhiLeith
(ItsABigIgloo), taken at commit `dd69abb` (2026-10-01), the version the AUR
package `caelestia-sddm-locklike-git` r188 installed. Install, sync, preview
and checks are in [`linux/sddm`](../../SETUP.md).

## Licence

The upstream theme is GPL-3.0, so this fork is too: `LICENSE` is upstream's
copy. Google Sans Flex in `assets/google-sans-flex`, and "GSF Lock Clock", a
renamed instance of it, are under the SIL Open Font License 1.1, with their
own `LICENSE`.

## Changes from upstream

- Renamed in `metadata.desktop`. `theme.conf` holds only the keys the theme
  reads (12-hour clock `ap=true`, blur and tint amounts, video on or off,
  `assetsDir`, fallback colours).
- Page 1 (`components/Greeting.qml`): "Good morning", "Good afternoon", "Good
  evening" or "Good night" and the user name on a second line, in rounded
  Google Sans Flex. Below them are the date, the time and a "press any key or
  click" hint, on one frosted card tinted with `surface`. It greets the
  selected user. A click also opens page 2.
- Page 2 (`components/LoginScreen.qml`) is rebuilt after my Noctalia lock
  screen: a 1500x840 card laid out at 1920x1080 and scaled to the screen.
  - Left: `WeatherCard.qml` (Open-Meteo, current weather and 3 days, for
    `location.json`) and `CalendarCard.qml` (this month, today marked).
  - Centre: `ClockGroup.qml` (the lock screen's main clock and date, with the
    same boxes, font, colours and chip), `UserAvatar.qml` (the face cut to
    Material's ClamShell shape, with arrows only when there is more than one
    user), the name, and `PasswordField.qml`. In the password field, Enter
    logs in and Escape goes back. Up and Down change the session. Left and
    Right change the user while the field is empty. A line under it says
    "Wrong password" or "Caps Lock is on".
  - Right: the lock screen's GIF, `SessionCard.qml` and `PowerRow.qml`
    directly below it. `SessionCard.qml` selects the first session with
    "uwsm" in its name, else SDDM's last one, and shows Caps Lock and
    keyboard layout chips. `PowerRow.qml` has suspend, reboot and shut down,
    dimmed when SDDM says it can't do them.
- One window per screen, as SDDM does it: `Main.qml` loads the login on X's
  primary screen and `SideScreen.qml` on the others. `SideScreen.qml` copies
  my lock screen's side monitors: the clock group over the blurred still,
  with the lock's blur, and no video or input. `ClockGroup.qml` uses the
  lock's boxes from `linux/noctalia/lock` and its font, "GSF Lock Clock".
  `LockText.qml` sizes and places text the way Noctalia does. Side windows
  refuse keyboard focus, and the login window takes focus back if it loses it
  to one, so keys always reach the password field.
- User files come from `assetsDir` (default `/var/lib/sddm-assets`), not the
  theme folder: `background` (still), `background.<video>`, `current.gif`,
  `location.json`, `faces/<user>.face.icon`. The face falls back to the one
  SDDM finds, then to the user's initial. The colours come from
  `theme.conf.user`, which the install links to `colours.conf` in that
  folder. Noctalia writes that file.
- Left out: caelestia's `scripts/sync.sh` with its root-owned copies, and
  `theme.conf.template`. Also left out: the sample `background.png` and
  `avatar.jpg`, the Qt Design Studio project file, an editor backup, and
  upstream's page 2 parts (fetch card, quote, dino, `PasswordInput.qml`,
  `SessionPicker.qml`, `SystemButtons.qml` and others).

## Requirements

`qt6-declarative`, `qt6-5compat`, `qt6-multimedia` (video) and
`ttf-material-symbols-variable` (icons, a system font). Google Sans Flex ships
in `assets/`. SDDM must not load Qt's on-screen keyboard. CachyOS sets
`InputMethod=qtvirtualkeyboard`, and
[`noctalia-card.conf`](../../noctalia-card.conf) clears it.
