-- Atom's One Dark Pro, replacing LazyVim's default tokyonight.

return {
  {
    "olimorris/onedarkpro.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      options = {
        cursorline = true,
        -- kitty keeps the glass background for the shell; nvim is a solid panel
        -- inside it, which is the readable combination.
        transparency = false,
        terminal_colors = true,
        -- Clears the bar behind lualine so the section groups read as separate
        -- pills instead of one continuous strip.
        lualine_transparency = true,
        highlight_inactive_windows = false,
      },
      styles = {
        comments = "italic",
        keywords = "italic",
        conditionals = "italic",
        virtual_text = "italic",
      },
    },
  },

  -- LazyVim calls vim.cmd.colorscheme() with this string on startup.
  { "LazyVim/LazyVim", opts = { colorscheme = "onedark_vivid" } },

  -- Hands the terminal Neovim's background and cursor colours over escape
  -- sequences, and restores them on exit. Without it the terminal's padding
  -- stays its own colour and shows as a seam around Neovim.
  { "typicode/bg.nvim", lazy = false },
}
