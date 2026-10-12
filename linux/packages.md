# CachyOS packages

What this desktop runs on top of a CachyOS install. `pacman -S` unless marked AUR
(`paru -S`). Until 2026-10-09 caelestia's installer set up part of this
desktop (`caelestia/`); what it brought that this setup still uses is listed
here too.

| Package | Why |
|---|---|
| `paru` | AUR helper for the packages marked AUR below; in CachyOS's own repo |
| `noctalia` | desktop shell since 2026-10-08: bar, launcher, lock, idle, notifications; see `noctalia/` |
| `hyprland` `xdg-desktop-portal-hyprland` `xdg-desktop-portal-gtk` | compositor |
| `sddm` `qt6-5compat` `qt6-multimedia` `ttf-material-symbols-variable` | login screen with our `noctalia-card` theme; see `sddm/` |
| `hyprmod` (AUR) | GUI for binds, monitors, workspace and window rules; owns `hyprland-gui.lua` |
| `kitty` | terminal (replaced foot, caelestia's default, for image logos and tabs) |
| `fish` `starship` | shell and prompt |
| `fastfetch` `imagemagick` | greeting and its logo sizing |
| `btop` | system monitor, coloured by Noctalia; see `btop/` |
| `neo-matrix` (AUR) | matrix rain; the `cmatrix` alias runs it on kitty's see-through background (cmatrix paints black) |
| `ttf-jetbrains-mono-nerd` | the font everything assumes |
| `eza` `bat` `fd` `ripgrep` `fzf` `zoxide` `direnv` | modern CLI replacements |
| `lazygit` `github-cli` `micro` | git UI, gh, editor |
| `snapper` `snap-pac` `limine-snapper-sync` `btrfs-assistant` | snapshots, preinstalled by CachyOS; see `snapshots/` |
| `dolphin` `mpv` `gwenview` | file manager (Super+E via `hypr-vars.lua`); video player and default image viewer (see `mpv/`); image editing and SVG |
| `mpv-uosc` (AUR) `mpv-thumbfast-git` (AUR) | mpv's on-screen controls and timeline thumbnails for videos; see `mpv/` |
| `zen-browser-bin` (AUR) `opera-gx` (AUR) `discord` | apps referenced by window rules |
| `equibop-bin` (AUR) | Equibop, the default Discord app; a Noctalia template writes its theme (see `noctalia/`). The official `discord` stays installed alongside |
| `linux-wallpaperengine-git` (AUR) | live wallpapers from Wallpaper Engine (installed through Steam/Proton); see `wallpaper/` |
| `jellyfin-desktop-git` (AUR) | Jellyfin client; replaced the repo's `jellyfin-desktop`; kept opaque by a HyprMod rule |
| `todoist-appimage` (AUR) | Todoist, started in the todo pop-up workspace (Super+R) |
| `visual-studio-code-bin` (AUR) | VS Code, Microsoft's build; replaced the `code` (Code - OSS) that caelestia's installer added. See `shared/vscode` |
| `chatgpt-desktop-bin` | ChatGPT desktop app; also opens `codex://` links |
| `rtk-bin` (AUR) | rtk, the command proxy behind Claude Code's hook (see `shared/claude`) |
| `pipewire` `wireplumber` | audio, preinstalled by CachyOS; the headset EQ runs in PipeWire's `filter-chain.service` (see `pipewire/`). Not EasyEffects |
| `spotify` (AUR) `spicetify-cli` (AUR) | music; a Noctalia template themes it through Spicetify, which needs applying once (see `hypr/`, Install) |
| `qtengine` (AUR) `darkly-bin` (AUR) `papirus-icon-theme` | Qt apps' theme engine, style and icons; `qtengine` reads the colours a Noctalia template writes (see `noctalia/`) |
| `polkit-gnome` `trash-cli` | started by the Hyprland autostart (`hypr/hyprland/execs.lua`): the polkit agent, and emptying trash older than 30 days |
| `ksshaskpass` | unlocks the SSH key at login from KDE Wallet (see `ssh/`) |
| `hyprsunset` | night light, always on (see `hyprsunset/`) |
| `thunar` | second file manager; its look comes from the `gtk.css` and `thunar.css` Noctalia templates (see `noctalia/`) |
| `gvfs-smb` | SMB shares (the NAS) in GTK apps such as Thunar; Dolphin and Gwenview use KDE's own SMB support |
| `tumbler` `ffmpegthumbnailer` | image and video thumbnails in GTK file managers such as Thunar |
| `appimagelauncher` (AUR) | adds downloaded AppImages to the app menu; enable its user service: `systemctl --user enable --now appimagelauncherd` |
| `profile-sync-daemon` | keeps the Firefox profile in RAM (it has no Zen definition); enable its user service: `systemctl --user enable --now psd` |
| `cachyos-gaming-meta` `cachyos-gaming-applications` | CachyOS's gaming bundle (Steam, Lutris and the rest), installed as a set rather than listed one by one |

Reproduce the list from a live machine with `pacman -Qqe`. Removed with
caelestia on 2026-10-09, so no longer installed: `quickshell-git`, `fuzzel`,
`swappy`, `slurp`, `gpu-screen-recorder`, `libcava`, `brightnessctl`,
`inotify-tools`, `ttf-rubik-vf`, `python-materialyoucolor`.

## Default apps

Zen for web pages and PDFs, Dolphin for folders, Equibop for `discord://`
links. mpv's image and video defaults are set in `mpv/SETUP.md`.

```bash
xdg-settings set default-web-browser zen.desktop
xdg-mime default zen.desktop application/pdf
xdg-mime default org.kde.dolphin.desktop inode/directory
xdg-mime default equibop.desktop x-scheme-handler/discord
```
