# dotfiles

Read `AGENTS.md` in this directory before doing anything with this repo — it
covers what's here, the preferences behind it, and how to set up a machine.

Two rules that apply to any edit in this repo:

1. **Never commit a credential.** Several configs here are committed *because*
   their key fields are empty (`ai-tools/claude-mem/settings.json`,
   `ai-tools/cursor/mcp.json`). If a key gets filled in on a machine, that file
   must stop being a symlink into this repo.
2. **Keep configs portable.** No hardcoded `/Users/roynulrohan` — use `$HOME`.
   Guard anything platform-specific with an existence check so the other OS
   skips it silently rather than erroring. Then document it in the package's
   `SETUP.md`.
