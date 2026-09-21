-- Look and feel on top of LazyVim's defaults.

return {
  -- Rounded statusline caps in place of lualine's default powerline wedges.
  -- LazyVim's own sections (mode, branch, diagnostics, path, git diff) are left
  -- alone; only the separators change. The glyphs are Nerd Font private-use
  -- codepoints, drawn here by JetBrainsMono NF.
  {
    "nvim-lualine/lualine.nvim",
    opts = {
      options = {
        section_separators = { left = "", right = "" },
        component_separators = { left = "", right = "" },
      },
    },
  },

  -- Fade everything outside the block under the cursor. LazyVim already turns on
  -- indent guides, smooth scroll, notifier and the dashboard; dim is the one
  -- visual module it leaves off. Toggle zen mode with <leader>uz.
  {
    "folke/snacks.nvim",
    opts = {
      dim = { enabled = true },
    },
  },
}
