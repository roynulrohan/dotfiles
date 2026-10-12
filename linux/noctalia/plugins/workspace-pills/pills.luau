--!nonstrict
-- This monitor's workspaces as numbered pills, animated like HyDE's waybar.
--
-- Data: the plugin's `hyprland` service publishes plugin state "workspaces"
-- (output name -> { active = id, ids = {...} }). Each pill has three animated
-- channels on HyDE's cubic-bezier(.55, -0.68, .48, 1.682):
--   present  0 -> 1 grows a new pill in from zero width, 1 -> 0 shrinks it out
--   active   widens the pill (inactive -> active width) and fills it with primary
--   hover    HyDE's hover background, primary at 40 %
-- A retarget starts from the channel's current value, so an interrupted
-- animation carries on from where it is.
--
-- Bar plugins have no frame tick. While a channel moves, the update interval
-- drops to FRAME_MS and update() draws one frame; once everything has settled
-- it goes back to RECHECK_MS, so an idle bar costs one signature compare
-- every few seconds and renders nothing.
--
-- Geometry copies the built-in widget at our [widget.workspaces] settings
-- (Noctalia 5.2.1 workspaces_widget.cpp, style "regular"): pill height 16,
-- inactive width max(16, text + 9.6), active width max(16 x 2.2, text + 9.6),
-- 4 px between pills, label 11 px x font_scale 1.3.

local FRAME_MS = 16
local RECHECK_MS = 5000 -- safety net in case a state update was missed

-- HyDE: `#workspaces button.active { transition: all 0.4s ... }` and
-- `:hover { transition: all 0.3s ... }`, both on this curve.
local CURVE = { 0.55, -0.68, 0.48, 1.682 }
local ACTIVE_MS = 400
-- In HyDE's CSS a button that loses `.active` takes the base rule's (absent)
-- transition and snaps narrow at once. Animating it too keeps the row from
-- jumping; set 0 for HyDE's snap.
local DEACTIVATE_MS = 400
local PRESENT_MS = 400 -- grow-in / shrink-out (HyDE has none; same curve and length as .active)
local HOVER_MS = 300
local HOVER_ALPHA = 0.4 -- HyDE's wb-hvr-bg is an accent at 40 % alpha
-- The built-in widget picks text readable on the pill's fill; on the
-- transparent inactive fill that is white.
local INACTIVE_TEXT = "#ffffff"

local PILL_HEIGHT = 16
local INACTIVE_SIZE = 1.0
local ACTIVE_SIZE = 2.2
local PADDING = PILL_HEIGHT * 0.6
local GAP = 4
local FONT_PX = 11 * 1.3
local CHAR_WIDTH = 0.6 -- JetBrains Mono advance per em; no text measuring in the plugin API

-- barWidget.outputName() and isVertical() need the bar snapshot that only the
-- load chunk and update() carry; state.watch callbacks get nil. Keep copies.
local output = nil
local vertical = false

local pills = {}      -- id -> pill; also kept in `order`
local order = {}      -- pills sorted by id, including ones shrinking out
local hovered = nil   -- id under the pointer
local lastSignature = nil
local ticking = false
local frames = 0      -- frames drawn, for the status IPC

local function rememberBar()
  local name = barWidget.outputName()
  if name ~= nil and name ~= "" then
    output = name
    vertical = barWidget.isVertical() and true or false
  end
end

-- cubic-bezier(x1, y1, x2, y2) as CSS defines it: solve x(t) = progress for t
-- (Newton, bisection fallback), return y(t). x is monotonic because x1 and x2
-- lie in [0, 1]; y overshoots both ends with this curve.
local function bezier(progress)
  local x1, y1, x2, y2 = CURVE[1], CURVE[2], CURVE[3], CURVE[4]
  local function sample(a1, a2, t)
    local u = 1 - t
    return 3 * u * u * t * a1 + 3 * u * t * t * a2 + t * t * t
  end
  local t = progress
  for _ = 1, 8 do
    local err = sample(x1, x2, t) - progress
    if math.abs(err) < 1e-5 then
      return sample(y1, y2, t)
    end
    local u = 1 - t
    local slope = 3 * u * u * x1 + 6 * u * t * (x2 - x1) + 3 * t * t * (1 - x2)
    if math.abs(slope) < 1e-6 then
      break
    end
    t = t - err / slope
  end
  local lo, hi = 0, 1
  t = progress
  for _ = 1, 30 do
    local x = sample(x1, x2, t)
    if math.abs(x - progress) < 1e-5 then
      break
    end
    if x < progress then
      lo = t
    else
      hi = t
    end
    t = (lo + hi) / 2
  end
  return sample(y1, y2, t)
