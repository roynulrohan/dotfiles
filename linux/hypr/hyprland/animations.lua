-- Animation preset, picked by name from ~/.config/hypr/animations/:
-- HyDE's presets (HyDE-Project/HyDE, Configs/.local/share/hypr/lua/animations)
-- and caelestia's original (caelestia.lua).
local preset = "caelestia"

-- HyDE's presets multiply their speeds by this; 1 = as designed.
_G.hyde = _G.hyde or {}
hyde.config = hyde.config or { anim = { duration_scale = 1 } }

require("animations." .. preset)
