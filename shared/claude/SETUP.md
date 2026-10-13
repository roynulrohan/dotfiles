# claude

Claude Code's own settings: its hooks, the statusline, and the model and
permission defaults. The global instructions it reads come from
[`shared/agents`](../agents/SETUP.md) and are copied to `~/.claude/CLAUDE.md`.

## Files

| Repo | Destination |
|---|---|
| [`settings.json`](settings.json) | `~/.claude/settings.json` |

If `CLAUDE_CONFIG_DIR` is set, use that folder instead of `~/.claude`. Skills
and plugins are installed per machine and are not in this repo.
`~/.claude.json` holds project state and MCP credentials and stays out of the
repo on purpose.

## Install

Both OSes:

```bash
curl -fsSL https://claude.ai/install.sh | bash   # Claude Code, native installer
curl -fsSL https://bun.sh/install | bash         # bun, to install ccstatusline
bun add -g ccstatusline                          # the statusline, see shared/ccstatusline
```

Claude Code lands in `~/.local/bin`, which [`shared/fish`](../fish/SETUP.md)
puts on PATH (`conf.d/00-roynul-env.fish`).

rtk and gh:

- CachyOS/Arch: `paru -S rtk-bin` (AUR) and `sudo pacman -S github-cli`
- macOS: `brew install rtk gh`

After copying:

1. Run `rtk init -g`. rtk installs and maintains its hook itself.
2. Run `claude` and sign in on first launch.

## Notes

### What each tool is for

| Tool | Needed for | If missing |
|---|---|---|
| `bun` | installing ccstatusline | the statusline doesn't render |
| `ccstatusline` | the statusline and the ccstatusline hooks | the statusline doesn't render |
| `rtk` | the `rtk hook claude` entry in `settings.json` | the hook command fails on every Bash call |
| `gh` | the statusline's Git PR segment (`git-review`) | the segment stays blank |

`bun` matters most. The rtk hook is a native binary command, so it needs
neither bash nor jq, but it does need `rtk` on PATH. On a machine without rtk,
run `rtk init -g --uninstall` or remove the `rtk hook claude` entry from
`settings.json`.

### settings.json

- `settings.json` registers `rtk hook claude`, the native hook from
  [rtk](https://github.com/rtk-ai/rtk), which rewrites shell commands to cut
  token use. The command resolves from PATH, so there are no hardcoded paths.
  `rtk init -g` writes the same line. Nothing else about rtk is stored here.
- **Plugins and skills are not tracked here.** The repo's `settings.json` has
  no `enabledPlugins` or `extraKnownMarketplaces`, so a fresh machine starts
  with none. Claude Code writes those keys into the live file as you enable
  plugins, so `./status.sh` reports `settings.json` as `seeded` (its manifest
  mode). That is expected.
- Orca ([`shared/orca`](../orca/SETUP.md)) adds its own hook entries to the
  live file. They are per machine too.
- `settings.json` sets `"permissions": {"defaultMode": "auto"}`. Confirm that
  you want this before you copy it to a shared or production machine.
- **Claude Code rewrites `settings.json`** when you change things with
  `/config`. Those edits land only in the live file. `./status.sh` only says
  `seeded`, so use the `diff` in Verify to see the drift. Copy the file back
  into the repo when you want to keep the edits. Leave out the per-machine plugin keys and Orca's hooks when you do.

## Verify

Run from the repo root:

```bash
diff shared/claude/settings.json ~/.claude/settings.json   # only per-machine keys and edits made in /config
jq -e . ~/.claude/settings.json >/dev/null && echo "valid json"
rtk init --show
```

`rtk init --show` reports the hook, `RTK.md`, and the `@RTK.md` reference in
`~/.claude/CLAUDE.md` as `[ok]`.

In Claude Code, `/status` shows the loaded config, and the statusline shows
four lines.