end

local function channel(value)
  return { from = value, to = value, start = 0, duration = 0 }
end

local function valueOf(ch, now)
  if ch.duration <= 0 or now >= ch.start + ch.duration then
    return ch.to
  end
  local progress = math.max(0, (now - ch.start) / ch.duration)
  return ch.from + (ch.to - ch.from) * bezier(progress)
end

local function moving(ch, now)
  return ch.duration > 0 and now < ch.start + ch.duration
end

local function retarget(ch, to, duration, now)
  if ch.to == to then
    return
  end
  ch.from = valueOf(ch, now)
  ch.to = to
  ch.start = now
  ch.duration = duration
end

local function clamp01(v)
  return math.min(1, math.max(0, v))
end

-- Colours: settled pills use palette role tokens, which the host resolves
-- live (a theme change needs no re-render). Moving ones blend hex values read
-- once per frame.
local function rgb(hex)
  hex = hex or "#000000"
  return tonumber(hex:sub(2, 3), 16) or 0, tonumber(hex:sub(4, 5), 16) or 0, tonumber(hex:sub(6, 7), 16) or 0
end

local function mix(a, b, t)
  local ar, ag, ab = rgb(a)
  local br, bg, bb = rgb(b)
  return string.format("#%02x%02x%02x",
    math.floor(ar + (br - ar) * t + 0.5), math.floor(ag + (bg - ag) * t + 0.5), math.floor(ab + (bb - ab) * t + 0.5))
end

-- The host scales a label's fontSize by the bar's font_scale (0.75 here), as
-- the built-in widget's numbers are. Widgets cannot ask which bar they are
-- on, so this reads the default bar's.
local barFontScale = tonumber(noctalia.getSetting("bar.default.font_scale")) or 1

local function textWidth(label)
  return #label * FONT_PX * barFontScale * CHAR_WIDTH
end

local function focusWorkspace(id)
  -- Hyprland 0.56 Lua config: legacy `hyprctl dispatch workspace N` is gone.
  noctalia.runAsync({ "hyprctl", "eval", "hl.dispatch(hl.dsp.focus({ workspace = " .. tostring(id) .. " }))" })
end

local function startTicking()
  if not ticking then
    ticking = true
    noctalia.setUpdateInterval(FRAME_MS)
  end
end

local function onHover(id, state)
  local now = noctalia.nowMs()
  if state == "true" then
    hovered = id
  elseif hovered == id then
    hovered = nil
  end
  for pid, pill in pairs(pills) do
    retarget(pill.hover, (pid == hovered) and 1 or 0, HOVER_MS, now)
  end
  startTicking()
end

local function render(now)
  local palette = nil
  local container = vertical and ui.column or ui.row
  local children = {}
  local before = 0 -- visible extent of the pills drawn so far, for the gaps
  local animating = false

  for _, pill in ipairs(order) do
    local present = valueOf(pill.present, now)
    local active = valueOf(pill.active, now)
    local hover = valueOf(pill.hover, now)
    local still = not (moving(pill.present, now) or moving(pill.active, now) or moving(pill.hover, now))
    animating = animating or not still

    local inactiveWidth = math.max(PILL_HEIGHT * INACTIVE_SIZE, pill.textWidth + PADDING)
    local activeWidth = math.max(PILL_HEIGHT * ACTIVE_SIZE, pill.textWidth + PADDING)
    local length = math.max(0, present * (inactiveWidth + (activeWidth - inactiveWidth) * active))
    local visible = clamp01(present)
    -- Rows do not clip their children, so a digit wider than its growing or
    -- shrinking pill would spill out. It fades in between "just fits" and the
    -- full inactive width instead.
    local labelOpacity = 1
    if pill.present.to == 0 or moving(pill.present, now) then
      labelOpacity = clamp01((length - pill.textWidth) / math.max(1, inactiveWidth - pill.textWidth))
    end

    local gap = GAP * math.min(before, visible)
    before = math.min(1, before + visible)
    if gap > 0.01 then
      table.insert(children, ui.box({
        key = "gap" .. pill.id,
        fill = "#00000000",
        width = vertical and PILL_HEIGHT or gap,
        height = vertical and gap or PILL_HEIGHT,
      }))
    end

    if length > 0.01 then
      local fill, color
      if still then
        if pill.active.to == 1 then
          fill, color = "primary", "on_primary"
        elseif pill.hover.to == 1 then
          fill, color = "primary/" .. HOVER_ALPHA, INACTIVE_TEXT
        else
          fill, color = "#00000000", INACTIVE_TEXT
        end
      else
        if palette == nil then
          palette = {
            primary = noctalia.getColor("primary"),
            onPrimary = noctalia.getColor("on_primary"),
          }
        end
        local a = clamp01(active)
        local alpha = a + (1 - a) * HOVER_ALPHA * clamp01(hover)
        fill = string.format("%s%02x", palette.primary or "#000000", math.floor(clamp01(alpha) * 255 + 0.5))
        color = mix(INACTIVE_TEXT, palette.onPrimary, a)
      end
      local id = pill.id
      table.insert(children, ui.row({
        key = "ws" .. id,
        width = vertical and PILL_HEIGHT or length,
        height = vertical and length or PILL_HEIGHT,
        radius = math.min(length, PILL_HEIGHT) / 2,
        fill = fill,
        opacity = visible,
        align = "center",
        justify = "center",
        onClick = function()
          focusWorkspace(id)
        end,
        onHover = function(state)
          onHover(id, state)
        end,
      }, {
        ui.label({ text = pill.label, fontSize = FONT_PX, color = color, opacity = labelOpacity }),
      }))
    end
  end

  barWidget.render(container({ gap = 0, align = "center" }, children))
  frames = frames + 1
  return animating
