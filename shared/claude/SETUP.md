# claude

Claude Code's own settings (`settings.json` only; hooks are entries in it, and
skills and plugins are installed per machine, see below). The global
instructions it reads live in [`shared/agents`](../agents/SETUP.md) and are copied to
`~/.claude/CLAUDE.md`.

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

| Tool | Needed for | CachyOS | macOS | If missing |
|---|---|---|---|---|
| `bun` | installing ccstatusline | `curl -fsSL https://bun.sh/install \| bash` | same | statusline doesn't render |
| `ccstatusline` | statusline, ccstatusline hooks | `bun add -g ccstatusline` | same | statusline doesn't render |
| `rtk` | the `rtk hook claude` entry in `settings.json` | `paru -S rtk-bin` | `brew install rtk` | the hook command fails on every tool call |
| `gh` | `git-pr` statusline segment | `pacman -S github-cli` | `brew install gh` | segment stays blank |

`bun` matters most. The rtk hook is a native binary command, so it needs neither
bash nor jq, but it does need `rtk` on PATH: without it, every tool call hits a
failing hook. On a machine without rtk, run `rtk init -g --uninstall` or drop the
`rtk hook claude` entry from `settings.json`.

Claude Code itself installs with its native installer on both machines:
`curl -fsSL https://claude.ai/install.sh | bash`. It lands in `~/.local/bin`,
which [`shared/fish`](../fish/SETUP.md) puts on PATH (`conf.d/00-roynul-env.fish`).

## Platform notes

- The hook command in `settings.json` is `rtk hook claude`, resolved from PATH,
  so there are no hardcoded paths. `rtk init -g` writes the same line.
- **Plugins and skills are not tracked here.** `settings.json` in this repo has
  no `enabledPlugins` or `extraKnownMarketplaces`, so a fresh machine starts with
  none and you install what you want per machine. Claude Code writes those keys
  back into the live file as you enable plugins, so `./status.sh` will report
  `settings.json` as `seeded` (its manifest mode). That is expected.
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
