-- User overrides loaded after caelestia's base config and before HyprMod's file.
-- Only things HyprMod cannot represent go here.

-- HyDE-style resize on Super+Shift+arrows (relative pixels). caelestia binds
-- these keys to "move window"; unbind first or both fire.
for _, dir in ipairs({ "Left", "Right", "Up", "Down" }) do
    hl.unbind("SUPER + SHIFT + " .. dir)
end
hl.bind("SUPER + SHIFT + Left",  hl.dsp.window.resize({ x = -30, y = 0, relative = true }), { repeating = true })
hl.bind("SUPER + SHIFT + Right", hl.dsp.window.resize({ x = 30,  y = 0, relative = true }), { repeating = true })
hl.bind("SUPER + SHIFT + Up",    hl.dsp.window.resize({ x = 0, y = -30, relative = true }), { repeating = true })
hl.bind("SUPER + SHIFT + Down",  hl.dsp.window.resize({ x = 0, y = 30,  relative = true }), { repeating = true })

-- imv zooms by 1.04^n per scroll event, where n is the raw scroll distance
-- (about 15 per wheel notch), so one notch zoomed about 80%. A 0.2 scroll factor
-- makes it about 12%. Keep it at or above 1/15: imv truncates each event to a
-- whole number, so a smaller factor stops wheel zoom. HyprMod has no
-- scroll_mouse action, so this rule lives here.
hl.window_rule({ match = { class = "imv" }, scroll_mouse = 0.2 })
