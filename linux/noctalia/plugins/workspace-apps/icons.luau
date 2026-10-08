--!nonstrict
-- One icon per window on the active Hyprland workspace of the monitor this
-- bar is on. Data comes from `hyprctl -j monitors` and `hyprctl -j clients`,
-- polled every POLL_MS; the tree is re-rendered only when the window list,
-- its order, or the focused window changes. An empty workspace hides the
-- whole capsule.

local ICON_PX = 18
local POLL_MS = 400

-- appIconPath scans the filesystem on a miss, so remember results per app
-- class. `false` records a class with no icon, so it is not retried each tick.
local iconCache = {}
local lastSignature = nil -- what the bar shows now; skip identical renders
local inFlight = false    -- drop a tick while the previous hyprctl pair runs

local function iconFor(class)
  local cached = iconCache[class]
  if cached ~= nil then
    return cached or nil
  end
  local path = noctalia.appIconPath(class, ICON_PX)
  iconCache[class] = path or false
  return path
end

local function focusWindow(address)
  -- Hyprland 0.56 Lua config: `hyprctl dispatch <expr>` runs hl.dispatch(<expr>).
  noctalia.runAsync({ "hyprctl", "dispatch", 'hl.dsp.focus({ window = "address:' .. address .. '" })' })
end

-- Windows on `output`'s active workspace, left to right. Special workspaces
-- (negative ids) are ignored: the normal workspace stays listed while one is
-- open on top. Unmapped and hidden (collapsed group tab) windows are skipped.
local function collect(output, monitors, clients)
  local activeId = nil
  for _, mon in ipairs(monitors) do
    if mon.name == output and type(mon.activeWorkspace) == "table" then
      activeId = mon.activeWorkspace.id
    end
  end

  local items = {}
  if activeId == nil or activeId < 0 then
    return items
  end
  for _, c in ipairs(clients) do
    if c.mapped and not c.hidden and type(c.workspace) == "table" and c.workspace.id == activeId then
      table.insert(items, {
        address = c.address,
        class = c.class or "",
        x = (type(c.at) == "table" and c.at[1]) or 0,
        y = (type(c.at) == "table" and c.at[2]) or 0,
        -- focusHistoryID 0 is the compositor-wide focused window.
        focused = c.focusHistoryID == 0,
      })
    end
  end
  table.sort(items, function(a, b)
    if a.x ~= b.x then
      return a.x < b.x
    end
    if a.y ~= b.y then
      return a.y < b.y
    end
    return a.address < b.address
  end)
  return items
end

local function render(items)
  local container = barWidget.isVertical() and ui.column or ui.row
  local children = {}
  for _, item in ipairs(items) do
    local path = iconFor(item.class)
    local visual
    if path then
      visual = ui.image({ path = path, width = ICON_PX, height = ICON_PX, fit = "contain" })
    else
      visual = ui.glyph({ name = "app-window", size = ICON_PX })
    end
    -- A row wrapper carries key, click, tooltip, and group opacity for both
    -- image and glyph alike. Opacity is the focus mark: full for the focused
    -- window, dimmed for the rest.
    table.insert(children, ui.row({
      key = item.address,
      align = "center",
      opacity = item.focused and 1.0 or 0.5,
      tooltip = item.class,
      onClick = function()
        focusWindow(item.address)
      end,
    }, { visual }))
  end
  barWidget.render(container({ gap = 8, align = "center" }, children))
end

local function apply(items)
  local parts = {}
  for _, item in ipairs(items) do
    parts[#parts + 1] = item.address .. (item.focused and "!" or "") .. item.class
  end
  local signature = table.concat(parts, ";")
  if signature == lastSignature then
    return
  end
  lastSignature = signature

  if #items == 0 then
    barWidget.setVisible(false)
    return
  end
  render(items)
  barWidget.setVisible(true)
end

local function decodeArray(result)
  if result.exitCode ~= 0 or result.timedOut or result.stdoutTruncated then
    return nil
  end
  local value = noctalia.json.decode(result.stdout)
  if type(value) ~= "table" then
    return nil
  end
  return value
end

local function refresh()
  if inFlight then
    return
  end
  local output = barWidget.outputName() or noctalia.focusedOutputName()
  if output == nil then
    return
  end
  inFlight = true
  local started = noctalia.runAsync({ "hyprctl", "-j", "monitors" }, function(monitorsResult)
    local monitors = decodeArray(monitorsResult)
    if monitors == nil then
      inFlight = false
      return
    end
    local ok = noctalia.runAsync({ "hyprctl", "-j", "clients" }, function(clientsResult)
      inFlight = false
      local clients = decodeArray(clientsResult)
      if clients == nil then
        return
      end
      apply(collect(output, monitors, clients))
    end)
    if not ok then
      inFlight = false
    end
  end)
  if not started then
    inFlight = false
  end
end

function update()
  noctalia.setUpdateInterval(POLL_MS)
  refresh()
end

-- `noctalia msg plugin roynul/workspace-apps:icons <output|all> refresh`
-- forces a full rebuild, including the icon cache.
function onIpc(event)
  if event == "refresh" then
    iconCache = {}
    lastSignature = nil
    refresh()
  end
end
