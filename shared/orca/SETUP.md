# orca

[Orca](https://github.com/stablyai/orca), the desktop app that runs coding
agents in git worktrees. `settings.json` holds the settings changed from Orca's
defaults: dark theme, One Dark terminal on a transparent background, the "Bun
Dev" quick command, Claude Code as the default agent, and notifications with the
terminal bell.

## Files

| Repo | Destination |
|---|---|
| `settings.json` | macOS: the `settings` object in `~/Library/Application Support/Orca/profiles/<profile>/orca-data.json` |

`orca-data.json` also holds repos, worktrees, sessions and the managed Claude and
Codex accounts, so it is never copied whole. `orca-settings.sh` merges only the
keys in `settings.json`. It reads the active profile from
`orca-profile-index.json` in the same directory (`local-default` here).

```bash
./orca-settings.sh diff     # live values against settings.json
./orca-settings.sh apply    # merge settings.json into Orca; quit Orca first
./orca-settings.sh export   # copy the live values back into settings.json
```

`apply` refuses to run while Orca is open: Orca writes its in-memory state back
to `orca-data.json`, which would undo the merge. It leaves a backup at
`orca-data.json.dotfiles-bak`. The script needs `jq`.

`manifest.tsv` has no row for Orca and `./status.sh` does not check it, because
the destination is part of a file. Use `./orca-settings.sh diff`.

## Install

macOS: the `.dmg` from the GitHub releases page. Orca updates itself. Homebrew's
`orca` cask is a different app (plotly's chart renderer). Sign in to Orca's cloud
account by hand.

## Notes

- The terminal font family is the preference: JetBrainsMono Nerd Font (`NFM` is
  the Mono variant). Use whatever name it has on the machine.
- To track another setting, add its key to `settings.json` with any value, then
  run `export`. Leave out credentials and account fields (`*ManagedAccounts`,
  `opencodeSessionCookie`, `minimaxGroupId`, proxy settings), `telemetry`, and
  Orca's `*Migrated` and `*DefaultedFor*` flags.
- Orca writes its own agent hooks into `~/.orca/agent-hooks`. They are not in
  this repo.
