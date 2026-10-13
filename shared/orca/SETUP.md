# orca

[Orca](https://github.com/stablyai/orca), the desktop app that runs coding
agents in git worktrees. The repo holds only the settings changed from Orca's
defaults: dark theme, One Dark terminal colours with the terminal background
blended into Orca's own (opacity 0), the "Bun Dev" quick command, Claude Code as
the default agent, and notifications with the terminal bell.
[`orca-settings.sh`](orca-settings.sh) merges them into Orca's profile.

## Files

| Repo | Destination |
|---|---|
| [`settings.json`](settings.json) | the `settings` of Orca's active profile, both OSes |
| [`settings.macos.json`](settings.macos.json) | the same, macOS only |
| [`settings.linux.json`](settings.linux.json) | the same, Linux only |

The profile lives in `profiles/<profile>/` under Orca's data folder:
`~/Library/Application Support/Orca` on macOS, `~/.config/orca` on Linux.
`orca-settings.sh` reads the active profile from `orca-profile-index.json`
(`local-default` if none is set).

`settings.json` holds what both OSes share. `settings.<os>.json` holds the
values that differ per OS and wins over it: the terminal font name, window
blur, and the Linux text colour.

`manifest.tsv` lists Orca as a `manual` row, and `./status.sh` does not check
it, because the destination is part of a file. Use `./orca-settings.sh diff`.

## Install

- macOS: the `.dmg` from Orca's GitHub releases page. Homebrew's `orca` cask is
  a different app (plotly's chart renderer).
- Linux: the AppImage from the same page, integrated with AppImageLauncher (it
  lands in `~/Applications`). AppImageLauncher: `paru -S appimagelauncher`
  (AUR), then `systemctl --user enable --now appimagelauncherd`.
- The script needs `jq`, and `sqlite3` for newer Orca. CachyOS/Arch:
  `sudo pacman -S jq sqlite`. macOS: `brew install jq` (macOS includes
  `sqlite3`).

Orca updates itself. Sign in to Orca's cloud account by hand.

After installing, quit Orca and apply the settings:

```bash
./orca-settings.sh diff     # live values against the repo files
./orca-settings.sh apply    # merge the repo files into Orca; quit Orca first
./orca-settings.sh export   # copy the live values back into the repo files
```

## Notes

### How the script stores settings

Where Orca keeps the settings depends on its version:

- **Orca 1.4.222 and later:** `profile-state.db`, a SQLite database with one
  row per top-level section. `orca-data.json` is only an export that Orca
  checks by hash (the `legacy_json_acceptance` marker in the database). Don't
  edit `orca-data.json` by hand: Orca then asks "This profile has two saved
  copies that don't match" on every launch. "Use JSON" does not fix that.
  Restoring the newest `orca-data.json.sqlite-export.N.json` (with `cp -p`)
  does. The script writes the `settings` row the way Orca saves one: compact
  JSON, its SHA-256 as `content_hash`, and the next profile `revision` on the
  row and in the meta table. It leaves `orca-data.json` alone, which Orca reads
  as an older accepted export.
- **Older Orca, such as 1.4.206:** everything is in `orca-data.json`, and the
  script edits its `settings` object.

The profile also holds repos, worktrees, sessions and the managed Claude and
Codex accounts, so it is never copied whole. The script deep-merges only the
tracked keys, and keeps nested keys that a newer Orca adds. `export` writes
each key back to the file it came from.

`apply` refuses to run while Orca is open, because Orca writes its in-memory
state back, which would undo the merge. On Linux the AppImage's processes are
named `orca-ide`. The script ignores Orca's background daemon
(`daemon-entry.js`), which keeps terminal sessions alive after the window
closes: it doesn't open the profile data. `apply` leaves a backup at
`profile-state.db.dotfiles-bak` or `orca-data.json.dotfiles-bak`.

### Settings

- The terminal font is JetBrainsMono Nerd Font Mono (`NFM`). Its family name
  differs per OS, so it lives in the per-OS files: `JetBrainsMono NFM Regular`
  on macOS, `JetBrainsMono NFM` on Linux (`fc-list : family | grep NFM`).
- **Window blur:** from Orca 1.4.222, `windowBackgroundBlur` only does
  anything on Windows (acrylic). Orca removed the macOS vibrancy
  (`createMainWindow.ts`, Orca issue #8482), Linux never had it, and Orca never
  makes its window transparent. So it can't show the desktop behind it on
  either OS. Older Orca, such as 1.4.206, still shows the glass look on macOS.
  `terminalBackgroundOpacity` 0 only lets Orca's own window background show
  through the terminal.
- **Text colour (Linux):** Hyprland's window transparency (`windowOpacity` in
  [`linux/hypr/hypr-vars.lua`](../../linux/hypr/hypr-vars.lua)) applies to the
  text too, so One Dark's grey text (`abb2bf`) looks dim. `settings.linux.json`
  brightens it with `terminalColorOverrides.foreground` `dcdfe4` (Settings →
  Color Overrides). macOS keeps plain One Dark.
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
