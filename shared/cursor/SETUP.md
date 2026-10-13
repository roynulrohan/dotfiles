# cursor

Cursor editor settings and keybindings. Cursor is a separate install with its
own config folder from VS Code ([`shared/vscode`](../vscode/SETUP.md)).
Cursor writes its agent config (`mcp.json`, `hooks.json`) itself, and this repo
does not track it.

## Files

| Repo | macOS | Linux |
|---|---|---|
| [`settings.json`](settings.json) | `~/Library/Application Support/Cursor/User/settings.json` | `~/.config/Cursor/User/settings.json` |
| [`keybindings.json`](keybindings.json) | `~/Library/Application Support/Cursor/User/keybindings.json` | `~/.config/Cursor/User/keybindings.json` |

## Install

- macOS: `brew install --cask cursor`
- Linux: the AppImage from [cursor.com](https://cursor.com). Put it on PATH
  as `cursor` (for example `~/.local/bin/cursor`).

`./status.sh` skips these rows until Cursor is installed: on macOS it looks for
`/Applications/Cursor.app`, on Linux for a `cursor` command on PATH.

Extensions are not captured for Cursor; reinstall them by hand. The
Brewfile's `vscode` lines are VS Code's list. Cursor uses a different
marketplace, so `cursor --install-extension` may not resolve the same
identifiers.

## Notes

- Cursor is a VS Code fork, so the settings schema is the same and most of
  [`shared/vscode/settings.json`](../vscode/settings.json) would apply here
  too. The two files differ, so keep them separate; don't merge them into one.
- `keybindings.json` is written for the Mac. Its two `cmd+` binds carry `isMac`
  in their `when` clause, because on Linux `cmd` means Super, which Hyprland
  takes first. The `-` entries remove macOS defaults and do nothing on Linux.
- Before you copy a live `settings.json` back, remove hardcoded home paths
  such as `/Users/<name>`. The shared file must not contain any.

## Verify

```bash
./status.sh | grep Cursor   # settings.json and keybindings.json: ok ("skipped" without Cursor)
```

Then launch Cursor, open Settings (JSON) from the command palette, and confirm
it matches [`settings.json`](settings.json).
