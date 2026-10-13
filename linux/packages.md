# Linux packages

The base for the Linux desktop, and the apps that have no package of their own
here. Every package folder names the rest in its `SETUP.md`, under Install.

`pacman -S` unless marked. "AUR" means `paru -S` on CachyOS and Arch. "CachyOS
repo" means the package is in CachyOS's own repository; on plain Arch it comes
from the AUR. "CachyOS only" has no Arch equivalent.

## Base

| Package | Why |
|---|---|
| `paru` (CachyOS repo) | installs the AUR packages |
| `ttf-jetbrains-mono-nerd` | the font every package assumes |
| `python` `lua` `gitleaks` | [`check.sh`](../check.sh): Python, `luac` and the secret scan |

## Apps without their own package

| Package | Why |
|---|---|
| `dolphin` `gwenview` | file manager on Super+E; image editing and SVG |
| `zen-browser-bin` (CachyOS repo) | browser on Super+B |
| `thunar` `gvfs-smb` `tumbler` `ffmpegthumbnailer` | second file manager, with SMB shares and thumbnails in GTK apps |
| `opera-gx` (AUR) | second browser |
| `jellyfin-desktop-git` (AUR) | Jellyfin client |
| `chatgpt-desktop-bin` (CachyOS only) | ChatGPT desktop app; also opens `codex://` links |
| `appimagelauncher` (AUR) | adds downloaded AppImages to the app menu. Enable its service: `systemctl --user enable --now appimagelauncherd` |
| `profile-sync-daemon` | keeps the Firefox profile in RAM. Enable its service: `systemctl --user enable --now psd` |
| `cachyos-gaming-meta` `cachyos-gaming-applications` (CachyOS only) | Steam, Lutris and the rest of CachyOS's gaming bundle |

## Default apps

Zen for web pages and PDFs, Dolphin for folders. mpv and Equibop set their own
defaults in [`mpv`](mpv/SETUP.md) and [`equibop`](equibop/SETUP.md).

```bash
xdg-settings set default-web-browser zen.desktop
xdg-mime default zen.desktop application/pdf
xdg-mime default org.kde.dolphin.desktop inode/directory
```

## Verify

```bash
pacman -Q paru ttf-jetbrains-mono-nerd python lua gitleaks   # a version for each
xdg-settings get default-web-browser                          # zen.desktop
```
