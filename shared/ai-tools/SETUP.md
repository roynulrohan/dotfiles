# ai-tools

Config for the non-Claude-Code agent tools. Claude Code has its own package —
see `claude/SETUP.md`.

None of this is required for a working machine. Install the ones actually being
used and skip the rest.

## Files

| Repo | Destination | Tool |
|---|---|---|
| `codex/config.toml` | `~/.codex/config.toml` | OpenAI Codex CLI |
| `codex/hooks.json` | `~/.codex/hooks.json` | |
| `gemini/settings.json` | `~/.gemini/settings.json` | Gemini CLI |
| `cursor/mcp.json` | `~/.cursor/mcp.json` | Cursor |
| `cursor/hooks.json` | `~/.cursor/hooks.json` | |
| `factory/settings.json` | `~/.factory/settings.json` | Factory |
| `mastracode/hooks.json` | `~/.mastracode/hooks.json` | Mastra |
| `claude-mem/settings.json` | `~/.claude-mem/settings.json` | claude-mem |

Same paths on both platforms. All symlinkable.

## Gotchas

**`codex/config.toml` has a hardcoded macOS project path** — a
`[projects."/Users/roynulrohan/Coding/…"]` block marking a repo as trusted. It's
harmless on another machine (the path just never matches) but it's noise. Drop
the block, or repoint it, when setting up somewhere new.

**`claude-mem/settings.json` has empty API key fields** —
`CLAUDE_MEM_GEMINI_API_KEY`, `CLAUDE_MEM_OPENROUTER_API_KEY`,
`CLAUDE_MEM_CHROMA_API_KEY` are all `""`. That's why the file is safe to commit.
If you fill any of them in on a machine, **that file must stop being a symlink
into this repo**, or the key gets committed. Copy it instead.

**`cursor/mcp.json`** is currently credential-free. Same rule: adding an MCP
server with an inline API key means it can no longer be linked.

## Not in this repo

Credentials, deliberately: `~/.codex/auth.json`, `~/.gemini/oauth_creds.json`,
`~/.gemini/google_accounts.json`. Each tool re-authenticates on first run.

`~/.codex/AGENTS.md` and `~/.gemini/GEMINI.md` are both empty files on the source
machine, so there was nothing to capture. If global instructions get written for
those tools later, add them here.

## Verify

Each tool reads its own config on launch. `codex --version`, `gemini`, etc. —
there's no shared check worth running.
