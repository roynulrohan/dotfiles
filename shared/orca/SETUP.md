# orca

[Orca](https://github.com/stablyai/orca), the desktop app that runs coding
agents in git worktrees. `settings.json` holds the settings changed from Orca's
defaults: dark theme, One Dark terminal on a transparent background, the "Bun
Dev" quick command, Claude Code as the default agent, and notifications with the
terminal bell.

## Files

| Repo | Destination |
|---|---|
| `settings.json` | the `settings` object in `orca-data.json`, both OSes |
| `settings.macos.json` | the same object, macOS only |
| `settings.linux.json` | the same object, Linux only |

`orca-data.json` lives in `profiles/<profile>/` under Orca's data directory:
`~/Library/Application Support/Orca` on macOS, `~/.config/orca` on Linux.
`settings.json` holds what both machines share. `settings.<os>.json` holds the
values that differ per OS, and wins over it: the terminal font name, window
blur (macOS glass; Hyprland blurs on Linux) and the terminal background opacity.
`export` writes each key back to the file it came from.

`orca-data.json` also holds repos, worktrees, sessions and the managed Claude and
Codex accounts, so it is never copied whole. `orca-settings.sh` merges only the
keys in `settings.json` and this OS's file. It reads the active profile from
`orca-profile-index.json` in the same directory (`local-default` here).

```bash
./orca-settings.sh diff     # live values against the repo files
./orca-settings.sh apply    # merge the repo files into Orca; quit Orca first
./orca-settings.sh export   # copy the live values back into settings.json
```

`apply` refuses to run while Orca is open: Orca writes its in-memory state back
to `orca-data.json`, which would undo the merge. It leaves a backup at
`orca-data.json.dotfiles-bak`. The script needs `jq`.

`manifest.tsv` has no row for Orca and `./status.sh` does not check it, because
the destination is part of a file. Use `./orca-settings.sh diff`.

## Install

macOS: the `.dmg` from the GitHub releases page. Linux: the AppImage from the
same page, integrated with AppImageLauncher (it lands in `~/Applications`).
Orca updates itself. Homebrew's
`orca` cask is a different app (plotly's chart renderer). Sign in to Orca's cloud
account by hand.

## Notes

- The terminal font family is the preference: JetBrainsMono Nerd Font (`NFM` is
  the Mono variant). Its name differs per machine, so it lives in the per-OS
  files: `JetBrainsMono NFM Regular` on the Mac, `JetBrainsMono NFM` on CachyOS
  (`fc-list : family | grep NFM`).
- To track another setting, add its key to `settings.json` with any value, then
  run `export`. Leave out credentials and account fields (`*ManagedAccounts`,
  `opencodeSessionCookie`, `minimaxGroupId`, proxy settings), `telemetry`, and
  Orca's `*Migrated` and `*DefaultedFor*` flags.
- Orca writes its own agent hooks into `~/.orca/agent-hooks`. They are not in
  this repo.
