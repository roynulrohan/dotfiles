--!nonstrict
-- Headless service: the plugin's single source of Hyprland window data.
--
-- One instance runs for the whole plugin, so one `socat` stream on Hyprland's
-- event socket serves every bar. On a relevant event (coalesced within
-- DEBOUNCE_MS) it reads `hyprctl -j monitors` + `hyprctl -j clients`, builds
-- a per-output list of the windows on each active workspace, and publishes it
-- as plugin state "workspaces" for the icons widgets. A slow poll backs the
-- stream up in case it dies; the shell loop around socat restarts it.
--
-- Privacy: window titles never leave hyprctl's JSON. Only address, class,
-- position, workspace id and focusHistoryID are kept, and event lines are
-- reduced to their name (the part before ">>") before anything looks at them.
--
-- Setting `hidden_tags`: windows carrying any of these Hyprland tags are left
-- out. Tag changes raise no socket2 event, so after changing a window's tags,
-- send the `refresh` IPC below to update the bars at once.

local POLL_MS = 5000     -- fallback when events are flowing
local NO_STREAM_MS = 1000 -- no event stream available: plain polling
local DEBOUNCE_MS = 50
local STREAM_EXIT = "__wsapps_stream_exit" -- printed by the shell loop when socat exits

-- Socket2 events that can change what a bar shows. Names only; payloads
-- (which carry titles for windowtitle*) are discarded unread.
local EVENTS = {}
for _, name in ipairs({
  "openwindow", "closewindow", "movewindow", "movewindowv2",
  "activewindow", "activewindowv2", "workspace", "workspacev2",
  "focusedmon", "focusedmonv2", "moveworkspace", "moveworkspacev2",
  "activespecial", "activespecialv2", "changefloatingmode", "fullscreen",
  "togglegroup", "moveintogroup", "moveoutofgroup", "minimized", "pin",
  "monitoradded", "monitoraddedv2", "monitorremoved", "monitorremovedv2",
  "configreloaded",
}) do
  EVENTS[name] = true
end

local STUCK_MS = 3000 -- a hyprctl pair older than this lost its callback; reset

local pollMs = POLL_MS
local pending = false  -- an event asked for a refresh; served on the next tick
local inFlight = false -- a hyprctl pair is running
local inFlightSince = 0
local dirty = false    -- events arrived while inFlight; run once more after
local lastSignature = nil
local streamStarted = false
-- Counters for the `status` IPC (numbers only, nothing from the events).
local stats = { events = 0, exits = 0, refreshes = 0, publishes = 0, lastPublishMs = 0 }

-- Tag names from the hidden_tags setting, as a set.
local hiddenTags = {}

local function readHiddenTags()
  hiddenTags = {}
  local list = noctalia.getConfig("hidden_tags")
  if type(list) == "table" then
    for _, tag in ipairs(list) do
      if type(tag) == "string" and tag ~= "" then
        hiddenTags[tag] = true
      end
    end
  end
end

local function hiddenTagCount()
  local n = 0
  for _ in pairs(hiddenTags) do
    n = n + 1
  end
  return n
end

-- hyprctl marks dynamic tags (set by window rules) with a trailing "*";
-- both forms match.
local function hasHiddenTag(c)
  if type(c.tags) ~= "table" then
    return false
  end
  for _, tag in ipairs(c.tags) do
    if type(tag) == "string" and hiddenTags[(tag:gsub("%*$", ""))] then
      return true
    end
  end
  return false
end

local function shellQuote(s)
  return "'" .. s:gsub("'", "'\\''") .. "'"
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

-- Windows on `activeId`, left to right. Unmapped and hidden (collapsed group
-- tab) windows are skipped, and so are windows with a hidden_tags tag.
-- `active` marks the window this output focused most recently (lowest
-- focusHistoryID); for the focused output that is the compositor-wide focused
-- window (id 0). Negative ids mean "never focused".
local function collect(activeId, clients)
  local items = {}
  local best = nil
  for _, c in ipairs(clients) do
    if c.mapped and not c.hidden and type(c.workspace) == "table" and c.workspace.id == activeId
      and not hasHiddenTag(c) then
      local id = c.focusHistoryID
      if type(id) ~= "number" or id < 0 then
        id = nil
      end
      table.insert(items, {
        address = c.address,
        class = c.class or "",
        x = (type(c.at) == "table" and c.at[1]) or 0,
        y = (type(c.at) == "table" and c.at[2]) or 0,
        history = id,
      })
      if id ~= nil and (best == nil or id < best) then
        best = id
      end
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
  for _, item in ipairs(items) do
    item.active = best ~= nil and item.history == best
    item.history = nil
  end
  return items
