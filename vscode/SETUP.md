# vscode

VS Code user settings and keybindings. See `../cursor/` for the Cursor
equivalent — they're separate installs with separate config directories.

## Files

| Repo | macOS | Linux |
|---|---|---|
| `settings.json` | `~/Library/Application Support/Code/User/settings.json` | `~/.config/Code/User/settings.json` |
| `keybindings.json` | `~/Library/Application Support/Code/User/keybindings.json` | `~/.config/Code/User/keybindings.json` |

**Different path per OS**, same as Ghostty. Symlink both.

On Windows/WSL it's `%APPDATA%\Code\User\`.

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
roots). Skim it after linking and fix anything pointing at `/Users/roynulrohan`
or `/opt/homebrew`.

`alias zshrc="code ~/.zshrc"` in `shell/zshrc` assumes `code` is on PATH. On
macOS that needs *Shell Command: Install 'code' command in PATH* from the command
palette; the Linux packages add it automatically.

## Verify

```bash
code --list-extensions | wc -l
```
