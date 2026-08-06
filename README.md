# dotfiles

Personal config, symlinked into place. Currently covers Claude Code and ccstatusline.

## Fresh machine

```bash
curl -fsSL https://bun.sh/install | bash   # required — statusline + hooks use bunx
gh repo clone roynulrohan/dotfiles ~/dotfiles
~/dotfiles/install.sh
```

Then restart Claude Code. `install.sh --dry-run` shows what it would touch first.

## Layout

```
claude/
  CLAUDE.md              global instructions  ->  ~/.claude/CLAUDE.md
  RTK.md                 rtk reference, @-imported by CLAUDE.md
  settings.json          env, hooks, statusline, plugins
  hooks/rtk-rewrite.sh   PreToolUse:Bash hook, rewrites commands through rtk
  skills/gh/             custom gh skill
ccstatusline/
  settings.json          statusline layout  ->  ~/.config/ccstatusline/settings.json
lib/links.sh             the source::destination map both scripts read
install.sh               create the symlinks
sync.sh                  check them / recover a clobbered one
```

To track another file, add one line to `lib/links.sh` and re-run `install.sh`.

## How it stays in sync

The repo holds the real files; the locations above are symlinks pointing back
here. Edit either side — it's the same file, and `git -C ~/dotfiles status`
shows the change immediately. Commit and push when you want it on the other
machine, `git pull` to receive it. No copy step.

One failure mode to know about: an app that saves by writing a temp file and
renaming it over the target replaces the symlink with a regular file, and the
repo silently stops seeing your edits. `./sync.sh` detects that (`DETACHED`),
and `./sync.sh --adopt` copies the file back into the repo and restores the
link, keeping the edit.

## Dependencies

| Tool | Needed for | Without it |
|---|---|---|
| `bun` | statusline, ccstatusline hooks | statusline doesn't render |
| `jq` | RTK hook | hook warns once, passes commands through |
| `rtk` | RTK hook | same |
| `gh` | `git-pr` statusline segment | segment stays blank |

`install.sh` reports which are present.

Plugins listed in `settings.json` (`enabledPlugins` / `extraKnownMarketplaces`)
are fetched by Claude Code itself on first run — nothing to install by hand.