end

-- Special workspaces (negative ids) are ignored: the normal workspace stays
-- listed while one is open on top.
local function snapshot(monitors, clients)
  local byOutput = {}
  local parts = {}
  for _, mon in ipairs(monitors) do
    if type(mon.name) == "string" and type(mon.activeWorkspace) == "table" then
      local id = mon.activeWorkspace.id
      local items = {}
      if type(id) == "number" and id >= 0 then
        items = collect(id, clients)
      end
      byOutput[mon.name] = items
      parts[#parts + 1] = mon.name .. "="
      for _, item in ipairs(items) do
        parts[#parts + 1] = item.address .. (item.active and "!" or "") .. item.class .. ","
      end
    end
  end
  return byOutput, table.concat(parts, ";")
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
    local ok = noctalia.runAsync({ "hyprctl", "-j", "clients" }, function(clientsResult)
      local clients = decodeArray(clientsResult)
      if clients ~= nil then
        local byOutput, signature = snapshot(monitors, clients)
        if signature ~= lastSignature then
          lastSignature = signature
          stats.publishes = stats.publishes + 1
          stats.lastPublishMs = noctalia.nowMs()
          noctalia.state.set("workspaces", byOutput)
        end
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
  pending = true
  noctalia.setUpdateInterval(DEBOUNCE_MS)
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
    schedule()
  end
end

local function startStream()
  local sig = noctalia.getenv("HYPRLAND_INSTANCE_SIGNATURE")
  local runtimeDir = noctalia.getenv("XDG_RUNTIME_DIR")
  if sig == nil or sig == "" or runtimeDir == nil or runtimeDir == "" then
    noctalia.log("no Hyprland instance in the environment; polling instead")
    return false
  end
  if not noctalia.commandExists("socat") then
    noctalia.log("socat not found; polling instead")
    return false
  end
  local socket = runtimeDir .. "/hypr/" .. sig .. "/.socket2.sock"
  -- socat exits when Hyprland closes the socket; loop so a hiccup does not
  -- leave the bars on the slow poll. Noctalia kills the whole process group
  -- on reload; should the loop ever outlive its reader, the failing echo
  -- (EPIPE) ends it instead of respawning socat forever.
  local cmd = "while :; do socat -U - UNIX-CONNECT:" .. shellQuote(socket)
    .. " 2>/dev/null; echo " .. STREAM_EXIT .. " || exit 0; sleep 1; done"
  if not noctalia.runStream(cmd, onLine) then
    noctalia.log("could not start the Hyprland event stream; polling instead")
    return false
  end
  return true
end

function update()
  pending = false
  noctalia.setUpdateInterval(pollMs)
  if inFlight and noctalia.nowMs() - inFlightSince > STUCK_MS then
    -- A callback that never came back would otherwise block every refresh.
    noctalia.log("hyprctl pair did not complete; resetting")
    inFlight = false
    dirty = false
  end
  refresh()
end

-- `noctalia msg plugin roynul/workspace-apps:hyprland all refresh` re-reads
-- Hyprland and republishes even when nothing changed.
-- `... all status` logs counters to noctalia.log (no window data).
function onIpc(event)
  if event == "refresh" then
    lastSignature = nil
    refresh()
  elseif event == "status" then
    noctalia.log(string.format(
      "hyprland: stream=%s poll=%dms events=%d exits=%d refreshes=%d publishes=%d lastPublishAge=%ds inFlight=%s hiddenTags=%d",
      tostring(streamStarted), pollMs, stats.events, stats.exits, stats.refreshes, stats.publishes,
      stats.lastPublishMs > 0 and math.floor((noctalia.nowMs() - stats.lastPublishMs) / 1000) or -1,
      tostring(inFlight), hiddenTagCount()))
  end
end

-- A settings change (hidden_tags) is applied in place: the event stream and
-- counters survive, and the lists are rebuilt at once.
function onConfigChanged()
  readHiddenTags()
  lastSignature = nil
  refresh()
end

-- Widgets ask for a republish (icon cache cleared) by bumping this key.
noctalia.state.watch("refresh-request", function()
  lastSignature = nil
  refresh()
end)

readHiddenTags()
streamStarted = startStream()
if not streamStarted then
  pollMs = NO_STREAM_MS
end
noctalia.setUpdateInterval(pollMs)
refresh()
