# agents

[`AGENTS.md`](../../AGENTS.md) is my global instructions for any AI agent. Copy it wherever the
agent reads global instructions, usually `~/.claude/CLAUDE.md` or
`~/.codex/AGENTS.md`.

After copying it to `~/.claude/CLAUDE.md`, run `rtk init -g`. rtk adds an
`@RTK.md` line to the end of that file, so `./status.sh` then reports
`~/.claude/CLAUDE.md` as `seeded` (its manifest mode). That difference is
expected.

## Tools I like

Ask me before installing any of these, or install them when I tell you to.
Once installed they manage themselves; their files don't belong in here.

- **Install:** [rtk](https://github.com/rtk-ai/rtk), a CLI proxy that cuts token
  use. Its init wires up the rest.
- **Skills:** [mattpocock/skills](https://github.com/mattpocock/skills).
- **More skills:** the [skills CLI](https://skills.sh), which also keeps them
  updated.

Codex settings worth setting by hand in `~/.codex/config.toml`: `model`,
`model_reasoning_effort = "high"`, `personality = "pragmatic"`. The rest of that
file is state Codex writes itself.
