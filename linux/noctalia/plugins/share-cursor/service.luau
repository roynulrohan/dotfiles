-- Publishes the cursor state as "on" for the button. A Hyprland config reload
-- puts the hardware cursor back, so while the state is on, read it again
-- every 5 seconds.

local cursor = require("./cursor.luau")

local function publish(on)
  if on ~= nil then
    noctalia.state.set("on", on)
  end
end

cursor.read(publish)

function update()
  noctalia.setUpdateInterval(5000)
  if noctalia.state.get("on") then
    cursor.read(publish)
  end
end
