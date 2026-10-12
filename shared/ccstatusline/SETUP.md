# ccstatusline

The Claude Code statusline. Four lines: speed + active skills / model + thinking
effort + context bar / session usage, weekly usage, cost, clock / git branch,
worktree, changes, ahead-behind, conflicts, PR.

## Files

| Repo | Destination |
|---|---|
| `settings.json` | `~/.config/ccstatusline/settings.json` |

Same path on both platforms. Copy it into place.

## Dependencies

A global install: `bun add -g ccstatusline`. The statusline runs as
`ccstatusline` from PATH (bun installs it to `~/.bun/bin`), wired up in
`shared/claude/settings.json` under `statusLine` and as `--hook` entries on
`UserPromptSubmit` and `PreToolUse:Skill`. It stays on the installed version
until you run `bun add -g ccstatusline@latest`.

ccstatusline records the install in an `installation` block in the live
`settings.json`. That block is per machine and is not in this repo, so
`./status.sh` reports the file as `seeded` (its manifest mode).

`gh` is optional and only feeds the `git-pr` segment.

## Platform notes

Fully portable — it's a layout description, no paths inside. Needs a Nerd Font
for the segment glyphs (JetBrainsMono Nerd Font, see `AGENTS.md`) and a terminal with truecolor;
`colorLevel: 3` means 24-bit. Ghostty and kitty both qualify.

`powerline.enabled` is `false`, so no powerline separator glyphs are required
beyond the Nerd Font already needed for the prompt.

## Gotcha

Re-running the ccstatusline installer **appends** its hooks to
`~/.claude/settings.json` without checking whether they're already there. Running it
three times gets you three copies on each event and three ccstatusline processes per
keystroke. The config in this repo is deduplicated — if you install ccstatusline
via its own installer rather than by copying this file, check
`~/.claude/settings.json` afterwards and remove the duplicates.

## Verify

Start Claude Code — four lines should appear at the bottom. If they're blank,
`ccstatusline` is not on PATH: run `bun add -g ccstatusline`. If they're full of
tofu, the Nerd Font isn't selected.
