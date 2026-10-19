# Agent instructions

One file of global instructions for AI coding agents. Claude Code and Codex
each read it from their own config folder.

## Files

| Repo | Destination | Mode |
|---|---|---|
| [`AGENTS.md`](AGENTS.md) | `~/.claude/CLAUDE.md` | `seed` |
| [`AGENTS.md`](AGENTS.md) | `~/.codex/AGENTS.md` | `copy` |

Another agent can take the same file: copy it wherever that agent reads global
instructions.

## Install

Install Claude Code and rtk with [`shared/claude`](../claude/SETUP.md). Copy
`AGENTS.md` to `~/.claude/CLAUDE.md` before you run its `rtk init -g` step.
rtk then adds an `@RTK.md` line to the end of that file.

## Notes

- Because rtk adds that line, `./status.sh` reports `~/.claude/CLAUDE.md` as
  `seeded` (its manifest mode).
- Optional skills, not tracked here:
  [mattpocock/skills](https://github.com/mattpocock/skills), and the
  [skills CLI](https://skills.sh), which also keeps installed skills updated.
- `~/.codex/config.toml` is not in the repo, because Codex writes most of it
  as state. Set these keys by hand: `model`,
  `model_reasoning_effort = "high"`, `personality = "pragmatic"`.

## Verify

Run from the repo root:

```bash
diff shared/agents/AGENTS.md ~/.codex/AGENTS.md    # no output
diff shared/agents/AGENTS.md ~/.claude/CLAUDE.md   # only lines that tools add, such as rtk's @RTK.md
rtk init --show                                    # Global (~/.claude/CLAUDE.md): @RTK.md reference [ok]
```
