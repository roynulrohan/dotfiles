# noctalia-card

Our SDDM login theme, installed as `/usr/share/sddm/themes/noctalia-card`. It
is a fork of the "locklike" theme from
[Caelestia SDDM](https://github.com/ItsABigIgloo/caelestia-sddm) by AkhiLeith
(ItsABigIgloo), taken at commit `dd69abb` (2026-10-01), the version the AUR
package `caelestia-sddm-locklike-git` r188 installed. Setup and sync are in
`../../SETUP.md`.

## Licence

The upstream theme is GPL-3.0, so this fork is too: `LICENSE` is upstream's
copy. Google Sans Flex in `assets/google-sans-flex` is under the SIL Open Font
License 1.1, with its own `LICENSE`.

## Changes from upstream

- Renamed in `metadata.desktop`; `theme.conf` has `sessionPicker=true`.
- Left out: caelestia's `scripts/sync.sh` (root sync from caelestia's state),
  `theme.conf.template` (caelestia's colour template), the sample
  `background.png` and `avatar.jpg`, the Qt Design Studio project file and an
  editor backup (`MaterialIcon.qml.save`).

## Preview

Without sudo, in a window. `<dir>` can be this folder: the greeter only reads
it. The repo has no wallpaper or avatar, so those show the fallback colour
there.

```bash
QML_XHR_ALLOW_FILE_READ=1 QT_QPA_PLATFORM=xcb sddm-greeter-qt6 --test-mode --theme <dir>
```

Test mode runs as you, not as `sddm`, and `sddm.login()` does nothing. The
greeter logs to the journal (`journalctl --user -t sddm-greeter-qt6`), not to
the terminal.
