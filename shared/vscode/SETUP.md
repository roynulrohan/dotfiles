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
- Debian/Ubuntu: Microsoft apt repo — see
  [code.visualstudio.com/docs/setup/linux](https://code.visualstudio.com/docs/setup/linux)

## Extensions

Not stored as a separate file — the **`Brewfile` at the repo root has all 112**
as `vscode "publisher.name"` lines. Two ways to restore:

```bash
# via brew bundle (macOS, installs everything else too)
brew bundle --file=~/dotfiles/Brewfile

# platform-independent: just the extensions
grep '^vscode ' ~/dotfiles/Brewfile | sed 's/vscode "\(.*\)"/\1/' \
  | xargs -n1 code --install-extension
```

The second form is the one to use on Linux.

## Notes

`settings.json` may reference machine-specific paths (interpreter locations, SDK
roots). Skim it after copying and fix anything pointing at `/Users/roynulrohan`
or `/opt/homebrew`.

`alias zshrc="code ~/.zshrc"` in `shell/zshrc` assumes `code` is on PATH. On
macOS that needs *Shell Command: Install 'code' command in PATH* from the command
palette; the Linux packages add it automatically.

## Verify

```bash
code --list-extensions | wc -l
```
