# nvim

LazyVim starter config. On top of the defaults: One Dark Pro as the colorscheme,
rounded float borders and statusline caps, five LazyVim extras, and an autocmd
that hands the terminal Neovim's background colour (see below).

## Files

| Repo | Destination |
|---|---|
| everything in this directory except `SETUP.md` | `~/.config/nvim/` |

Same path on both platforms; `manifest.tsv` copies the directory, like every
other package here.

**One exception: `lazy-lock.json`.** lazy.nvim rewrites it whenever plugins are
updated, so the live copy drifts from the repo after any `:Lazy update`.
`status.sh` reports that drift like any other, which is the point of committing
the lockfile — copy it back when you want the new pins on the other machine.

## Install

- CachyOS: `pacman -S neovim`
- macOS: `brew install neovim`

Recommended extras LazyVim uses if present: `ripgrep` and `fd` (both already in
`linux/packages.md` and `mac/Brewfile`), plus a C compiler and `git` for
treesitter builds.

## Terminal background

This matters on a transparent terminal. kitty applies `background_opacity` only
to cells whose colour equals the current default background, so a colorscheme
that paints its own background gets no transparency and no share of
`window_padding_width`. The result is an opaque, square-cornered block floating
inside the rounded translucent window, with the padding showing as a seam.

Two halves fix it:

- **Colour** — `bg.nvim` hands the terminal Neovim's background and cursor over
  escape sequences and restores them on exit, so the padding and the rounded
  corner take Neovim's colour. Standard escapes, so it works in Ghostty too.
- **Opacity** — an autocmd in `lua/config/autocmds.lua` makes the window opaque
  while Neovim runs, then gives the terminal its own opacity back. It reads that
  value from the running kitty over remote control instead of hardcoding it, so
  the Mac (glass) and the Linux box each get their own. The whole block is
  skipped when `KITTY_LISTEN_ON` is unset.

kitty has no setting that colours its padding and upstream has declined to add
one, so the opacity half has no off-the-shelf equivalent.

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
