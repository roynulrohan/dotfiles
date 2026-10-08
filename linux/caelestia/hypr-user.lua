-- User overrides loaded after the base config (linux/hypr) and before HyprMod's file.
-- Only things HyprMod cannot represent go here.

-- Window mode (Super+A): move, resize and place the active window from the
-- keyboard. Inside the mode:
--   arrows        move 40 px (tiled windows: move within the layout)
--   Alt+arrows    move 5 px
--   Shift+arrows  move the right / bottom edge, or the left / top one when the
--                 window sits against the right / bottom side (tiled: resize)
--   Alt+Shift+arrows  the same, 5 px
--   Ctrl+arrows   snap to the left / right / top / bottom half (floating only)
--   f             fill the height, keeping width and horizontal position
--   c             centre
--   Esc, Enter or Super+A leave the mode. Other keys do nothing inside it.
-- Floating windows never move or grow past the usable screen area: a step that
-- would cross an edge stops at it.
local STEP  = 40    -- px per arrow press
local FINE  = 5     -- px per Alt+arrow and Alt+Shift+arrow press
local EDGE  = 30    -- px per Shift+arrow press
local INSET = 4 + 2 -- HyprMod's gaps_out + border_size, so placed windows line up with tiled ones

-- Usable area of a monitor (the window's own, else the focused one): minus
-- the bar (reserved), minus the gap.
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

-- One axis of edge(): the size change and the shift that keeps the other edge
-- put. The right / bottom edge moves by d, unless the window touches only the
-- far side of the usable area (snapped right or down): then the left / top
-- edge moves, so the window stays against that side. Growth stops at the
-- usable area.
local function edge_axis(d, pos, size, lo, len)
    if d == 0 then return 0, 0 end
    if math.abs(pos + size - (lo + len)) <= 1 and pos > lo + 1 then
        local grow = -d
        if grow > 0 then grow = math.min(grow, pos - lo) end
        return grow, -grow / 2
    end
    local grow = d
    if grow > 0 then grow = math.max(0, math.min(grow, lo + len - (pos + size))) end
    return grow, grow / 2
end

-- Move a window edge by dx / dy (see edge_axis for which one). Hyprland
-- resizes a floating window around its centre, so it's shifted by half.
local function edge(dx, dy)
    local win = hl.get_active_window()
    if not win then return end
    if not win.floating then
        hl.dispatch(hl.dsp.window.resize({ x = dx, y = dy, relative = true }))
        return
    end
    local a = work_area(win)
    if not a then return end
    local gx, mx = edge_axis(dx, win.at.x, win.size.x, a.x, a.w)
    local gy, my = edge_axis(dy, win.at.y, win.size.y, a.y, a.h)
    if gx == 0 and gy == 0 then return end
    hl.dispatch(hl.dsp.window.resize({ x = gx, y = gy, relative = true }))
    hl.dispatch(hl.dsp.window.move({ x = mx, y = my, relative = true }))
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

-- Super+Shift+arrows resizes outside window mode too, the same way as
-- Shift+arrows inside it. caelestia binds these keys to "move window";
-- unbind first or both fire.
for _, dir in ipairs({ "Left", "Right", "Up", "Down" }) do
    hl.unbind("SUPER + SHIFT + " .. dir)
end
hl.bind("SUPER + SHIFT + Left",  function() edge(-EDGE, 0) end, { repeating = true })
hl.bind("SUPER + SHIFT + Right", function() edge(EDGE, 0) end, { repeating = true })
hl.bind("SUPER + SHIFT + Up",    function() edge(0, -EDGE) end, { repeating = true })
hl.bind("SUPER + SHIFT + Down",  function() edge(0, EDGE) end, { repeating = true })

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
    hl.bind("ALT + SHIFT + Left",  function() edge(-FINE, 0) end, keep)
    hl.bind("ALT + SHIFT + Right", function() edge(FINE, 0) end, keep)
    hl.bind("ALT + SHIFT + Up",    function() edge(0, -FINE) end, keep)
    hl.bind("ALT + SHIFT + Down",  function() edge(0, FINE) end, keep)
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

-- Live wallpapers run as a systemd user service (linux/wallpaper), not from here.
-- linux-wallpaperengine only draws on the outputs it saw at start. A monitor
-- that comes back (replugged, or the DisplayPort VG248 reconnecting when the
-- screens wake from DPMS) gets no wallpaper, so restart the service then;
-- try-restart does nothing before the service has started at login.
hl.on("monitor.added", function()
    hl.exec_cmd("systemctl --user try-restart live-wallpaper.service")
end)

-- Per-monitor workspaces: each monitor has its own 1-10 on Super+1..0, from
-- split-monitor-workspaces (a Lua package, pinned clone in
-- ~/.local/share/hypr-plugins; see linux/caelestia/SETUP.md). Hyprland ids:
-- main DP-1 1-10, right HDMI-A-1 11-20, left DP-2 21-30.
-- Required by its full name: its modules are called globals/helpers/monitors,
-- and caelestia's own modules are required by bare names too.
local smw_dir = os.getenv("HOME") .. "/.local/share/hypr-plugins"
package.path = package.path .. ";" .. smw_dir .. "/?.lua;" .. smw_dir .. "/?/init.lua"
local smw_ok, smw = pcall(require, "split-monitor-workspaces")
if not smw_ok then
    print("hypr-user: split-monitor-workspaces not loaded: " .. tostring(smw))
else
    -- HyprMod reads this config by running it and parsing stdout line by line,
    -- and the package print()s at setup, which broke HyprMod. Send those lines
    -- to stderr instead (Hyprland logs both).
    local stdout_print = print
    print = function(...)
        local parts = {}
        for i = 1, select("#", ...) do parts[i] = tostring(select(i, ...)) end
        io.stderr:write(table.concat(parts, "\t") .. "\n")
    end
    smw.setup({
        workspace_count = 10,
        monitor_priority = { "DP-1", "HDMI-A-1", "DP-2" },
        -- Workspaces stay persistent (the package's default): Hyprland's own
        -- workspace rules then pin each one to its monitor. Without them, a
        -- reload makes the package create missing workspaces on whichever
        -- monitor has focus and then move them, which left workspaces on the
        -- wrong monitor.
    })
    print = stdout_print

    -- Replace caelestia's global Super(+Alt)+N and its "groups of 10"
    -- (Ctrl+Super(+Alt)+N). Super+Shift+N used to live in HyprMod's file.
    for i = 1, 10 do
        local key, n = tostring(i % 10), tostring(i)
        for _, mods in ipairs({ "SUPER", "SUPER + ALT", "CTRL + SUPER", "CTRL + SUPER + ALT" }) do
            hl.unbind(mods .. " + " .. key)
        end
        hl.bind("SUPER + " .. key, smw.workspace(n))
        hl.bind("SUPER + SHIFT + " .. key, smw.move_to_workspace(n))
        hl.bind("SUPER + ALT + " .. key, smw.move_to_workspace_silent(n))
    end

    -- Cycling stays on the focused monitor. Keyboard keys repeat, wheels don't.
    local function rebind(keys, action, repeating)
        for _, key in ipairs(keys) do
            hl.unbind(key)
            hl.bind(key, action, repeating and { repeating = true } or nil)
        end
    end
    rebind({ "SUPER + mouse_down" }, smw.cycle_workspaces("next"))
    rebind({ "SUPER + mouse_up" }, smw.cycle_workspaces("prev"))
    rebind({ "CTRL + SUPER + Right", "SUPER + Page_Down" }, smw.cycle_workspaces("next"), true)
    rebind({ "CTRL + SUPER + Left", "SUPER + Page_Up" }, smw.cycle_workspaces("prev"), true)
    rebind({ "SUPER + ALT + mouse_down" }, smw.move_to_workspace("+1"))
    rebind({ "SUPER + ALT + mouse_up" }, smw.move_to_workspace("-1"))
    rebind({ "SUPER + ALT + Page_Down", "SUPER + CTRL + ALT + right" }, smw.move_to_workspace("+1"), true)
    rebind({ "SUPER + ALT + Page_Up", "SUPER + CTRL + ALT + left" }, smw.move_to_workspace("-1"), true)
    rebind({ "SUPER + CTRL + down" }, smw.workspace("empty"))
    hl.unbind("CTRL + SUPER + mouse_down")
    hl.unbind("CTRL + SUPER + mouse_up")

    -- Monitors: Super+[ ] jumps left/right, Super+Shift+[ ] sends the window.
    hl.bind("SUPER + bracketleft", hl.dsp.focus({ monitor = "l" }))
    hl.bind("SUPER + bracketright", hl.dsp.focus({ monitor = "r" }))
    hl.bind("SUPER + SHIFT + bracketleft", hl.dsp.window.move({ monitor = "l" }))
    hl.bind("SUPER + SHIFT + bracketright", hl.dsp.window.move({ monitor = "r" }))
end

-- Machine-local config that stays out of the repo, if this machine has one.
-- Errors show as a Hyprland notification instead of failing silently.
local local_file = os.getenv("HOME") .. "/.config/caelestia/hypr-local.lua"
local lf = io.open(local_file)
if lf then
    lf:close()
    local ok, err = pcall(require, "hypr-local")
    if not ok then
        hl.notification.create({ text = "hypr-local.lua failed: " .. tostring(err), timeout = 10000 })
    end
end
