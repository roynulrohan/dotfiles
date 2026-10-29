-- The Share Cursor button. A click switches the software cursor on or off.

local cursor = require("./cursor.luau")

local function render(on)
  shortcut.setLabel("Share Cursor")
  shortcut.setIcon("pointer", "pointer-off")
  shortcut.setActive(on == true)
end

render(noctalia.state.get("on"))
noctalia.state.watch("on", render)

function onClick()
  cursor.set(not noctalia.state.get("on"), function(on)
    if on ~= nil then
      noctalia.state.set("on", on)
    end
  end)
end
