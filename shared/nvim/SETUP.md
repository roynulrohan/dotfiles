# Neovim

Neovim, from the LazyVim starter config (Apache-2.0, [`LICENSE`](LICENSE)). On top of LazyVim's defaults: One
Dark Pro (vivid) as the colorscheme, rounded float borders and statusline caps,
five LazyVim extras, and an autocmd that makes kitty opaque while Neovim runs
(see Notes).

## Files

| Repo | Destination |
|---|---|
| everything in this folder except `SETUP.md` | `~/.config/nvim/` |

Same path on both OSes. `manifest.tsv` copies the folder, and `./status.sh`
skips `SETUP.md` inside it.

`lazy-lock.json` drifts. lazy.nvim rewrites it on every `:Lazy update`, so
`./status.sh` then reports the folder as `differs`. The lockfile is committed
so the pins travel: copy it back when you want the new pins on the other
machine.

## Install

- CachyOS/Arch: `sudo pacman -S neovim git gcc tree-sitter-cli ripgrep fd fzf`
- macOS: `brew install neovim tree-sitter-cli ripgrep fd fzf`, and a C compiler
  from the Xcode Command Line Tools (`xcode-select --install`).

LazyVim's requirements (lazyvim.org): Neovim 0.11.2 or later, git,
`tree-sitter-cli` and a C compiler for nvim-treesitter, a v3 Nerd Font for the
icons, and `ripgrep`, `fd` and `fzf` for the pickers. `lazygit` is optional.

After copying, start `nvim` once. lazy.nvim installs the plugins at the commits
pinned in `lazy-lock.json` and builds the treesitter parsers. Expect a minute of
downloading and compiling.

## Notes

### Terminal background

In a transparent kitty window, a colorscheme that paints its own background
shows as an opaque block, with the window padding as a seam around it. Two
parts fix it:

- **Colour:** `bg.nvim` gives the terminal Neovim's background and cursor
  colours while Neovim runs. This part works in Ghostty too.
- **Opacity:** an autocmd in
  [`lua/config/autocmds.lua`](lua/config/autocmds.lua) makes the kitty window
  opaque while Neovim runs, then restores the opacity that kitty reported. It
  needs kitty's remote control ([`shared/kitty`](../kitty/SETUP.md)), and it
  does nothing when `KITTY_LISTEN_ON` is unset.

The comments in `autocmds.lua` explain why kitty needs this.

### Other files

- The config is portable: no paths and no OS checks.
- `.neoconf.json` and `stylua.toml` come from the LazyVim starter.

## Verify

```bash
nvim --version | head -1   # NVIM v0.11.2 or later
./status.sh | grep nvim    # ok; differs after a :Lazy update (lazy-lock.json)
```

Then open `nvim`: the dashboard renders with icons, and `:checkhealth lazyvim`
reports no errors.
