# nvim

LazyVim starter config, essentially stock — the customisation files
(`lua/config/*.lua`, `lua/plugins/example.lua`) are still the defaults.

## Files

| Repo | Destination |
|---|---|
| everything in this directory except `SETUP.md` | `~/.config/nvim/` |

Same path on both platforms. Symlink the whole directory:
`ln -sfn ~/dotfiles/nvim ~/.config/nvim`.

**One exception: `lazy-lock.json`.** lazy.nvim rewrites it whenever plugins are
updated. With the directory symlinked that's fine and arguably desirable — the
lockfile stays pinned across machines, which is the point of committing it. Just
expect `git status` to show it after any `:Lazy update`.

## Install

- macOS: `brew install neovim`
- Debian/Ubuntu: `apt install neovim` is usually too old for LazyVim (needs
  ≥0.9). Prefer the official appimage or `snap install nvim --classic`.

Recommended extras LazyVim uses if present: `ripgrep` and `fd` (both already in
`shell/SETUP.md`), plus a C compiler and `git` for treesitter builds.

## Platform notes

Fully portable. Plugins are fetched by lazy.nvim on first launch — expect a
minute of downloading and treesitter compilation.

`.neoconf.json` and `stylua.toml` are LazyVim scaffolding; `README.md` and
`LICENSE` come from the starter template and can be ignored.

## Verify

```bash
nvim --headless "+Lazy! sync" +qa      # installs plugins, exits
nvim --headless "+checkhealth" +qa
```

Then open `nvim` — dashboard should render with icons (Nerd Font required).
