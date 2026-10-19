--!nonstrict
-- Headless service: the plugin's single source of Hyprland workspace data.
--
-- One `socat` stream on Hyprland's event socket serves every bar. On a
-- relevant event (coalesced within DEBOUNCE_MS) it reads `hyprctl -j
-- monitors` + `hyprctl -j workspaces` into a model and publishes, as plugin
-- state "workspaces", a table of output name -> { active = id, ids = {...} }:
-- the workspaces on that monitor that have windows, plus its active one,
-- sorted by id. A `workspacev2` event also moves the active workspace in the
-- model at once, so a switch animates without waiting for hyprctl.
--
-- Special workspaces (negative ids, names starting with "special:") are never
-- published.
--
-- Privacy: only id, name, monitor and window count are read from hyprctl's
-- JSON (it also carries the last window title), and event lines are reduced
-- to their name and, for workspacev2, the workspace id.
--
-- Without Hyprland (no instance in the environment) the service stays idle.
-- The `fake` IPC below then publishes test states.

local POLL_MS = 5000      -- fallback when events are flowing
local NO_STREAM_MS = 1000 -- no event stream (socat missing): plain polling
local DEBOUNCE_MS = 30
local STUCK_MS = 3000     -- a hyprctl pair older than this lost its callback; reset
local STREAM_EXIT = "__wspills_stream_exit" -- printed by the shell loop when socat exits

-- Socket2 events that can change what a bar shows.
local EVENTS = {}
for _, name in ipairs({
  "workspace", "workspacev2", "createworkspace", "createworkspacev2",
  "destroyworkspace", "destroyworkspacev2", "moveworkspace", "moveworkspacev2",
  "renameworkspace", "focusedmon", "focusedmonv2",
  "openwindow", "closewindow", "movewindow", "movewindowv2",
  "monitoradded", "monitoraddedv2", "monitorremoved", "monitorremovedv2",
  "configreloaded",
}) do
  EVENTS[name] = true
end

local pollMs = POLL_MS
local hyprland = false -- a Hyprland instance is in the environment
local fake = false     -- a `fake` IPC took over; Hyprland data is ignored
local inFlight = false
local inFlightSince = 0
local dirty = false
local lastSignature = nil
local streamStarted = false
local stats = { events = 0, exits = 0, refreshes = 0, publishes = 0, optimistic = 0 }

-- monitors: output name -> active workspace id.
-- workspaces: id -> { monitor = name, windows = n }, normal workspaces only.
local model = { monitors = {}, workspaces = {} }

local function isSpecial(id, name)
  return type(id) ~= "number" or id < 1
    or (type(name) == "string" and name:sub(1, 8) == "special:")
end

