# MacBook Pro

Commit tag `macbook-pro`. It connects to the [desk](desk.md) through the dock.
The Mac setup follows [`preferences.md`](../preferences.md) and adapts the
shared configs; it never changes the Linux side.

## Hardware

| Part | Model |
|---|---|
| Model | MacBook Pro 16" (2023), Apple M3 Pro |
| RAM | 18 GB |
| Storage | 512 GB SSD |

## Packages

In this order. Each package's `SETUP.md` has the steps and a Verify section.

1. Base: Homebrew, then `brew bundle --file mac/Brewfile`
   ([`mac/Brewfile`](../../mac/Brewfile)).
2. Shell and git: [`shared/fish`](../../shared/fish/SETUP.md),
   [`mac/fish`](../../mac/fish/SETUP.md), [`shared/git`](../../shared/git/SETUP.md).
3. Terminal: [`shared/kitty`](../../shared/kitty/SETUP.md) with
   [`mac/kitty`](../../mac/kitty/SETUP.md), and [`shared/ghostty`](../../shared/ghostty/SETUP.md).
4. Prompt and greeting: [`shared/starship`](../../shared/starship/SETUP.md),
   [`shared/fastfetch`](../../shared/fastfetch/SETUP.md).
5. Coding agents: [`shared/agents`](../../shared/agents/SETUP.md),
   [`shared/claude`](../../shared/claude/SETUP.md),
   [`shared/ccstatusline`](../../shared/ccstatusline/SETUP.md).
6. Desktop: [`mac/wm`](../../mac/wm/SETUP.md), following its numbered steps.
7. The rest: [`shared/nvim`](../../shared/nvim/SETUP.md),
   [`shared/vscode`](../../shared/vscode/SETUP.md),
   [`shared/cursor`](../../shared/cursor/SETUP.md),
   [`shared/orca`](../../shared/orca/SETUP.md).

## My extras

- [ ] Sign in: `gh auth login` with a new SSH key, register the key for commit
      signing, then Claude Code and Orca.
- [ ] Restore the greeting's logo images to `~/.config/fastfetch/logo/`.
