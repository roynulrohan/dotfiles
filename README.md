# dotfiles

Config files plus instructions for reproducing them on a machine they weren't
written for.

There's no install script. Each package has a `SETUP.md` covering dependencies
per platform, where the files go, what breaks on the other OS, and how to check
it worked. `AGENTS.md` is the entry point an agent reads first.

## Fresh machine

Point an agent at it:

> Clone `roynulrohan/dotfiles`, read `AGENTS.md`, and set up this box.
> It's a headless Ubuntu dev server — shell and Claude Code only.

Or do it yourself: read `AGENTS.md`, then the `SETUP.md` of whatever you want.

## Bootstrap

The repo is private and the agent isn't installed yet, so a few steps come first:

```bash
sudo apt update && sudo apt install -y git curl zsh gh   # or brew on macOS
gh auth login                                            # private repo — needed to clone
gh repo clone roynulrohan/dotfiles ~/dotfiles
curl -fsSL https://claude.ai/install.sh | bash           # lands in ~/.local/bin
claude                                                   # sign in
cd ~/dotfiles && claude
```

Then tell it what the machine is. On WSL, say so explicitly — `AGENTS.md` has a
section for it, and the differences are the kind that fail silently.

## Packages

| | | macOS | Linux | WSL |
|---|---|:-:|:-:|:-:|
| `shell` | zsh, oh-my-zsh, p10k, aliases, PATH | ✅ | ✅ | ✅ |
| `git` | gitconfig | ✅ | ✅ | ✅ |
| `claude` | Claude Code — instructions, settings, hooks, skills | ✅ | ✅ | ✅ |
| `ccstatusline` | Claude Code statusline | ✅ | ✅ | ✅ |
| `ghostty` | primary terminal | ✅ | ✅ | ❌ |
| `kitty` | fallback terminal | ✅ | ✅ | ❌ |
| `nvim` | LazyVim | ✅ | ✅ | ✅ |
| `neofetch` | fetch | ✅ | ⚠️ unmaintained | ⚠️ |
| `ai-tools` | codex, gemini, cursor, factory, mastra, claude-mem | ✅ | ✅ | ✅ |
| `vscode` `cursor` | editor settings, keybindings | ✅ | ✅ | ⚠️ Windows side |
| `windows-terminal` | terminal profile | ❌ | ❌ | ⚠️ not captured |
| `macos` | yabai, sketchybar, borders, linearmouse | ✅ | ❌ | ❌ |
| `Brewfile` | 11 taps · 47 formulae · 11 casks · 5 MAS · 112 VS Code extensions | ✅ | 📖 source list | 📖 |

On WSL the terminal and GUI editor are Windows processes — fonts, terminal
config, and VS Code settings all live on the host and are invisible from inside
the distro. That's the one thing worth knowing before starting.

## How it stays current

The files here are the real ones — the paths on this Mac are symlinks pointing
back into the repo. Edit either side, `git status` sees it.

The failure mode: an app that saves config by writing a temp file and renaming it
over the target replaces the symlink with a regular file, and the repo quietly
stops seeing your edits. Claude Code, VS Code, and Cursor can all do this. To
check everything at once:

```bash
find ~/.zshrc ~/.gitconfig ~/.claude/settings.json \
     ~/.config/ccstatusline/settings.json ~/.config/nvim \
     -maxdepth 0 ! -type l 2>/dev/null
```

Anything it prints has detached. Copy it back into the repo and relink.

## Not in here

Credentials, by design — SSH keys, `~/.claude.json`, `~/.codex/auth.json`,
Gemini OAuth, Stripe/arbor/agentuity keys. Plus shell history, caches, and
`.zcompdump*`. `.gitignore` blocks the obvious filenames as a backstop, but it's
not a substitute for checking before you commit.

Manual after any fresh setup: `gh auth login`, sign into Claude Code, generate
new SSH keys.
