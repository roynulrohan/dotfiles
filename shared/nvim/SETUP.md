# nvim

Neovim, from the LazyVim starter config. On top of LazyVim's defaults: One
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
`./status.sh` then reports the folder as `differs`. That is the point of
committing the lockfile: copy it back when you want the new pins on the other
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

This matters on a transparent terminal. kitty applies `background_opacity` only
to cells whose colour equals the current default background. So a colorscheme
that paints its own background gets no transparency and no share of
`window_padding_width`. The result is an opaque, square-cornered block inside
the rounded translucent window, with the padding showing as a seam.

Two parts fix it:

- **Colour:** `bg.nvim` hands the terminal Neovim's background and cursor
  colours over escape sequences, and restores them on exit. So the padding and
  the rounded corner take Neovim's colour. These are standard escapes, so this
  part works in Ghostty too.
- **Opacity:** an autocmd in
  [`lua/config/autocmds.lua`](lua/config/autocmds.lua) makes the window opaque
  while Neovim runs, then gives the terminal its own opacity back. It reads that
  value from the running kitty over remote control instead of hardcoding it, so
  each machine gets its own value back. The whole block is skipped when
  `KITTY_LISTEN_ON` is unset.

kitty has no setting that colours its padding, and upstream has declined to add
one, so the opacity part has no off-the-shelf equivalent.

### Other files

- The config is fully portable: no paths and no OS checks.
- `.neoconf.json`, `stylua.toml` and
  [`lua/plugins/example.lua`](lua/plugins/example.lua) come from the LazyVim
  starter. `example.lua` returns an empty spec, so it loads nothing.

## Verify

```bash
nvim --version | head -1   # NVIM v0.11.2 or later
./status.sh | grep nvim    # ok; differs after a :Lazy update (lazy-lock.json)
```

Then open `nvim`: the dashboard renders with icons, and `:checkhealth lazyvim`
reports no errors.
