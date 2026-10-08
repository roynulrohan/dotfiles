return {
    terminal = "kitty",
    fileExplorer = "dolphin",
    -- caelestia gives a lone tiled window a bigger outer gap (default 20).
    -- Keep it equal to HyprMod's general:gaps_out so single windows match.
    singleWindowGapsOut = 4,
    -- No caelestia resize keys (Super+-/=, Super+Shift+-/=, Super+Alt+arrows:
    -- 10% of the window per press). Super+Shift+arrows in hypr-user.lua resizes.
    kbWindowDecreaseWidth  = {},
    kbWindowIncreaseWidth  = {},
    kbWindowDecreaseHeight = {},
    kbWindowIncreaseHeight = {},
}
