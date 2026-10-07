# claude

Claude Code's own settings, hooks, and skills. The global instructions it reads
live in `shared/agents` and are copied to `~/.claude/CLAUDE.md`.

## Files

| Repo | Destination |
|---|---|
| `settings.json` | `~/.claude/settings.json` |

Copy it into place. If `CLAUDE_CONFIG_DIR` is set, use that instead of `~/.claude`.

`settings.json` registers `rtk hook claude`, the native hook from
[rtk](https://github.com/rtk-ai/rtk), which rewrites shell commands to cut token
use. rtk installs and maintains that hook itself: run `rtk init -g`. Nothing
about it is stored here beyond the one line in `settings.json`.

## Dependencies

| Tool | Needed for | macOS | Debian/Ubuntu | If missing |
|---|---|---|---|---|
| `bun` | installing ccstatusline | `curl -fsSL https://bun.sh/install \| bash` | same | statusline doesn't render |
| `ccstatusline` | statusline, ccstatusline hooks | `bun add -g ccstatusline` | same | statusline doesn't render |
| `rtk` | the `rtk hook claude` entry in `settings.json` | `brew install rtk` | `cargo install rtk` | the hook command fails on every tool call |
| `gh` | `git-pr` statusline segment | `brew install gh` | [cli.github.com](https://github.com/cli/cli/blob/trunk/docs/install_linux.md) | segment stays blank |

`bun` matters most. The rtk hook is a native binary command, so it needs neither
bash nor jq, but it does need `rtk` on PATH: without it, every tool call hits a
failing hook. On a machine without rtk, run `rtk init -g --uninstall` or drop the
`rtk hook claude` entry from `settings.json`.

**On WSL and Debian/Ubuntu, `rtk` has no package** — it needs a Rust toolchain
(`curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh`, then
`cargo install rtk`). That's a big dependency for a token optimiser, so skipping
it is reasonable. If you skip it, remove the hook entry as well, and say you did
both.

Claude Code itself installs on WSL with the same native installer as Linux:
`curl -fsSL https://claude.ai/install.sh | bash`. It lands in `~/.local/bin`,
which `shell/zshrc` already adds to PATH.

## Platform notes

- The hook command in `settings.json` is `rtk hook claude`, resolved from PATH,
  so there are no hardcoded paths. `rtk init -g` writes the same line.
- **Plugins and skills are not tracked here.** `settings.json` in this repo has
  no `enabledPlugins` or `extraKnownMarketplaces`, so a fresh machine starts with
  none and you install what you want per machine. Claude Code writes those keys
  back into the live file as you enable plugins, so `./status.sh` will report
  `settings.json` as differing. That is expected.
- `settings.json` sets `"permissions": {"defaultMode": "auto"}`. Worth
  confirming that's wanted on a shared or production machine before copying.
- **Claude Code rewrites `settings.json`** when you change things via `/config`.
  Those edits land only in the live file. Run `./status.sh` to see the drift, and
  copy the file back into the repo when you want to keep them. Leave out the
  per-machine plugin keys when you do.

## Auth

Not in this repo. Run `claude` and sign in on first launch. `~/.claude.json`
holds project state and MCP credentials and is deliberately excluded.

## Verify

```bash
diff shared/claude/settings.json ~/.claude/settings.json
jq -e . ~/.claude/settings.json >/dev/null && echo "valid json"
rtk init --show
```

The last one should report the hook, `RTK.md`, and the `@RTK.md` reference in
`~/.claude/CLAUDE.md` as configured.

In Claude Code: `/status` shows the loaded config, and the statusline should
appear across four lines.
