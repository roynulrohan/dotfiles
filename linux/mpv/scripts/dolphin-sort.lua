-- Next/previous follows Dolphin's sort order for the folder.
--
-- autocreate-playlist (mpv.conf) lists the folder sorted by name only. This
-- reorders that playlist the way Dolphin shows the folder, from Dolphin's view
-- settings (Dolphin 26.08, src/views/viewproperties.cpp):
--   * "Remember display style for each folder" off (GlobalViewProps): the
--     global settings in ~/.local/share/dolphin/view_properties/global.
--   * on: the folder's own settings (a .directory file, or the folder's
--     user.kde.fm.viewproperties#1 attribute; Dolphin keeps folders outside
--     home under view_properties/local, network folders under
--     view_properties/remote), with missing keys from the global settings.
-- Sort roles: name (natural), modified, created, accessed, size, type (by
-- extension); anything else falls back to name. Once per playlist; mpv's own
-- order stays if anything is missing.

local mp = require "mp"
local utils = require "mp.utils"

local HOME = os.getenv("HOME") or ""
local CONFIG = os.getenv("XDG_CONFIG_HOME") or (HOME .. "/.config")
local VIEWPROPS = (os.getenv("XDG_DATA_HOME") or (HOME .. "/.local/share")) .. "/dolphin/view_properties"

local function read_file(path)
    local f = io.open(path, "r")
    if not f then return nil end
    local s = f:read("a")
    f:close()
    return s
end

local function run(args)
    local r = mp.command_native({
        name = "subprocess", args = args, playback_only = false,
        capture_stdout = true, capture_stderr = true,
    })
    if r and r.status == 0 then return r.stdout end
    return nil
end

-- Keys of one INI group.
local function ini_group(text, want)
    local t, group = {}, nil
    for line in (text or ""):gmatch("[^\r\n]+") do
        local g = line:match("^%[(.+)%]$")
        if g then
            group = g
        elseif group == want then
            local k, v = line:match("^([^=]+)=(.*)$")
            if k then t[k] = v end
        end
    end
    return t
end

-- Dolphin's settings stored at one directory: .directory first, then the attribute.
local function props_at(dir)
    local t = ini_group(read_file(dir .. "/.directory"), "Dolphin")
    if next(t) then return t end
    return ini_group(run({ "getfattr", "--absolute-names", "--only-values",
        "-n", "user.kde.fm.viewproperties#1", dir }), "Dolphin")
end

-- KConfig dates ("2026,10,7,6,13,1.979") as comparable strings.
local function stamp(s)
    local p = {}
    for n in (s or ""):gmatch("[%d.]+") do p[#p + 1] = tonumber(n) end
    if #p < 6 then return "" end
    return string.format("%04d%02d%02d%02d%02d%06.3f", p[1], p[2], p[3], p[4], p[5], p[6])
end

local function sort_settings(dir)
    local general = ini_group(read_file(CONFIG .. "/dolphinrc"), "General")
    local defaults = props_at(VIEWPROPS .. "/global")
    local role, order = defaults.SortRole or "text", defaults.SortOrder or "0"
    if (general.GlobalViewProps or "true") == "true" then return role, order end

    local own = {}
    if dir:find("/kio%-fuse%-") then
        own = props_at(VIEWPROPS .. "/remote")
    else
        if dir == HOME or dir:sub(1, #HOME + 1) == HOME .. "/" then own = props_at(dir) end
        if not next(own) then own = props_at(VIEWPROPS .. "/local" .. dir) end
    end
    -- Settings older than the last "apply to all folders" don't count, as in Dolphin.
    if own.Timestamp and stamp(own.Timestamp) < stamp(general.ViewPropsTimestamp) then own = {} end
    return own.SortRole or role, own.SortOrder or order
end

-- Natural, case-insensitive order: "img2" before "img10".
local function name_less(a, b)
    a, b = a:lower(), b:lower()
    local i, j = 1, 1
    while i <= #a and j <= #b do
        local da, db = a:match("^%d+", i), b:match("^%d+", j)
        if da and db then
            local na, nb = da:gsub("^0+", ""), db:gsub("^0+", "")
            if #na ~= #nb then return #na < #nb end
            if na ~= nb then return na < nb end
            i, j = i + #da, j + #db
        else
            local ca, cb = a:sub(i, i), b:sub(j, j)
            if ca ~= cb then return ca < cb end
            i, j = i + 1, j + 1
        end
    end
    return (#a - i) < (#b - j)
end

local function birth_times(paths)
    local args = { "stat", "--printf", "%W\\n", "--" }
    for _, p in ipairs(paths) do args[#args + 1] = p end
    local out, t = run(args) or "", {}
    for n in out:gmatch("[^\n]+") do t[#t + 1] = tonumber(n) or 0 end
    return t
end

local function reorder()
    local list = mp.get_property_native("playlist") or {}
    if #list < 2 then return end
    local cwd = utils.getcwd() or ""
    local dir, items = nil, {}
    for i, e in ipairs(list) do
        local path = e.filename
        if path:find("^%a[%w+.-]*://") then return end           -- not a local file
        if path:sub(1, 1) ~= "/" then path = utils.join_path(cwd, path) end
        local d, name = utils.split_path(path)
        d = d:gsub("/+$", "")
        if dir and d ~= dir then return end                       -- not one folder's playlist
        dir = d
        local info = utils.file_info(path)
        if not info then return end
        items[i] = { index = i - 1, path = path, name = name, info = info }
    end

    local role, order = sort_settings(dir)
    local key
    if role == "modificationtime" then
        key = function(it) return it.info.mtime end
    elseif role == "accesstime" then
        key = function(it) return it.info.atime end
    elseif role == "size" then
        key = function(it) return it.info.size end
    elseif role == "creationtime" then
        local paths = {}
        for i, it in ipairs(items) do paths[i] = it.path end
        local born = birth_times(paths)
        for i, it in ipairs(items) do it.born = born[i] or 0 end
        key = function(it) return it.born end
    elseif role == "type" then
        key = function(it) return (it.name:match("%.([^.]+)$") or ""):lower() end
    end
    local desc = order == "1"

    local sorted = {}
    for i, it in ipairs(items) do sorted[i] = it end
    table.sort(sorted, function(a, b)
        if key then
            local ka, kb = key(a), key(b)
            if ka ~= kb then
                if desc then return ka > kb end
                return ka < kb
            end
            return name_less(a.name, b.name)              -- ties: by name, as Dolphin
        end
        if desc then return name_less(b.name, a.name) end
        return name_less(a.name, b.name)
    end)

    -- Move entries into place; the playing entry keeps playing.
    local current = {}
    for i, it in ipairs(items) do current[i] = it.index end
    for p, it in ipairs(sorted) do
        local q
        for k = p, #current do
            if current[k] == it.index then q = k; break end
        end
        if q and q ~= p then
            mp.commandv("playlist-move", tostring(q - 1), tostring(p - 1))
            table.remove(current, q)
            table.insert(current, p, it.index)
        end
    end
end

local done = false
mp.register_event("file-loaded", function()
    if done then return end
    done = true
    reorder()
end)
