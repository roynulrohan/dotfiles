-- Animation preset, picked by name from ~/.config/hypr/animations/:
-- HyDE's presets (HyDE-Project/HyDE, Configs/.local/share/hypr/lua/animations)
-- and caelestia's original (caelestia.lua).
local preset = "caelestia"

-- HyDE's presets multiply their speeds by this; 1 = as designed.
_G.hyde = _G.hyde or {}
hyde.config = hyde.config or { anim = { duration_scale = 1 } }

require("animations." .. preset)

-- Our change on top of the preset: pop-up (special) workspaces drop in from
-- the top and slide back up on close (caelestia's rise from the bottom and
-- sink back down). The word after the style fixes the direction; open and
-- close are separate animations, so each gets its own.
hl.animation({ leaf = "specialWorkspaceIn", enabled = true, speed = 4, bezier = "specialWorkSwitch", style = "slidefadevert top 15%" })
hl.animation({ leaf = "specialWorkspaceOut", enabled = true, speed = 4, bezier = "specialWorkSwitch", style = "slidefadevert bottom 15%" })
