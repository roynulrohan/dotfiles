# Linux packages

The base for the Linux desktop, and the apps that have no package of their own
here. Every package folder names the rest in its `SETUP.md`, under Install.

`pacman -S` unless marked. "AUR" means `paru -S` on CachyOS and Arch. "CachyOS
repo" means the package is in CachyOS's own repository. On plain Arch, it
comes from the AUR. "CachyOS only" has no Arch equivalent.

## Base

| Package | Why |
|---|---|
| `paru` (CachyOS repo) | installs the AUR packages |
| `ttf-jetbrains-mono-nerd` | the font every package assumes |
| `python` `lua` `gitleaks` | [`check.sh`](../check.sh): Python, `luac` and the secret scan |
| `pacman-contrib` | `paccache` deletes old package versions every week and keeps the 3 newest of each. Enable its timer: `sudo systemctl enable --now paccache.timer` |

## Apps without their own package

| Package | Why |
|---|---|
| `dolphin` `gwenview` | file manager on Super+E; image editing and SVG |
| `zen-browser-bin` (CachyOS repo) | browser on Super+B |
| `gvfs-smb` `ffmpegthumbnailer` | SMB shares and video thumbnails in GTK apps |
| `okular` | PDF viewer |
| `libreoffice-fresh` `hunspell-en_ca` | office suite. LibreOffice has no dictionaries of its own and uses the system's, so spell check needs `hunspell-en_ca` |
| `opera-gx` (AUR) | second browser |
| `jellyfin-desktop-git` (AUR) | Jellyfin client; settings in [`linux/jellyfin`](jellyfin/SETUP.md) |
| `chatgpt-desktop-bin` (CachyOS only) | ChatGPT desktop app; also opens `codex://` links |
| `appimagelauncher` (AUR) | adds downloaded AppImages to the app menu. Enable its service: `systemctl --user enable --now appimagelauncherd` |
| `profile-sync-daemon` | keeps browser profiles in RAM for the browsers it knows (Firefox, Chromium, Opera and more; not Zen). Enable its service: `systemctl --user enable --now psd` |
| `cachyos-gaming-meta` `cachyos-gaming-applications` (CachyOS only) | Steam, Lutris and the rest of CachyOS's gaming bundle |

## Default apps

Zen for web pages, Okular for PDFs, VS Code for text and code files,
LibreOffice Calc for CSV, Dolphin for folders. mpv and Equibop set their own
defaults in [`mpv`](mpv/SETUP.md) and [`equibop`](equibop/SETUP.md).

```bash
xdg-settings set default-web-browser zen.desktop
xdg-mime default org.kde.okular.desktop application/pdf
for t in text/plain text/markdown application/json text/x-python text/x-python3 text/x-shellscript application/yaml application/toml; do
    xdg-mime default com.microsoft.VSCode.desktop "$t"; done
xdg-mime default libreoffice-calc.desktop text/csv
xdg-mime default org.kde.dolphin.desktop inode/directory
```

## Verify

```bash
pacman -Q paru ttf-jetbrains-mono-nerd python lua gitleaks pacman-contrib   # a version for each
systemctl is-enabled paccache.timer                                          # enabled
xdg-settings get default-web-browser                                         # zen.desktop
xdg-mime query default application/pdf                                       # org.kde.okular.desktop
xdg-mime query default text/plain                                            # com.microsoft.VSCode.desktop
```
