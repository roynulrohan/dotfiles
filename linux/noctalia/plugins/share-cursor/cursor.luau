-- Reads and sets Hyprland's cursor:no_hardware_cursors. 1 is always a
-- software cursor. 2 is Hyprland's default (Auto), a hardware cursor on this
-- PC. A Lua config rejects `hyprctl keyword`, so set goes through eval.

local M = {}

-- cb(true) when the software cursor is on, cb(false) when not, cb(nil) when
-- hyprctl doesn't answer.
function M.read(cb)
  noctalia.runAsync({ "hyprctl", "-j", "getoption", "cursor:no_hardware_cursors" }, function(result)
    local v = tonumber(string.match(result.stdout or "", '"int":%s*(%d+)'))
    if result.exitCode ~= 0 or v == nil then
      cb(nil)
      return
    end
    cb(v == 1)
  end)
end

-- Sets the cursor, then reads it back so cb gets the real state.
function M.set(on, cb)
  local code = string.format("hl.config({ cursor = { no_hardware_cursors = %d } })", on and 1 or 2)
  noctalia.runAsync({ "hyprctl", "eval", code }, function()
    M.read(cb)
  end)
end

return M
