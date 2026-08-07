# Setting up a machine for Roynul

You are reading this because you were asked to set up a machine using this repo.
It holds real config files plus per-package instructions for reproducing them on
a platform they weren't originally written for.

There is no install script. That is deliberate. Roughly half of what's here
cannot be symlinked into place correctly without knowing which OS you're on and
what the local package manager calls things — Ghostty's config path differs
between macOS and Linux, and `bat` is called `batcat` on Debian. Those are
judgement calls. That's your job.

## Before you start

1. **Ask what this machine is for.** A headless Linux dev box needs `shell`,
   `git`, and `claude`. A desktop wants `ghostty` and fonts too. Nobody needs
   `macos/` unless they're on a Mac. Don't install all of it reflexively.
2. **Detect the platform** — `uname -s`, and on Linux the distro and package
   manager. Every SETUP.md is written in terms of macOS/Homebrew vs
   Debian/Ubuntu/apt. Other distros: translate, don't guess at paths.

   **Check for WSL specifically** — `grep -qi microsoft /proc/version`. WSL is
   Ubuntu for package-manager purposes but differs in ways that will make you
   report success on things that didn't work. Read the WSL section below before
   touching anything.
3. **Never clobber silently.** If a destination file exists and isn't already a
   symlink into this repo, copy it somewhere safe first and say what you did.

## Preferences worth knowing

These explain *why* the configs look the way they do. Honour them when you hit a
decision this repo doesn't cover.

- **zsh, always.** With oh-my-zsh and powerlevel10k. Not bash, not fish, not starship.
- **Modern CLI replacements are load-bearing.** `cat`→bat, `ls`/`ll`/`tree`→eza,
  find→fd, grep→ripgrep, cd→zoxide, fzf everywhere. `shell/zshrc` only aliases
  over `cat` and `ls` when the replacement actually exists, so a partial install
  degrades instead of breaking — but a machine without these feels wrong. Install them.
- **Nerd Font or the prompt is broken.** JetBrainsMono Nerd Font specifically.
  p10k and eza both render glyphs that plain fonts don't have.
- **bun over npm/npx/pnpm** for anything JS. `bunx`, not `npx`.
- **Terminal is Ghostty.** kitty config is here as a fallback for machines where
  Ghostty won't build. iTerm2 is legacy, not in this repo.
- **Claude Code is the primary agent** and its config is the most important thing
  here. If you only get one package right, make it `claude`.

## Packages

| Package | What | macOS | Linux | WSL |
|---|---|:-:|:-:|:-:|
| `shell` | zsh, p10k, aliases, PATH | ✅ | ✅ | ✅ |
| `git` | gitconfig | ✅ | ✅ | ✅ |
| `claude` | Claude Code config, hooks, skills | ✅ | ✅ | ✅ |
| `ccstatusline` | Claude Code statusline | ✅ | ✅ | ✅ |
| `ghostty` | terminal — **config path differs by OS** | ✅ | ✅ | ❌ |
| `kitty` | terminal, fallback | ✅ | ✅ | ❌ |
| `nvim` | LazyVim | ✅ | ✅ | ✅ |
| `neofetch` | fetch output | ✅ | ⚠️ | ⚠️ |
| `ai-tools` | codex, gemini, cursor, factory, mastra, claude-mem | ✅ | ✅ | ✅ |
| `vscode` / `cursor` | editor settings, keybindings | ✅ | ✅ | ⚠️ Windows side |
| `windows-terminal` | terminal profile | ❌ | ❌ | ⚠️ not captured |
| `macos` | yabai, sketchybar, borders, linearmouse | ✅ | ❌ skip | ❌ skip |
| `Brewfile` | full macOS package manifest | ✅ | 📖 read as a source list | 📖 same |

Each package has a `SETUP.md`. Read it. They all follow the same shape: what it
is, dependencies per platform, where the files go, platform gotchas, how to verify.

## WSL

Detect with `grep -qi microsoft /proc/version`.

For apt and everything under `$HOME`, treat WSL as Ubuntu — the `shell`, `git`,
`claude`, `ccstatusline`, `nvim`, and `ai-tools` packages all install normally.

What's different is that **the terminal and the GUI editor are Windows
processes**, not Linux ones. Anything to do with rendering — fonts, terminal
colours, window settings — is configured on the Windows side and is invisible
from inside WSL. This is the failure mode to watch for: you run the documented
Linux steps, every command exits 0, and the result still looks wrong, because
the thing you configured isn't the thing doing the rendering.

**Fonts do not work the way `shell/SETUP.md` describes.** Installing a Nerd Font
into `~/.local/share/fonts` and running `fc-cache` inside WSL accomplishes
nothing — Windows Terminal renders with fonts installed on Windows. The font
must be installed on the Windows host and selected in the terminal profile.
That's a manual step outside your reach. Surface it, don't attempt it, and don't
report the prompt as working until the user confirms the glyphs render.

**Skip `ghostty` and `kitty` entirely.** There's no GUI terminal inside WSL.
The equivalent config is the Windows Terminal profile — see
`windows-terminal/SETUP.md`.

**`vscode` and `cursor` are inverted.** With the Remote-WSL extension the editor
runs on Windows; WSL only holds `~/.vscode-server/`, which is machine state, not
config. Linking `vscode/settings.json` inside WSL has no effect. The real
destination is on the Windows filesystem:

```
/mnt/c/Users/<WindowsUser>/AppData/Roaming/Code/User/settings.json
```

Writing across the `/mnt/c` boundary works but is a decision, not a default —
it edits the user's Windows install, and symlinks from Windows into WSL are
unreliable. Ask before doing it; copying is safer than linking here.

**`rtk` has no apt package**, so the RTK hook in `claude` stays inert unless
Rust is installed (`cargo install rtk`). The hook detects this and exits
cleanly, so nothing breaks — but say so rather than leaving it silently
disabled.

**Set the login shell**: `chsh -s $(which zsh)`. Also check that the Windows
Terminal profile launches the WSL distro directly; if it invokes `bash`, none of
the zsh config loads and the box will look unconfigured.

## Order

`shell` and `git` first — everything else assumes a working shell. Then the
terminal, then Claude, then the rest. Restart the shell (`exec zsh`) before
verifying anything shell-dependent.

## Linking

Symlink files back to this repo rather than copying, so edits on the machine stay
visible to `git status`:

```bash
ln -sfn ~/dotfiles/shell/zshrc ~/.zshrc
```

Two exceptions, both noted in their SETUP.md: Ghostty's `auto/theme.ghostty` is
regenerated by the app, and `nvim/lazy-lock.json` is updated by the plugin
manager. Copy those, don't link them.

`stow` works for the simple packages if it's installed, but the repo is not laid
out as stow packages — the paths here don't mirror `$HOME`. Prefer explicit `ln`.

## Not in this repo

Deliberately excluded, because they're credentials: SSH keys, `~/.claude.json`,
`~/.codex/auth.json`, `~/.gemini/oauth_creds.json`, Stripe/arbor/agentuity API
keys, and every `*_history` / cache / `.zcompdump` file.

After setup, these need doing by hand — surface them as a checklist rather than
attempting them:

- `gh auth login`
- `claude` — sign in on first run
- SSH keys: generate new ones, don't copy old ones between machines

## When you're done

Report what you installed, what you skipped and why, what you backed up and
where, and the manual auth steps still outstanding. If something in a SETUP.md
turned out to be wrong or stale, say so — the file should be fixed.
