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

-- Pass high-resolution wheel events through with their real direction. With
-- emulation on (the default, 1), Hyprland regroups them into whole notches and
-- sends zero-length scroll events while a notch fills up; swayimg reads a zero
-- length as "scroll up", so Ctrl+wheel only zoomed in. Apps that read the
-- high-resolution value (value120) are unaffected. HyprMod doesn't model this
-- option, so it lives here.
hl.config({ input = { emulate_discrete_scroll = 0 } })
