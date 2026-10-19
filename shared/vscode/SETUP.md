# VS Code

VS Code user settings and keybindings, set up for TypeScript full-stack work.
Cursor is a separate install with its own config folder. See
[`shared/cursor`](../cursor/SETUP.md).

## Files

| Repo | macOS | Linux |
|---|---|---|
| [`settings.json`](settings.json) | `~/Library/Application Support/Code/User/settings.json` | `~/.config/Code/User/settings.json` |
| [`keybindings.json`](keybindings.json) | `~/Library/Application Support/Code/User/keybindings.json` | `~/.config/Code/User/keybindings.json` |
| [`code-flags.conf`](code-flags.conf) | | `~/.config/code-flags.conf` (Linux only; see Notes) |

## Install

- CachyOS/Arch: `paru -S visual-studio-code-bin` (AUR), Microsoft's build. Not
  Arch's `code` (Code - OSS): it uses the Open VSX store (no Microsoft-only
  extensions), has no Microsoft Settings Sync, and reads
  `~/.config/Code - OSS/` instead of `~/.config/Code/`.
- macOS: `brew install --cask visual-studio-code`.
- The font: `ttf-jetbrains-mono-nerd` on Arch, the
  `font-jetbrains-mono-nerd-font` cask on macOS.

Extensions: on macOS, the `vscode` lines in [`mac/Brewfile`](../../mac/Brewfile)
install them. Anywhere:

```bash
for e in esbenp.prettier-vscode dbaeumer.vscode-eslint oxc.oxc-vscode biomejs.biome editorconfig.editorconfig \
    bradlc.vscode-tailwindcss \
    usernamehw.errorlens yoavbls.pretty-ts-errors eamodio.gitlens github.vscode-pull-request-github \
    github.vscode-github-actions redhat.vscode-yaml zhuangtongfa.material-theme \
    pkief.material-icon-theme leonardssh.vscord; do code --install-extension "$e"; done
```

With Settings Sync: sign in first, then copy these files in. Sync pulls the
cloud copy on first sign-in and would overwrite them.

## Notes

### Extensions

| Extension | Why |
|---|---|
| `esbenp.prettier-vscode`, `dbaeumer.vscode-eslint`, `oxc.oxc-vscode`, `biomejs.biome` | format and lint (projects use Prettier or Biome) |
| `editorconfig.editorconfig` | per-project `.editorconfig` |
| `bradlc.vscode-tailwindcss` | Tailwind IntelliSense |
| `usernamehw.errorlens`, `yoavbls.pretty-ts-errors` | errors inline, readable TypeScript errors |
| `eamodio.gitlens` | git blame and history (VS Code has its own commit graph) |
| `github.vscode-pull-request-github`, `github.vscode-github-actions` | PRs, Actions |
| `redhat.vscode-yaml` | YAML |
| `zhuangtongfa.material-theme`, `pkief.material-icon-theme` | One Dark Pro (Night Flat, vivid), icons |
| `leonardssh.vscord` | Discord presence (iCrawl's is archived) |

VS Code has these built in, so they need no extension: auto close and rename
tag, auto import, and removing unused imports (`source.removeUnusedImports`,
also on Alt+Shift+U).

### Settings Sync

Settings Sync carries settings, keybindings and the extension list between
machines. This repo is the reference copy: edit here, copy into place, and Sync
spreads it. Every machine gets the same `settings.json`, so it holds per-OS
keys (`terminal.integrated.defaultProfile.linux`, `.osx`, `.windows`).
Keybindings sync per platform.

### Other notes

- Theme One Dark Pro Night Flat with `oneDarkPro.vivid`, JetBrains Mono at
  weight 500.
- Discord presence (`vscord`) shows the project and file only. On Linux, it
  reaches Discord through Equibop's built-in arRPC bridge, so Equibop needs
  `arRPC: true` in `~/.config/equibop/settings.json`.
- The `cmd+` entries in `keybindings.json` remove macOS defaults. Linux has no
  such defaults (there `cmd` means Super), so they do nothing on Linux.
- Ctrl+S formats with Prettier, applies ESLint fixes and removes unused imports
  (`editor.codeActionsOnSave`, `explicit`). Auto save after a delay doesn't, so
  nothing reshuffles while you type.
- `code-flags.conf` holds the launch flags that `visual-studio-code-bin` reads
  on Linux: native Wayland with GTK 4 and the Wayland input method, GPU
  acceleration even where Chromium's blocklist would turn it off, touchpad
  swipe for back and forward, and colours kept in sRGB (Wayland colour
  management off). Copy it after you sign in to Settings Sync.
- `--password-store=gnome-libsecret` in `code-flags.conf` sends logins to the
  Secret Service API (`org.freedesktop.secrets`). KDE Wallet answers it, so
  GitHub logins stay in the wallet.

## Verify

```bash
code --list-extensions 2>/dev/null | wc -l   # 15
./status.sh | grep Code/User                 # settings.json and keybindings.json: ok
```
