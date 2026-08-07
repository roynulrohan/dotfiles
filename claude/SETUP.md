# claude

Claude Code: global instructions, settings, hooks, and skills. The most important
package here.

## Files

| Repo | Destination |
|---|---|
| `CLAUDE.md` | `~/.claude/CLAUDE.md` |
| `RTK.md` | `~/.claude/RTK.md` |
| `settings.json` | `~/.claude/settings.json` |
| `hooks/rtk-rewrite.sh` | `~/.claude/hooks/rtk-rewrite.sh` (must be `chmod +x`) |
| `skills/gh/` | `~/.claude/skills/gh/` |
| `agent-skills/*` | `~/.agents/skills/` — see below |

All symlinkable. If `CLAUDE_CONFIG_DIR` is set, use that instead of `~/.claude`.

`CLAUDE.md` ends with `@RTK.md`, an import — both files must be present or the
import dangles.

## agent-skills

`~/.claude/skills/` normally contains symlinks pointing out to `~/.agents/skills/`,
a directory shared with other agent tools. On a fresh machine those links point
at nothing and the skills vanish silently.

Place the contents of `agent-skills/` at `~/.agents/skills/` first, then recreate
the links:

```bash
mkdir -p ~/.agents/skills
for s in ~/dotfiles/claude/agent-skills/*/; do
  ln -sfn "$s" ~/.agents/skills/"$(basename "$s")"
  ln -sfn ../../.agents/skills/"$(basename "$s")" ~/.claude/skills/"$(basename "$s")"
done
```

Four skills: `find-skills`, `hermes-agent`, `mobile-responsiveness`,
`tailwindcss-responsive-darkmode`.

## Dependencies

| Tool | Needed for | macOS | Debian/Ubuntu | If missing |
|---|---|---|---|---|
| `bun` | statusline, ccstatusline hooks | `curl -fsSL https://bun.sh/install \| bash` | same | statusline doesn't render |
| `jq` | RTK hook | `brew install jq` | `apt install jq` | hook warns once, passes commands through |
| `rtk` | RTK hook | `brew install rtk` | `cargo install rtk` (needs ≥0.23.0) | same |
| `gh` | `git-pr` statusline segment | `brew install gh` | [cli.github.com](https://github.com/cli/cli/blob/trunk/docs/install_linux.md) | segment stays blank |

Only `bun` really matters. The RTK hook checks for `jq` and `rtk` itself and
exits cleanly when they're absent, so a machine without them works fine — you
just lose the token savings.

## Platform notes

- The hook command in `settings.json` is
  `"${CLAUDE_CONFIG_DIR:-$HOME/.claude}/hooks/rtk-rewrite.sh"` — no hardcoded
  paths. Keep it that way.
- `enabledPlugins` and `extraKnownMarketplaces` are fetched by Claude Code on
  first run. Nothing to install by hand; expect a delay on first launch.
- `settings.json` sets `"permissions": {"defaultMode": "dontAsk"}`. Worth
  confirming that's wanted on a shared or production machine before linking.
- **Claude Code rewrites `settings.json`** when you change things via `/config`.
  If it saves by rename, the symlink is replaced by a regular file and the repo
  silently stops tracking your edits. Check with
  `test -L ~/.claude/settings.json`; if it's not a link, copy it back into the
  repo and relink.

## Auth

Not in this repo. Run `claude` and sign in on first launch. `~/.claude.json`
holds project state and MCP credentials and is deliberately excluded.

## Verify

```bash
test -L ~/.claude/settings.json && echo linked
jq -e . ~/.claude/settings.json >/dev/null && echo "valid json"
echo '{"tool_input":{"command":"git status"}}' | ~/.claude/hooks/rtk-rewrite.sh
```

That last one should emit JSON rewriting the command to `rtk git status`. With
`rtk` or `jq` absent it prints a warning and nothing else — also correct.

In Claude Code: `/status` shows the loaded config, and the statusline should
appear across four lines.
