--!nonstrict
-- One icon per window on the active Hyprland workspace of the monitor this
-- bar is on. The data comes from the plugin's `hyprland` service through the
-- "workspaces" state key (a table of output name -> window list); the tree is
-- re-rendered only when the window list, its order, or the highlighted window
-- changes. An empty workspace hides the whole capsule.

local ICON_PX = 18
local RECHECK_MS = 5000 -- safety net in case a state update was missed

-- appIconPath scans the filesystem on a miss, so remember results per app
-- class. `false` records a class with no icon, so it is not retried.
local iconCache = {}
local lastSignature = nil -- what the bar shows now; skip identical renders
local itemCount = 0

-- barWidget.outputName() and isVertical() read the bar snapshot attached to
-- the current call. The load chunk and update() carry one; noctalia.state
-- watch callbacks do not, so there both return nil/false. Remember the values
-- while a snapshot is present and use the copies everywhere.
local output = nil
local vertical = false

local function rememberBar()
  local name = barWidget.outputName()
  if name ~= nil and name ~= "" then
    output = name
    vertical = barWidget.isVertical() and true or false
  end
end

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

local function render(items)
  local container = vertical and ui.column or ui.row
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
    -- image and glyph alike. Opacity is the focus mark: full for the window
    -- this monitor focused most recently (the compositor-wide focused window
    -- on the focused monitor), dimmed for the rest.
    table.insert(children, ui.row({
      key = item.address,
      align = "center",
      opacity = item.active and 1.0 or 0.5,
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
    parts[#parts + 1] = item.address .. (item.active and "!" or "") .. item.class
  end
  local signature = table.concat(parts, ";")
  if signature == lastSignature then
    return
  end
  lastSignature = signature
  itemCount = #items

  if #items == 0 then
    barWidget.setVisible(false)
    return
  end
  render(items)
  barWidget.setVisible(true)
end

local function applyState(workspaces)
  if output == nil then
    return
  end
  if type(workspaces) ~= "table" then
    -- Nothing published yet (service still starting): no empty capsule.
    barWidget.setVisible(false)
    return
  end
  apply(workspaces[output] or {})
end

noctalia.state.watch("workspaces", applyState)

function update()
  noctalia.setUpdateInterval(RECHECK_MS)
  rememberBar()
  applyState(noctalia.state.get("workspaces"))
end

-- `noctalia msg plugin roynul/workspace-apps:icons <output|all> refresh`
-- forces a full rebuild, including the icon cache.
-- `... status` logs which output this bar follows and how many icons it shows.
function onIpc(event)
  if event == "refresh" then
    iconCache = {}
    lastSignature = nil
    noctalia.state.set("refresh-request", noctalia.nowMs())
  elseif event == "status" then
    noctalia.log(string.format("icons: output=%s vertical=%s items=%d published=%s",
      tostring(output), tostring(vertical), itemCount,
      tostring(noctalia.state.get("workspaces") ~= nil)))
  end
end

rememberBar()
applyState(noctalia.state.get("workspaces"))
