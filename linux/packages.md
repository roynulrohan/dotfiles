# CachyOS packages

What this desktop runs on top of a CachyOS install. `pacman -S` unless marked AUR
(`paru -S`). caelestia's own installer handles its components; this list is what
sits around it.

| Package | Why |
|---|---|
| `paru` | AUR helper for the packages marked AUR below; in CachyOS's own repo |
| `caelestia-shell` `caelestia-cli` (AUR) | desktop shell, wallpaper/scheme tooling |
| `hyprland` `xdg-desktop-portal-hyprland` `xdg-desktop-portal-gtk` | compositor |
| `hyprmod` (AUR) | GUI for binds, monitors, workspace and window rules; owns `hyprland-gui.lua` |
| `kitty` | terminal (foot is caelestia's default; kitty for image logos and tabs) |
| `fish` `starship` | shell and prompt |
| `fastfetch` `imagemagick` | greeting and its logo sizing |
| `ttf-jetbrains-mono-nerd` | the font everything assumes |
| `eza` `bat` `fd` `ripgrep` `fzf` `zoxide` `direnv` | modern CLI replacements |
| `lazygit` `github-cli` `micro` | git UI, gh, editor |
| `snapper` `snap-pac` `limine-snapper-sync` `btrfs-assistant` | snapshots, preinstalled by CachyOS; see `snapshots/` |
| `dolphin` `mpv` `gwenview` | file manager (Super+E via `hypr-vars.lua`); video player and default image viewer (see `mpv/`); image editing and SVG |
| `zen-browser-bin` (AUR) `discord` | apps referenced by window rules |
| `jellyfin-desktop-git` (AUR) | Jellyfin client; replaced the repo's `jellyfin-desktop`; kept opaque by a HyprMod rule |
| `chatgpt-desktop-bin` | ChatGPT desktop app; also opens `codex://` links |
| `rtk-bin` (AUR) | rtk, the command proxy behind Claude Code's hook (see `shared/claude`) |
| `gvfs-smb` | SMB shares (the NAS) in GTK apps such as Thunar; Dolphin and Gwenview use KDE's own SMB support |

Reproduce the list from a live machine with `pacman -Qqe`.
