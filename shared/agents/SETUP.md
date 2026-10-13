# agents

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

Claude Code itself: see [`shared/claude`](../claude/SETUP.md).

rtk, a CLI proxy that cuts token use:

- CachyOS/Arch: `paru -S rtk-bin` (AUR)
- macOS: `brew install rtk`

After copying `AGENTS.md` to `~/.claude/CLAUDE.md`, run `rtk init -g`. It adds
an `@RTK.md` line to the end of that file and wires up the rest.

## Notes

- Because rtk adds that line, `./status.sh` reports `~/.claude/CLAUDE.md` as
  `seeded` (its manifest mode). That difference is expected.
- Optional skills, not tracked here:
  [mattpocock/skills](https://github.com/mattpocock/skills), and the
  [skills CLI](https://skills.sh), which also keeps installed skills updated.
  Once installed, they manage themselves, and their files stay out of this
  repo.
- `~/.codex/config.toml` is not in the repo, because Codex writes most of it
  as state. Set these keys by hand: `model`,
  `model_reasoning_effort = "high"`, `personality = "pragmatic"`.

## Verify

Run from the repo root:

```bash
diff shared/agents/AGENTS.md ~/.codex/AGENTS.md    # no output
diff shared/agents/AGENTS.md ~/.claude/CLAUDE.md   # only the blank line and @RTK.md that rtk adds
rtk init --show                                    # Global (~/.claude/CLAUDE.md): @RTK.md reference [ok]
```
