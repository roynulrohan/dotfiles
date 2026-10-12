# orca

[Orca](https://github.com/stablyai/orca), the desktop app that runs coding
agents in git worktrees. `settings.json` holds the settings changed from Orca's
defaults: dark theme, One Dark terminal colours with the terminal background
blended into Orca's own (opacity 0), the "Bun Dev" quick command, Claude Code as the default agent, and notifications with the
terminal bell.

## Files

| Repo | Destination |
|---|---|
| `settings.json` | Orca's `settings`, both OSes |
| `settings.macos.json` | the same, macOS only |
| `settings.linux.json` | the same, Linux only |

The profile lives in `profiles/<profile>/` under Orca's data directory:
`~/Library/Application Support/Orca` on macOS, `~/.config/orca` on Linux.
`orca-settings.sh` reads the active profile from `orca-profile-index.json`
(`local-default` on both machines). `settings.json` holds what both machines
share; `settings.<os>.json` holds the values that differ per OS and wins over
it: the terminal font name, window blur and Linux's text colour. `export` writes
each key back to the file it came from.

Where Orca keeps the settings depends on its version:
- **Orca 1.4.222 and later** (CachyOS): `profile-state.db`, a SQLite database
  with one row per top-level section. `orca-data.json` is only an export Orca
  checks by hash (the `legacy_json_acceptance` marker in the database). Editing it
  by hand makes Orca ask "This profile has two saved copies that don't match" on
  every launch, and "Use JSON" didn't fix that; restoring the newest
  `orca-data.json.sqlite-export.N.json` (with `cp -p`) did. The script writes the
  `settings` row the way Orca saves one: compact JSON, its SHA-256 as
  `content_hash`, the next profile `revision` on the row and in the meta table.
  It leaves `orca-data.json` alone, which Orca reads as an older accepted export.
- **Older Orca** (the Mac, 1.4.206): everything is in `orca-data.json`, and the
  script edits its `settings` object.

The profile also holds repos, worktrees, sessions and the managed Claude and
Codex accounts, so it is never copied whole: the script deep-merges only the
tracked keys, keeping nested keys a newer Orca adds.

```bash
./orca-settings.sh diff     # live values against the repo files
./orca-settings.sh apply    # merge the repo files into Orca; quit Orca first
./orca-settings.sh export   # copy the live values back into the repo files
```

`apply` refuses to run while Orca is open: Orca writes its in-memory state back,
which would undo the merge. On Linux the AppImage's processes are named
`orca-ide`. Orca's background daemon (`daemon-entry.js`), which keeps terminal
sessions alive after the window closes, is ignored: it doesn't open the profile
data. `apply` leaves a backup at `profile-state.db.dotfiles-bak` or
`orca-data.json.dotfiles-bak`. The script needs `jq` and, for the database,
`sqlite3`.

`manifest.tsv` lists Orca as a `manual` row and `./status.sh` does not check
it, because the destination is part of a file. Use `./orca-settings.sh diff`.

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
- **Window blur:** in Orca 1.4.222 `windowBackgroundBlur` only does anything on
  Windows (acrylic). The macOS vibrancy was removed (`createMainWindow.ts`, Orca
  issue #8482) and Linux never had it, and Orca never makes its window
  transparent, so it can't show the desktop behind it on either OS. The Mac's
  glass look on 1.4.206 goes away when it updates. `terminalBackgroundOpacity` 0
  only lets Orca's own window background show through the terminal.
- **Text colour (Linux):** Hyprland's window transparency (`windowOpacity` in
  [`linux/hypr/hypr-vars.lua`](../../linux/hypr/hypr-vars.lua), 95% when this was set) applies to the text too, so One
  Dark's grey text (`abb2bf`) looked dim. `settings.linux.json` brightens it with
  `terminalColorOverrides.foreground` `dcdfe4` (Settings → Color Overrides). The
  Mac keeps plain One Dark.
- To track another setting, add its key to `settings.json` with any value, then
  run `export`. Leave out credentials and account fields (`*ManagedAccounts`,
  `opencodeSessionCookie`, `minimaxGroupId`, proxy settings), `telemetry`, and
  Orca's `*Migrated` and `*DefaultedFor*` flags.
- Orca writes its own agent hooks into `~/.orca/agent-hooks`. They are not in
  this repo.

## Verify

```bash
./orca-settings.sh diff   # in sync
```

A `+` line with no `-` line is a nested key that a newer Orca added. It is not
drift. Orca opens without the "two saved copies that don't match" question.
