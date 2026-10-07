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

-- Window mode (Super+A): move, resize and place the active window from the
-- keyboard. Inside the mode:
--   arrows        move 40 px (tiled windows: move within the layout)
--   Alt+arrows    move 5 px
--   Shift+arrows  move the right / bottom edge (tiled: resize)
--   Ctrl+arrows   snap to the left / right / top / bottom half (floating only)
--   f             fill the height, keeping width and horizontal position
--   c             centre
--   Esc, Enter or Super+A leave the mode. Other keys do nothing inside it.
-- Floating windows never move or grow past the usable screen area: a step that
-- would cross an edge stops at it.
local STEP  = 40    -- px per arrow press
local FINE  = 5     -- px per Alt+arrow press
local EDGE  = 30    -- px per Shift+arrow press
local INSET = 4 + 2 -- HyprMod's gaps_out + border_size, so placed windows line up with tiled ones

-- Usable area of a monitor (the window's own, else the focused one): minus
-- caelestia's bar and frame (reserved), minus the gap.
local function work_area(win)
    local m = (win and win.monitor) or hl.get_active_monitor()
    if not m then return nil end
    local r = m.reserved
    return {
        x = m.x + r.left + INSET,
        y = m.y + r.top + INSET,
        w = m.width / m.scale - r.left - r.right - 2 * INSET,
        h = m.height / m.scale - r.top - r.bottom - 2 * INSET,
    }
end

local function clamp(v, lo, hi)
    return math.max(lo, math.min(v, math.max(lo, hi)))
end

local function nudge(dx, dy, dir)
    local win = hl.get_active_window()
    if not win then return end
    if not win.floating then
        hl.dispatch(hl.dsp.window.move({ direction = dir }))
        return
    end
    local a = work_area(win)
    if not a then return end
    local x = clamp(win.at.x + dx, a.x, a.x + a.w - win.size.x)
    local y = clamp(win.at.y + dy, a.y, a.y + a.h - win.size.y)
    hl.dispatch(hl.dsp.window.move({ x = math.floor(x), y = math.floor(y) }))
end

-- Grow (+) or shrink (-) the right / bottom edge. Hyprland resizes a floating
-- window around its centre, so shift it back by half to keep the top-left put.
local function edge(dx, dy)
    local win = hl.get_active_window()
    if not win then return end
    if not win.floating then
        hl.dispatch(hl.dsp.window.resize({ x = dx, y = dy, relative = true }))
        return
    end
    local a = work_area(win)
    if a then -- don't grow past the right / bottom edge of the usable area
        dx = math.min(dx, a.x + a.w - (win.at.x + win.size.x))
        dy = math.min(dy, a.y + a.h - (win.at.y + win.size.y))
    end
    if dx == 0 and dy == 0 then return end
    hl.dispatch(hl.dsp.window.resize({ x = dx, y = dy, relative = true }))
    hl.dispatch(hl.dsp.window.move({ x = dx / 2, y = dy / 2, relative = true }))
end

local function place(x, y, w, h)
    hl.dispatch(hl.dsp.window.resize({ x = math.floor(w), y = math.floor(h) }))
    hl.dispatch(hl.dsp.window.move({ x = math.floor(x), y = math.floor(y) }))
end

local function snap(side)
    local win = hl.get_active_window()
    local a = work_area(win)
    if not (win and win.floating and a) then return end
    local hw, hh = (a.w - INSET) / 2, (a.h - INSET) / 2
    if side == "left" then place(a.x, a.y, hw, a.h)
    elseif side == "right" then place(a.x + hw + INSET, a.y, hw, a.h)
    elseif side == "up" then place(a.x, a.y, a.w, hh)
    else place(a.x, a.y + hh + INSET, a.w, hh) end
end

local function fill_height()
    local win = hl.get_active_window()
    local a = work_area(win)
    if not (win and win.floating and a) then return end
    place(win.at.x, a.y, win.size.x, a.h)
end

hl.bind("SUPER + A", hl.dsp.submap("window"))
hl.define_submap("window", function()
    local keep = { repeating = true }
    hl.bind("Left",  function() nudge(-STEP, 0, "left") end, keep)
    hl.bind("Right", function() nudge(STEP, 0, "right") end, keep)
    hl.bind("Up",    function() nudge(0, -STEP, "up") end, keep)
    hl.bind("Down",  function() nudge(0, STEP, "down") end, keep)
    hl.bind("ALT + Left",  function() nudge(-FINE, 0, "left") end, keep)
    hl.bind("ALT + Right", function() nudge(FINE, 0, "right") end, keep)
    hl.bind("ALT + Up",    function() nudge(0, -FINE, "up") end, keep)
    hl.bind("ALT + Down",  function() nudge(0, FINE, "down") end, keep)
    hl.bind("SHIFT + Left",  function() edge(-EDGE, 0) end, keep)
    hl.bind("SHIFT + Right", function() edge(EDGE, 0) end, keep)
    hl.bind("SHIFT + Up",    function() edge(0, -EDGE) end, keep)
    hl.bind("SHIFT + Down",  function() edge(0, EDGE) end, keep)
    hl.bind("CTRL + Left",  function() snap("left") end)
    hl.bind("CTRL + Right", function() snap("right") end)
    hl.bind("CTRL + Up",    function() snap("up") end)
    hl.bind("CTRL + Down",  function() snap("down") end)
    hl.bind("f", fill_height)
    hl.bind("c", hl.dsp.window.center())
    hl.bind("Escape", hl.dsp.submap("reset"))
    hl.bind("Return", hl.dsp.submap("reset"))
    hl.bind("SUPER + A", hl.dsp.submap("reset"))
end)

-- Live wallpapers (linux/wallpaper/live-wallpaper): one Wallpaper Engine
-- wallpaper per connected monitor, over caelestia's still wallpaper.
hl.on("hyprland.start", function()
    hl.exec_cmd(os.getenv("HOME") .. "/.local/bin/live-wallpaper")
end)
