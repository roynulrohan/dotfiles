# ccstatusline

The Claude Code statusline. Four lines: speed + active skills / model + thinking
effort + context bar / session usage, weekly usage, cost, clock / git branch,
worktree, changes, ahead-behind, conflicts, PR.

## Files

| Repo | Destination |
|---|---|
| `settings.json` | `~/.config/ccstatusline/settings.json` |

Same path on both platforms. Symlink it.

## Dependencies

`bun` — the statusline runs as `bunx -y ccstatusline@latest`, wired up in
`claude/settings.json` under `statusLine` and as `--hook` entries on
`UserPromptSubmit` and `PreToolUse:Skill`. Nothing to install separately; bunx
fetches it on first use.

`gh` is optional and only feeds the `git-pr` segment.

## Platform notes

Fully portable — it's a layout description, no paths inside. Needs a Nerd Font
for the segment glyphs (see `shell/SETUP.md`) and a terminal with truecolor;
`colorLevel: 3` means 24-bit. Ghostty and kitty both qualify.

`powerline.enabled` is `false`, so no powerline separator glyphs are required
beyond the Nerd Font already needed for the prompt.

## Gotcha

Re-running the ccstatusline installer **appends** its hooks to
`claude/settings.json` without checking whether they're already there. Running it
three times gets you three copies on each event and three `bunx` processes per
keystroke. The config in this repo is deduplicated — if you install ccstatusline
via its own installer rather than by linking this file, check
`claude/settings.json` afterwards and remove the duplicates.

## Verify

Start Claude Code — four lines should appear at the bottom. If they're blank,
`bun` is missing. If they're full of tofu, the Nerd Font isn't selected.
