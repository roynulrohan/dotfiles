# ccstatusline

The Claude Code statusline, on four lines:

1. Model, thinking effort, Claude service status with a 48-hour incident
   strip, Claude Code version, and the skills used this session.
2. Session name (after `/rename`), context bar, compaction count (hidden at
   zero), then speed, total tokens, the prompt cache timer and cache hit rate.
3. Session and weekly usage with their reset countdowns, Fable weekly usage,
   then session cost and cost per hour.
4. Git: origin owner/repo as a link, branch, worktree, commits and diff of
   the branch against the default branch, then clean/dirty,
   staged/unstaged/untracked file counts, insertions and deletions,
   ahead-behind, conflicts, PR and SHA.
   Each segment hides when it has nothing to say.

## Files

| Repo | Destination |
|---|---|
| [`settings.json`](settings.json) | `~/.config/ccstatusline/settings.json` |
| [`git-branch-stat`](git-branch-stat) | `~/.local/bin/git-branch-stat` |

Same paths on both OSes. `git-branch-stat` is the custom command behind the
"commits vs main" segment: it reads the status JSON on stdin, compares the
branch with `origin/HEAD` (fallback `main`, then `master`) and prints nothing
on the default branch or when the branch has no commits of its own. It needs
`python3` and `git` on PATH.

## Install

Both OSes, with bun installed ([`shared/claude`](../claude/SETUP.md),
Install):

```bash
bun add -g ccstatusline
```

bun only installs it. ccstatusline runs on Node.js (`#!/usr/bin/env node`).
Install Node.js by name (CachyOS/Arch: `sudo pacman -S nodejs`; macOS:
`brew install node`). Without Node.js, the statusline stays empty and every
hook entry fails. If another package pulled Node.js in as a dependency,
`pacman -Rns` on that package removes Node.js too.

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
- The config has no paths inside: the custom command is `git-branch-stat`
  from PATH. So it works on both OSes unchanged. `colorLevel: 3` means 24-bit
  colour.
- The cache timer assumes the 1-hour prompt cache (`ttlSeconds: 3600`). Claude
  Code drops to the 5-minute cache in usage overage; the timer does not know.
- `powerline.enabled` is `false`, so it needs no powerline separator glyphs
  beyond the Nerd Font.

### Duplicate hooks

The ccstatusline installer **appends** its hooks to `~/.claude/settings.json`
each time it runs, and does not check for copies that are already there. Each
copy starts one more ccstatusline process on every hook event. The config in
this repo has each hook once. If you use the installer instead of copying these
files, check `~/.claude/settings.json` afterwards and remove the duplicates.

## Verify

```bash
command -v ccstatusline   # ~/.bun/bin/ccstatusline
```

Start Claude Code: four lines appear at the bottom. If they are blank,
`ccstatusline` is not on PATH: run `bun add -g ccstatusline`. If they are full
of empty boxes, the terminal font is not a Nerd Font.
