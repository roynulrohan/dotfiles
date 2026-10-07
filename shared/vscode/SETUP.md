# vscode

VS Code user settings and keybindings. See `../cursor/` for the Cursor
equivalent — they're separate installs with separate config directories.

## Files

| Repo | macOS | Linux |
|---|---|---|
| `settings.json` | `~/Library/Application Support/Code/User/settings.json` | `~/.config/Code/User/settings.json` |
| `keybindings.json` | `~/Library/Application Support/Code/User/keybindings.json` | `~/.config/Code/User/keybindings.json` |

**Different path per OS**, same as Ghostty. Copy both.

## WSL

Do not copy these into the WSL filesystem — it has no effect.

With the Remote-WSL extension, **VS Code runs on Windows**. The Linux side only
holds `~/.vscode-server/`, which is downloaded server state, not user config.
Your settings live on the Windows host:

```
/mnt/c/Users/<WindowsUser>/AppData/Roaming/Code/User/settings.json
/mnt/c/Users/<WindowsUser>/AppData/Roaming/Code/User/keybindings.json
```

Reachable from WSL through `/mnt/c`, but treat it as a decision rather than a
default — it modifies the user's Windows install. **Copy rather than symlink**:
a symlink created in WSL pointing back into the Linux filesystem is not reliably
followed by a Windows process, and the reverse direction has the same problem.

Extensions split in two under Remote-WSL. UI extensions (themes, keymaps)
install on the Windows host; workspace extensions (language servers, linters,
formatters) install into the WSL distro. The `code --install-extension` loop
below installs into whichever context the `code` command resolves to, so run it
from inside a WSL shell to populate the Linux side, and from PowerShell for the
Windows side. Most of the list wants both.

## Install

- macOS: `brew install --cask visual-studio-code`
- CachyOS: `paru -S visual-studio-code-bin` (AUR, Microsoft's build). It replaces
  Arch's `code` (Code - OSS), which caelestia's installer adds: Code - OSS uses the
  Open VSX store (no Microsoft-only extensions), has no Microsoft Settings Sync,
  and reads `~/.config/Code - OSS/` instead of `~/.config/Code/`.
- Debian/Ubuntu: Microsoft apt repo — see
  [code.visualstudio.com/docs/setup/linux](https://code.visualstudio.com/docs/setup/linux)

## Extensions

Thirteen, for TypeScript full-stack work; pruned on 2026-10-07 from over a
hundred collected on Windows and the Mac. On the Mac they're the `vscode` lines
in `mac/Brewfile`.

| Extension | Why |
|---|---|
| `esbenp.prettier-vscode`, `dbaeumer.vscode-eslint`, `oxc.oxc-vscode` | format and lint |
| `bradlc.vscode-tailwindcss` | Tailwind IntelliSense |
| `usernamehw.errorlens`, `yoavbls.pretty-ts-errors` | errors inline, readable TypeScript errors |
| `eamodio.gitlens` | git blame and history (VS Code has its own commit graph) |
| `github.vscode-pull-request-github`, `github.vscode-github-actions` | PRs, Actions |
| `redhat.vscode-yaml` | YAML |
| `akamud.vscode-theme-onedark`, `pkief.material-icon-theme` | Atom One Dark, icons |
| `leonardssh.vscord` | Discord presence (iCrawl's is archived) |

```bash
for e in esbenp.prettier-vscode dbaeumer.vscode-eslint oxc.oxc-vscode bradlc.vscode-tailwindcss \
    usernamehw.errorlens yoavbls.pretty-ts-errors eamodio.gitlens github.vscode-pull-request-github \
    github.vscode-github-actions redhat.vscode-yaml akamud.vscode-theme-onedark \
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

- Ctrl+S formats with Prettier, applies ESLint fixes and removes unused imports
  (`editor.codeActionsOnSave`, `explicit`); auto save after a delay doesn't, so
  nothing reshuffles while typing.
- CachyOS: caelestia's `vscode` component installs `~/.config/code-flags.conf`
  (read by `visual-studio-code-bin`): native Wayland, GTK 4, Wayland IME, and
  `--password-store=gnome-libsecret`, which KDE Wallet answers through its
  Secret Service API (`org.freedesktop.secrets`), so GitHub logins stay in the
  wallet. caelestia also installs its own VS Code settings and keybindings
  (copies in `~/.local/state/caelestia/dots/vscode/`); these files replace them.

## Verify

```bash
code --list-extensions | wc -l
```
