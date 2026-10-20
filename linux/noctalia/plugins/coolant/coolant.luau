-- Reads the cooling state from OpenLinkHub's API every 3 seconds. The hub and
-- the AIO are found by product name, so no serial number is stored here.
-- The widget stays monotone like the other stats. From AMBER on it turns
-- amber, then red at RED, the same points as the pump's lighting
-- (linux/openlinkhub, Pump lighting).

local AMBER, RED = 38, 41
local C_AMBER, C_RED = { 0xff, 0xb3, 0x47 }, { 0xff, 0x6b, 0x6b }

local READ = [[
import json, urllib.request
api = "http://127.0.0.1:27003/api/devices/"
def get(product):
    keys = {v["Product"]: k for k, v in json.load(urllib.request.urlopen(api, timeout=2))["devices"].items()}
    if product not in keys:
        return {}
    return json.load(urllib.request.urlopen(api + keys[product], timeout=2)).get("device", {}).get("devices", {})
aio = get("iCUE H100i RGB PRO XT")
hub = get("COMMANDER CORE XT")
def out(name, dev, ch, field):
    if ch in dev:
        print(name, dev[ch][field])
out("coolant", aio, "0", "temperature")
out("pump", aio, "0", "rpm")
out("top", hub, "4", "rpm")
out("under", aio, "1", "rpm")
out("rear", hub, "0", "rpm")
out("bottom", hub, "1", "rpm")
out("front", hub, "3", "rpm")
out("air", hub, "6", "temperature")
]]

local function mix(a, b, t)
  local c = {}
  for i = 1, 3 do c[i] = math.floor(a[i] + (b[i] - a[i]) * t + 0.5) end
  return string.format("#%02x%02x%02x", c[1], c[2], c[3])
end

-- Only called from AMBER up: amber at AMBER, red from RED on.
local function colourFor(t)
  return mix(C_AMBER, C_RED, math.max(0, math.min(1, (t - AMBER) / (RED - AMBER))))
end

local function show(result)
  local v = {}
  for key, value in string.gmatch(result.stdout or "", "(%a+) ([%d%.]+)") do v[key] = tonumber(value) end
  if result.exitCode ~= 0 or v.coolant == nil then
    barWidget.setGlyphColor("on_surface")
    barWidget.setText("--")
    barWidget.setTooltip(result.exitCode ~= 0 and "OpenLinkHub is not answering"
      or "OpenLinkHub doesn't see the H100i: restart it, or reboot")
    return
  end
  local t = v.coolant
  -- Monotone like the other stats; amber to red only past AMBER.
  local c = t >= AMBER and colourFor(t) or "on_surface"
  barWidget.setGlyphColor(c)
  barWidget.setColor(c)
  barWidget.setText(string.format("%.1f°C", t))
  local rows = { { "Coolant", string.format("%.1f °C", t) } }
  local function row(label, key, fmt)
    rows[#rows + 1] = { label, v[key] and string.format(fmt, v[key]) or "not seen" }
  end
  row("Case air", "air", "%.1f °C")
  row("Pump", "pump", "%d RPM")
  row("Radiator, top", "top", "%d RPM")
  row("Radiator, under", "under", "%d RPM")
  row("Rear", "rear", "%d RPM")
  row("Bottom intakes", "bottom", "%d RPM")
  row("Front intakes", "front", "%d RPM")
  barWidget.setTooltip(rows)
end

function update()
  noctalia.setUpdateInterval(3000)
  barWidget.setGlyph("droplet")
  noctalia.runAsync({ "/usr/bin/python3", "-I", "-c", READ }, show)
end

function onClick()
  noctalia.runAsync({ "xdg-open", "http://127.0.0.1:27003" })
end
