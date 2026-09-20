# cursor

Cursor editor settings and keybindings. Separate install and separate config
directory from VS Code, see `../vscode/`. Cursor's agent config (`mcp.json`,
`hooks.json`) is written by Cursor and not tracked here.

## Files

| Repo | macOS | Linux |
|---|---|---|
| `settings.json` | `~/Library/Application Support/Cursor/User/settings.json` | `~/.config/Cursor/User/settings.json` |
| `keybindings.json` | `~/Library/Application Support/Cursor/User/keybindings.json` | `~/.config/Cursor/User/keybindings.json` |

**Different path per OS.** Symlink both.

## Install

- macOS: `brew install --cask cursor`
- Linux: AppImage from [cursor.com](https://cursor.com) — no apt repo.

## Notes

Cursor is a VS Code fork, so the settings schema is the same and most of
`../vscode/settings.json` would apply here too. They're kept as separate files
because they've drifted; don't try to merge them into one.

Extensions are not captured for Cursor. The `Brewfile`'s `vscode` lines are VS
Code's list — Cursor uses a different marketplace and `cursor --install-extension`
won't necessarily resolve the same identifiers. Reinstall by hand.

Same caveat as VS Code: skim `settings.json` after linking for hardcoded
`/Users/roynulrohan` paths.

## Verify

Launch Cursor, open Settings (JSON) from the command palette, confirm it matches.
