# CachyOS packages

What this desktop runs on top of a CachyOS install. `pacman -S` unless marked AUR
(`paru -S`). caelestia's own installer handles its components; this list is what
sits around it.

| Package | Why |
|---|---|
| `paru` | AUR helper for the packages marked AUR below; in CachyOS's own repo |
| `caelestia-shell` `caelestia-cli` (AUR) | desktop shell, wallpaper/scheme tooling |
| `hyprland` `xdg-desktop-portal-hyprland` `xdg-desktop-portal-gtk` | compositor |
| `sddm` `caelestia-sddm-locklike-git` (AUR) | login screen in caelestia's lock-screen style; see `sddm/` |
| `hyprmod` (AUR) | GUI for binds, monitors, workspace and window rules; owns `hyprland-gui.lua` |
| `kitty` | terminal (foot is caelestia's default; kitty for image logos and tabs) |
| `fish` `starship` | shell and prompt |
| `fastfetch` `imagemagick` | greeting and its logo sizing |
| `ttf-jetbrains-mono-nerd` | the font everything assumes |
| `eza` `bat` `fd` `ripgrep` `fzf` `zoxide` `direnv` | modern CLI replacements |
| `lazygit` `github-cli` `micro` | git UI, gh, editor |
| `snapper` `snap-pac` `limine-snapper-sync` `btrfs-assistant` | snapshots, preinstalled by CachyOS; see `snapshots/` |
| `dolphin` `mpv` `gwenview` | file manager (Super+E via `hypr-vars.lua`); video player and default image viewer (see `mpv/`); image editing and SVG |
| `zen-browser-bin` (AUR) `opera-gx` (AUR) `discord` | apps referenced by window rules |
| `equibop-bin` (AUR) | Equibop, the default Discord app: caelestia's `discord` component installs it and themes it with its colours. The official `discord` stays installed alongside |
| `linux-wallpaperengine-git` (AUR) | live wallpapers from Wallpaper Engine (installed through Steam/Proton); see `wallpaper/` |
| `jellyfin-desktop-git` (AUR) | Jellyfin client; replaced the repo's `jellyfin-desktop`; kept opaque by a HyprMod rule |
| `visual-studio-code-bin` (AUR) | VS Code, Microsoft's build; replaces the `code` (Code - OSS) that caelestia installs. See `shared/vscode` |
| `chatgpt-desktop-bin` | ChatGPT desktop app; also opens `codex://` links |
| `rtk-bin` (AUR) | rtk, the command proxy behind Claude Code's hook (see `shared/claude`) |
| `pipewire` `wireplumber` | audio, preinstalled by CachyOS; the headset EQ runs in PipeWire's `filter-chain.service` (see `pipewire/`). Not EasyEffects |
| `spotify` (AUR) `spicetify-cli` | music; caelestia's `spotify` component themes it through Spicetify, which needs applying once (see `caelestia/`) |
| `ksshaskpass` | unlocks the SSH key at login from KDE Wallet (see `ssh/`) |
| `hyprsunset` | night light, always on (see `hyprsunset/`) |
| `gvfs-smb` | SMB shares (the NAS) in GTK apps such as Thunar; Dolphin and Gwenview use KDE's own SMB support |
| `cachyos-gaming-meta` `cachyos-gaming-applications` | CachyOS's gaming bundle (Steam, Lutris and the rest), installed as a set rather than listed one by one |

Reproduce the list from a live machine with `pacman -Qqe`.

## Default apps

Zen for web pages and PDFs, Dolphin for folders, Equibop for `discord://`
links. mpv's image and video defaults are set in `mpv/SETUP.md`.

```bash
xdg-settings set default-web-browser zen.desktop
xdg-mime default zen.desktop application/pdf
xdg-mime default org.kde.dolphin.desktop inode/directory
xdg-mime default equibop.desktop x-scheme-handler/discord
```
