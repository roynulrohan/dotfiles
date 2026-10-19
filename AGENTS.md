# AGENTS.md

Roynul's dotfiles for two machines: a CachyOS gaming PC (Hyprland, Noctalia)
and a MacBook Pro (AeroSpace, SketchyBar). Plain config files in package
folders, copied into place. There is no install script and nothing is
symlinked. Read "Rules" before you change anything.

## Where things are

| Path | What |
|---|---|
| `shared/`, `linux/`, `mac/` | Packages. Each has a `SETUP.md` with the same sections: what it is, Files, Install, Notes, Verify. |
| [`manifest.tsv`](manifest.tsv) | Every repo file and its destination. Its header explains the modes and the `needs` column. |
| [`status.sh`](status.sh) | Compares the live files with the repo. Read-only. |
| [`check.sh`](check.sh) | Syntax, manifest, coverage, links and secrets. Run it before every commit. |
| [`personal/preferences.md`](personal/preferences.md) | What the owner wants, independent of tools. Read it before you change how something works or replace a tool. |
| [`personal/machines/`](personal/machines/gaming-pc.md) | One file per machine: hardware, the packages it takes in order, its own extras. `desk.md` is the shared desk. |
| [`INSTALL.md`](INSTALL.md) | The guide for other people who want this setup. |
| [`README.md`](README.md) | The owner's showcase. |
| [`CREDITS.md`](CREDITS.md) | Inspirations, and work included from others. |
| [`WRITING.md`](WRITING.md) | What goes in the repo, where each fact lives, and how to write it. |

## Setting up one of the owner's machines

1. Ask which machine it is.
2. Follow its file in [`personal/machines/`](personal/machines/gaming-pc.md),
   in order. Check each step with `./status.sh` and the package's Verify
   section before the next.
3. Never overwrite silently. If a destination exists and differs, show the
   diff or back the file up before you copy over it.
4. When you're done, report what you copied, what you skipped and why, and what
   you backed up. Give the owner the open items of "My extras" as a checklist.
   If a `SETUP.md` was wrong, fix it.

## Rules

These apply to every edit, by any agent.

1. **Never commit a credential.** Some configs are committed *because* their
   key fields are empty. If a machine fills one in, don't copy that key back.
2. **Copy, don't symlink.** Machines keep normal files in normal places. This
   repo is the source to copy from and the place to copy changes back to.
   Use the `manifest.tsv` modes: `seed` for a file the app rewrites, the
   `needs` column for an app a machine may not have, `manual` for a file that
   is run or applied in place, and a `gone` row when you retire a destination.
3. **Own what you adopt.** Config taken from a framework or another person's
   dotfiles becomes a copy in this repo, never a dependency on their live tree.
   Other files a tool drops into a folder this repo owns stay out of
   `manifest.tsv`. When you copy someone else's work in, credit it in
   [`CREDITS.md`](CREDITS.md).
4. **Keep shared configs portable.** No hardcoded home paths. Guard OS-specific
   parts so the other OS skips them, and say so in the package's `SETUP.md`.
   The Linux side is the reference; never change it to match the Mac.
5. **Tag every commit with its device.** End the subject with the device tag
   in parentheses, so `git log --oneline` shows which machine each change came
   from:

       kitty: abstract socket on Linux, path socket only on macOS (cachy-os)

   | Tag | Machine | Hostname |
   |---|---|---|
   | `cachy-os` | [gaming PC](personal/machines/gaming-pc.md) | `cachyos` |
   | `macbook-pro` | [MacBook Pro](personal/machines/macbook-pro.md) | TODO: ask the owner |

   A new machine picks a short kebab-case tag, adds a row here and a file in
   `personal/machines/` in its first commit. The oldest commits have no tag.
6. **Explain changes in the commit message.** The body says why, and which
   alternatives were tried or rejected. The commit history is the record of
   how the setup got here; the docs describe it as it is now.
7. **Read the diff before you copy a live file back.** Copy back only the lines
   that belong in the repo. Lines for one machine only, such as an installer's
   PATH addition, go in that file's local slot, which stays out of the repo:
   `~/.config/fish/local.fish`, `~/.gitconfig.local` or kitty's `local.conf`.
8. **Run `./check.sh` after `git add` and before every commit.** Commit only
   when it prints no `FAIL` line.
9. **Write by [`WRITING.md`](WRITING.md).** It says what goes in the repo,
   which file is the home of each fact, who each doc is for, and how to
   write. Read it before you write a doc, a comment or a commit body.
10. **Record lasting preferences.** When the owner states a preference that the
    config can't show (a ranking, a convention across tools, a hard no), add it
    to [`personal/preferences.md`](personal/preferences.md), worded without
    naming a tool where possible.
11. **Write repo paths in docs as links**, relative to the doc, so readers can
    click through. A folder links to its `SETUP.md`.
