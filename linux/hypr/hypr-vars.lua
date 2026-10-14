-- Colours from the scheme file, which Noctalia rewrites from the wallpaper palette
-- (template ~/.config/noctalia/templates/hypr-scheme.lua).
local scheme = require("scheme.current")

return {
    terminal = "kitty",
    fileExplorer = "dolphin",
    -- caelestia's config gives a lone tiled window a bigger outer gap (default 20).
    -- Keep it equal to HyprMod's general:gaps_out so single windows match.
    singleWindowGapsOut = 4,
    -- caelestia's defaults point at things this machine doesn't have: codium
    -- (VS Code is installed), suspend-then-hibernate (zram swap only, so it
    -- can't hibernate) and the sweet-cursors theme (not installed).
    editor = "code",
    sleepGestureCmd = "systemctl suspend",
    -- Volume keys and the keyboard's knob change volume by 1% per step (caelestia: 10).
    volumeStep = 1,
    cursorTheme = "breeze_cursors",
    -- No window shadows, as in HyDE's themes (caelestia's were large and faint).
    -- Blur stays caelestia's (8, 2 passes); HyDE's 6 with 3 passes was also liked.
    shadowEnabled = false,
    -- HyDE's window transparency: 90% focused, 75% unfocused (caelestia: 95% for all).
    windowOpacity = "0.90 0.75",
    -- HyDE-style borders: a two-colour 45° gradient, with unfocused windows keeping
    -- a visible, dimmer one (caelestia's unfocused border was almost invisible).
    -- (In Lua, a gradient is a table, as in HyDE's dynamic.lua.)
    activeWindowBorderColour = { colors = { "rgba(" .. scheme.primary .. "ff)", "rgba(" .. scheme.tertiary .. "ff)" }, angle = 45 },
    inactiveWindowBorderColour = { colors = { "rgba(" .. scheme.onSurfaceVariant .. "cc)", "rgba(" .. scheme.outlineVariant .. "cc)" }, angle = 45 },
    -- HyDE: blur behind pop-up workspaces (dimming is in hypr-user.lua).
    blurSpecialWs = true,
    -- No caelestia resize keys (Super+-/=, Super+Shift+-/=, Super+Alt+arrows:
    -- 10% of the window per press). Super+Shift+arrows in hypr-user.lua resizes.
    kbWindowDecreaseWidth  = {},
    kbWindowIncreaseWidth  = {},
    kbWindowDecreaseHeight = {},
    kbWindowIncreaseHeight = {},
}