local function build()
  local byOutput = {}
  for output, active in pairs(model.monitors) do
    byOutput[output] = { active = active, ids = {} }
  end
  for id, ws in pairs(model.workspaces) do
    local entry = byOutput[ws.monitor]
    if entry == nil then
      -- A monitor with no normal active workspace still lists its occupied ones.
      entry = { ids = {} }
      byOutput[ws.monitor] = entry
    end
    if ws.windows > 0 or id == entry.active then
      table.insert(entry.ids, id)
    end
  end
  local outputs = {}
  for output, entry in pairs(byOutput) do
    table.sort(entry.ids)
    -- The active workspace must show even when hyprctl's two reads raced.
    if entry.active ~= nil and model.workspaces[entry.active] == nil then
      table.insert(entry.ids, entry.active)
      table.sort(entry.ids)
    end
    table.insert(outputs, output)
  end
  table.sort(outputs)
  local parts = {}
  for _, output in ipairs(outputs) do
    local entry = byOutput[output]
    parts[#parts + 1] = output .. "=" .. tostring(entry.active) .. ":" .. table.concat(entry.ids, ",")
  end
  return byOutput, table.concat(parts, ";")
end

local function publish()
  local byOutput, signature = build()
  if signature ~= lastSignature then
    lastSignature = signature
    stats.publishes = stats.publishes + 1
    noctalia.state.set("workspaces", byOutput)
  end
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

local function load(monitors, workspaces)
  local fresh = { monitors = {}, workspaces = {} }
  for _, mon in ipairs(monitors) do
    if type(mon.name) == "string" and type(mon.activeWorkspace) == "table" then
      local ws = mon.activeWorkspace
      fresh.monitors[mon.name] = (not isSpecial(ws.id, ws.name)) and ws.id or nil
    end
  end
  for _, ws in ipairs(workspaces) do
    if not isSpecial(ws.id, ws.name) and type(ws.monitor) == "string" then
      fresh.workspaces[ws.id] = { monitor = ws.monitor, windows = tonumber(ws.windows) or 0 }
    end
  end
  model = fresh
end

local refresh

local function finish()
  inFlight = false
  if dirty then
    dirty = false
    refresh()
  end
end

refresh = function()
  if fake or not hyprland then
    return
  end
  if inFlight then
    dirty = true
    return
  end
  inFlight = true
  inFlightSince = noctalia.nowMs()
  stats.refreshes = stats.refreshes + 1
  local started = noctalia.runAsync({ "hyprctl", "-j", "monitors" }, function(monitorsResult)
    local monitors = decodeArray(monitorsResult)
    if monitors == nil then
      finish()
      return
    end
    local ok = noctalia.runAsync({ "hyprctl", "-j", "workspaces" }, function(workspacesResult)
      local workspaces = decodeArray(workspacesResult)
      if workspaces ~= nil and not fake then
        load(monitors, workspaces)
        publish()
      end
      finish()
    end)
    if not ok then
      finish()
    end
  end)
  if not started then
    finish()
  end
end

-- Debounce without a timer API: drop the update interval to DEBOUNCE_MS. The
-- host re-arms its timer only when the value changes, so a burst of events
-- shares one tick, and update() restores the slow poll afterwards.
local function schedule()
  noctalia.setUpdateInterval(DEBOUNCE_MS)
end

-- `workspacev2>>ID,NAME`: ID is now active on the monitor that owns it.
-- Workspaces are pinned to monitors, so the model already knows which one.
local function optimistic(line)
  local id = tonumber(line:match("^workspacev2>>(%-?%d+),"))
  if id == nil or fake then
    return
  end
  local ws = model.workspaces[id]
  if ws ~= nil and model.monitors[ws.monitor] ~= id then
    model.monitors[ws.monitor] = id
    stats.optimistic = stats.optimistic + 1
    publish()
  end
end

local function onLine(line)
  if line == STREAM_EXIT then
    stats.exits = stats.exits + 1
    noctalia.log("hyprland event stream exited; restarting")
    schedule()
    return
  end
  local name = line:match("^(%w+)>>")
  if name ~= nil and EVENTS[name] then
    stats.events = stats.events + 1
    if name == "workspacev2" then
      optimistic(line)
    end
    schedule()
  end
end

local function shellQuote(s)
  return "'" .. s:gsub("'", "'\\''") .. "'"
end

local function startStream()
  local socket = noctalia.getenv("XDG_RUNTIME_DIR") .. "/hypr/"
    .. noctalia.getenv("HYPRLAND_INSTANCE_SIGNATURE") .. "/.socket2.sock"
  if not noctalia.commandExists("socat") then
    noctalia.log("socat not found; polling instead")
    return false
  end
  -- socat exits when Hyprland closes the socket; loop so a hiccup does not
  -- leave the bars on the slow poll. If the loop ever outlives its reader,
  -- the failing echo (EPIPE) ends it instead of respawning socat forever.
  local cmd = "while :; do socat -U - UNIX-CONNECT:" .. shellQuote(socket)
    .. " 2>/dev/null; echo " .. STREAM_EXIT .. " || exit 0; sleep 1; done"
  if not noctalia.runStream(cmd, onLine) then
    noctalia.log("could not start the Hyprland event stream; polling instead")
    return false
  end
  return true
end

function update()
  if not hyprland or fake then
    noctalia.setUpdateInterval(60000)
    return
  end
  noctalia.setUpdateInterval(pollMs)
  if inFlight and noctalia.nowMs() - inFlightSince > STUCK_MS then
    noctalia.log("hyprctl pair did not complete; resetting")
    inFlight = false
    dirty = false
  end
  refresh()
end

-- `noctalia msg plugin roynul/workspace-pills:hyprland all refresh` re-reads
-- Hyprland and republishes even when nothing changed.
-- `... all status` logs counters and the published ids (numbers only).
-- `... all fake '<json>'` publishes a test state and stops reading Hyprland
-- until `... all real`. The JSON is the published shape:
-- {"DP-1": {"active": 3, "ids": [1, 3, 5]}}. Special ids are dropped here too.
function onIpc(event, payload)
  if event == "refresh" then
    lastSignature = nil
    refresh()
  elseif event == "status" then
    noctalia.log(string.format(
      "hyprland: hyprland=%s fake=%s stream=%s poll=%dms events=%d exits=%d refreshes=%d publishes=%d optimistic=%d inFlight=%s",
      tostring(hyprland), tostring(fake), tostring(streamStarted), pollMs, stats.events, stats.exits,
      stats.refreshes, stats.publishes, stats.optimistic, tostring(inFlight)))
    noctalia.log("hyprland: published " .. tostring(lastSignature))
  elseif event == "fake" then
    local value = noctalia.json.decode(payload or "")
    if type(value) ~= "table" then
      noctalia.log("fake: payload is not a JSON object")
      return
    end
    fake = true
    model = { monitors = {}, workspaces = {} }
    for output, entry in pairs(value) do
      if type(entry) == "table" then
        local active = tonumber(entry.active)
        model.monitors[output] = (active ~= nil and not isSpecial(active)) and active or nil
        for _, id in ipairs(type(entry.ids) == "table" and entry.ids or {}) do
          id = tonumber(id)
          if id ~= nil and not isSpecial(id) then
            model.workspaces[id] = { monitor = output, windows = 1 }
          end
        end
      end
    end
    publish()
  elseif event == "real" then
    fake = false
    lastSignature = nil
    refresh()
  end
end

local sig = noctalia.getenv("HYPRLAND_INSTANCE_SIGNATURE")
local runtimeDir = noctalia.getenv("XDG_RUNTIME_DIR")
hyprland = sig ~= nil and sig ~= "" and runtimeDir ~= nil and runtimeDir ~= ""
if hyprland then
  streamStarted = startStream()
  if not streamStarted then
    pollMs = NO_STREAM_MS
  end
  noctalia.setUpdateInterval(pollMs)
  refresh()
else
  noctalia.log("no Hyprland instance in the environment; waiting for `fake` IPC")
  noctalia.setUpdateInterval(60000)
end
