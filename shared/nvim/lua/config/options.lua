-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Rounded borders for every float that does not set its own. Native in Neovim
-- 0.11 and left unset by LazyVim, so it is ours to define: LSP hover, signature
-- help, diagnostics, :Lazy and :Mason all pick it up.
vim.o.winborder = "rounded"
