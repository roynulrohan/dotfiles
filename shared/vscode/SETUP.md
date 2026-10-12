# vscode

VS Code user settings and keybindings. See `../cursor/` for the Cursor
equivalent — they're separate installs with separate config directories.

## Files

| Repo | macOS | Linux |
|---|---|---|
| `settings.json` | `~/Library/Application Support/Code/User/settings.json` | `~/.config/Code/User/settings.json` |
| `keybindings.json` | `~/Library/Application Support/Code/User/keybindings.json` | `~/.config/Code/User/keybindings.json` |

**Different path per OS**, same as Ghostty. Copy both.

## Install

- macOS: `brew install --cask visual-studio-code`
- CachyOS: `paru -S visual-studio-code-bin` (AUR, Microsoft's build). It replaced
  Arch's `code` (Code - OSS), which caelestia's installer added: Code - OSS uses the
  Open VSX store (no Microsoft-only extensions), has no Microsoft Settings Sync,
  and reads `~/.config/Code - OSS/` instead of `~/.config/Code/`.

## Extensions

Fifteen, for TypeScript full-stack work; pruned on 2026-10-07 from over a
hundred collected on Windows and the Mac. On the Mac they're the `vscode` lines
in `mac/Brewfile`.

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

```bash
for e in esbenp.prettier-vscode dbaeumer.vscode-eslint oxc.oxc-vscode biomejs.biome editorconfig.editorconfig \
    bradlc.vscode-tailwindcss \
    usernamehw.errorlens yoavbls.pretty-ts-errors eamodio.gitlens github.vscode-pull-request-github \
    github.vscode-github-actions redhat.vscode-yaml zhuangtongfa.material-theme \
    pkief.material-icon-theme leonardssh.vscord; do code --install-extension "$e"; done
```

Not used any more: Claude Code (the CLI and Orca instead), Container Tools,
Remote-SSH/WSL, Live Server, and the Java, C/C++, PHP, Python, Flutter and
GraphQL stacks. Built into VS Code now: auto close/rename tag, auto import,
removing unused imports (`source.removeUnusedImports`, also on Alt+Shift+U).

## Settings Sync

Settings Sync is on (signed in with GitHub/Microsoft) and carries settings,
keybindings and the extension list between Windows, the Mac and CachyOS. This
repo is the reference copy: edit here, copy into place, and Sync spreads it.
`settings.json` holds per-OS keys (`terminal.integrated.defaultProfile.linux`,
`.osx`, `.windows`) because every machine gets the same file. Keybindings sync
per platform. On a new machine Sync pulls the cloud copy on first sign-in, so
copy these files in after signing in.

## Notes

- Theme One Dark Pro Night Flat with `oneDarkPro.vivid`, JetBrains Mono at weight
  500. VS Code is left see-through at the default window transparency
  (`windowOpacity` in `linux/hypr/hypr-vars.lua`) on purpose.
- Discord presence (`vscord`) shows the project and file only: no line numbers,
  error counts or "View Repository" button, and it disconnects after 5 minutes
  idle. On CachyOS it reaches Discord through Equibop's built-in arRPC bridge
  (`arRPC: true` in `~/.config/equibop/settings.json`, socket
  `$XDG_RUNTIME_DIR/discord-ipc-0`). `vscord.app.privacyMode.enable` hides the
  project and file too; `vscord.ignore.workspaces` hides chosen projects.
- The `cmd+` entries in `keybindings.json` remove macOS defaults. Linux has no
  such defaults (there `cmd` means Super), so they do nothing on CachyOS.
- Ctrl+S formats with Prettier, applies ESLint fixes and removes unused imports
  (`editor.codeActionsOnSave`, `explicit`); auto save after a delay doesn't, so
  nothing reshuffles while typing.
- CachyOS: `~/.config/code-flags.conf` (read by `visual-studio-code-bin`)
  turns on native Wayland, GTK 4, Wayland IME, and
  `--password-store=gnome-libsecret`, which KDE Wallet answers through its
  Secret Service API (`org.freedesktop.secrets`), so GitHub logins stay in the
  wallet. caelestia's `vscode` component wrote it; it isn't in this repo, so a
  new machine needs it written by hand. caelestia also installed its own VS
  Code settings and keybindings; these files replaced them.

## Verify

```bash
code --list-extensions | wc -l
```
