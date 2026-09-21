-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Cover the terminal's transparency while Neovim is up.
--
-- kitty applies background_opacity only to cells whose colour matches the
-- default background, so a colorscheme that paints its own background renders
-- opaque and gets no share of window_padding_width -- an opaque block inside a
-- rounded translucent window, with the padding showing as a seam. bg.nvim fixes
-- the colour half by handing the terminal our background over OSC. This covers
-- the rest: the window goes opaque while Neovim runs and gets its own opacity
-- back on exit. kitty has no setting for this and upstream declined to add one.

-- Read at load time: vim.system's on_exit runs in a fast event context, where
-- reading vim.env raises E5560.
local socket = vim.env.KITTY_LISTEN_ON

if socket then
  local group = vim.api.nvim_create_augroup("terminal_opacity", { clear = true })

  -- Read from the running terminal rather than hardcoded, so the Mac (glass) and
  -- the Linux box each get their own value back.
  local shell_opacity = nil

  local function kitty(args, on_exit)
    local cmd = { "kitten", "@", "--to", socket }
    vim.list_extend(cmd, args)
    return vim.system(cmd, { text = true }, on_exit)
  end

  vim.api.nvim_create_autocmd({ "UIEnter", "VimResume" }, {
    group = group,
    desc = "Make the terminal opaque for Neovim",
    callback = function()
      if shell_opacity then
        kitty({ "set-background-opacity", "1.0" })
        return
      end
      -- Learn the terminal's opacity first, so the restore has a value.
      kitty({ "ls" }, function(res)
        if res.code == 0 then
          local ok, windows = pcall(vim.json.decode, res.stdout)
          if ok and windows and windows[1] then
            shell_opacity = tostring(windows[1].background_opacity)
          end
        end
        kitty({ "set-background-opacity", "1.0" })
      end)
    end,
  })

  vim.api.nvim_create_autocmd({ "VimLeavePre", "VimSuspend" }, {
    group = group,
    desc = "Give the terminal its opacity back",
    callback = function()
      if not shell_opacity then
        return
      end
      local proc = kitty({ "set-background-opacity", shell_opacity })
      if proc then
        proc:wait(2000)
      end
    end,
  })
end