end

-- Drop pills that finished shrinking out.
local function prune(now)
  local kept = {}
  for _, pill in ipairs(order) do
    if pill.present.to == 0 and not moving(pill.present, now) then
      pills[pill.id] = nil
      if hovered == pill.id then
        hovered = nil
      end
    else
      table.insert(kept, pill)
    end
  end
  order = kept
end

local function apply(entry)
  local ids = (type(entry) == "table" and type(entry.ids) == "table") and entry.ids or {}
  local active = type(entry) == "table" and tonumber(entry.active) or nil
  local signature = tostring(active) .. ":" .. table.concat(ids, ",")
  if signature == lastSignature then
    return
  end
  local first = lastSignature == nil -- first data: draw settled, no grow-in
  lastSignature = signature
  local now = noctalia.nowMs()

  local wanted = {}
  for _, raw in ipairs(ids) do
    local id = tonumber(raw)
    -- Special workspaces never show, whatever the service sent.
    if id ~= nil and id >= 1 then
      wanted[id] = true
    end
  end

  for id in pairs(wanted) do
    if pills[id] == nil then
      local label = tostring(id)
      local pill = {
        id = id,
        label = label,
        textWidth = textWidth(label),
        present = channel(first and 1 or 0),
        active = channel((first and id == active) and 1 or 0),
        hover = channel(0),
      }
      pills[id] = pill
      table.insert(order, pill)
    end
  end
  table.sort(order, function(a, b)
    return a.id < b.id
  end)

  for id, pill in pairs(pills) do
    retarget(pill.present, wanted[id] and 1 or 0, PRESENT_MS, now)
    local isActive = wanted[id] and id == active
    retarget(pill.active, isActive and 1 or 0, isActive and ACTIVE_MS or DEACTIVATE_MS, now)
  end

  if next(pills) == nil then
    barWidget.setVisible(false)
    return
  end
  barWidget.setVisible(true)
  if first then
    render(now)
  else
    startTicking()
  end
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
  apply(workspaces[output])
end

noctalia.state.watch("workspaces", applyState)

function update()
  rememberBar()
  if ticking then
    local now = noctalia.nowMs()
    local animating = render(now)
    prune(now)
    if not animating then
      ticking = false
      noctalia.setUpdateInterval(RECHECK_MS)
      if next(pills) == nil then
        barWidget.setVisible(false)
      end
    end
    return
  end
  noctalia.setUpdateInterval(RECHECK_MS)
  applyState(noctalia.state.get("workspaces"))
end

-- `noctalia msg plugin roynul/workspace-pills:pills <output|all> status` logs
-- which output this bar follows, its pills and how many frames it has drawn.
function onIpc(event)
  if event == "status" then
    local ids = {}
    for _, pill in ipairs(order) do
      ids[#ids + 1] = tostring(pill.id)
    end
    noctalia.log(string.format("pills: output=%s vertical=%s ticking=%s frames=%d pills=%s",
      tostring(output), tostring(vertical), tostring(ticking), frames, table.concat(ids, ",")))
  end
end

rememberBar()
applyState(noctalia.state.get("workspaces"))
