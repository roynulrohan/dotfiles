-- Colours from the scheme file, which Noctalia rewrites from the wallpaper palette
-- (template ~/.config/noctalia/templates/hypr-scheme.lua).
local scheme = require("scheme.current")

return {
    terminal = "kitty",
    fileExplorer = "dolphin",
    -- The outer gap of a lone tiled window (rules.lua). Keep it equal to
    -- HyprMod's general:gaps_out.
    singleWindowGapsOut = 4,
    editor = "code",
    -- Plain suspend: suspend-then-hibernate can't work with zram swap only.
    sleepGestureCmd = "systemctl suspend",
    -- Volume keys and the keyboard's knob change volume by 1% per step.
    volumeStep = 1,
    -- Keep equal to XCURSOR_THEME in linux/uwsm/env.
    cursorTheme = "breeze_cursors",
    -- No window shadows.
    -- Blur keeps the defaults in variables.lua: size 8, 2 passes. Size 6 with
    -- 3 passes also looks good.
    shadowEnabled = false,
    -- HyDE's window transparency: 90% focused, 75% unfocused.
    windowOpacity = "0.90 0.75",
    -- HyDE-style borders: a two-colour 45° gradient. Unfocused windows keep a
    -- dimmer gradient that stays visible. In Lua, a gradient is a table, not the
    -- text form of hyprland.conf.
    activeWindowBorderColour = { colors = { "rgba(" .. scheme.primary .. "ff)", "rgba(" .. scheme.tertiary .. "ff)" }, angle = 45 },
    inactiveWindowBorderColour = { colors = { "rgba(" .. scheme.onSurfaceVariant .. "cc)", "rgba(" .. scheme.outlineVariant .. "cc)" }, angle = 45 },
    -- Blur behind pop-up workspaces. The dimming is in hypr-user.lua.
    blurSpecialWs = true,
    -- Switch off the resize keys of hyprland/keybinds.lua (Super+-/=,
    -- Super+Shift+-/=, Super+Alt+arrows). Super+Shift+arrows in hypr-user.lua
    -- resizes instead.
    kbWindowDecreaseWidth  = {},
    kbWindowIncreaseWidth  = {},
    kbWindowDecreaseHeight = {},
    kbWindowIncreaseHeight = {},
    -- The MX Master 3S thumb button sends mouse:277 without Solaar, so it
    -- toggles pop-up workspaces like Super+S.
    kbSpecialWs = { "SUPER + S", "mouse:277" },
    -- Pop-up workspace apps, merged over the defaults in utils/functions.lua.
    -- Super+D starts Equibop, not Discord.
    toggles = {
        communication = {
            discord = { enable = false },
            equibop = { enable = true, match = { { class = "equibop" } }, command = { "equibop" }, move = true },
        },
    },
}
