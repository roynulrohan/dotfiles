# ccstatusline

The Claude Code statusline, on four lines: speed and active skills; model,
thinking effort and context bar; session usage, weekly usage (all models and
Fable), the weekly reset timer and session cost; git branch, worktree, changes,
ahead-behind, conflicts and PR.

## Files

| Repo | Destination |
|---|---|
| [`settings.json`](settings.json) | `~/.config/ccstatusline/settings.json` |

Same path on both OSes.

## Install

Both OSes, with bun installed ([`shared/claude`](../claude/SETUP.md),
Install):

```bash
bun add -g ccstatusline
```

Optional, for the PR segment: `gh` (CachyOS/Arch: `sudo pacman -S
github-cli`; macOS: `brew install gh`).

It also needs JetBrainsMono Nerd Font for the segment glyphs
(`ttf-jetbrains-mono-nerd` on Arch, the `font-jetbrains-mono-nerd-font` cask on
macOS) and a truecolor terminal. kitty and Ghostty both qualify.

## Notes

- Claude Code runs the statusline as `ccstatusline` from PATH (bun installs it
  to `~/.bun/bin`). [`shared/claude/settings.json`](../claude/settings.json)
  wires it up under `statusLine` and as `--hook` entries on `UserPromptSubmit`
  and `PreToolUse:Skill`.
- It stays on the installed version until you run
  `bun add -g ccstatusline@latest`.
- ccstatusline records the install in an `installation` block in the live
  `settings.json`. That block is per machine and is not in this repo, so
  `./status.sh` reports the file as `seeded` (its manifest mode).
- The config is a layout description with no paths inside, so it is fully
  portable. `colorLevel: 3` means 24-bit colour.
- `powerline.enabled` is `false`, so it needs no powerline separator glyphs
  beyond the Nerd Font.

### Duplicate hooks

Re-running the ccstatusline installer **appends** its hooks to
`~/.claude/settings.json` without checking whether they are already there. Run
it three times and you get three copies on each event, and three ccstatusline
processes per keystroke. The config in this repo has each hook once. If you
install ccstatusline with its own installer instead of copying these files,
check `~/.claude/settings.json` afterwards and remove the duplicates.

## Verify

```bash
command -v ccstatusline   # ~/.bun/bin/ccstatusline
```

Start Claude Code: four lines appear at the bottom. If they are blank,
`ccstatusline` is not on PATH: run `bun add -g ccstatusline`. If they are full
of empty boxes, the terminal font is not a Nerd Font.
