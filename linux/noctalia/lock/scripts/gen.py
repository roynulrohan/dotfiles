# Generates the lock screen's config, ~/.config/noctalia/lock.toml (or the path in
# the second argument). usage: gen.py params.json [out.toml]
# Noctalia merges every *.toml in ~/.config/noctalia, so this file sits next to
# config.toml. Paths in it are absolute, so the generated file is not tracked.
import os, sys, json, subprocess
LOCK = os.path.expanduser("~/.local/share/noctalia/lock")
OUT = sys.argv[2] if len(sys.argv) > 2 else os.path.expanduser("~/.config/noctalia/lock.toml")
W = []  # (id, table)
def w(id_, type_, out, cx, cy, bw, bh, settings, enabled=True):
    W.append((f"{id_}@{out}", dict(type=type_, output=out, cx=cx, cy=cy, box_width=bw, box_height=bh, enabled=enabled), settings))
def card(id_, out, cx, cy, bw, bh, color, opacity, radius):
    w(id_, "label", out, cx, cy, bw, bh, dict(title=" ", description="", shadow=False, background=True,
      background_color=color, background_opacity=opacity, background_radius=radius, background_padding=0.0))
def text(id_, out, cx, cy, bw, bh, title, color="on_surface", opacity=1.0, font="", shadow=False, bold=False):
    s = dict(title=title if bold else "", description="" if bold else title, color=color, opacity=opacity, shadow=shadow, background=False)
    if font: s["font_family"] = font
    w(id_, "label", out, cx, cy, bw, bh, s)
P = json.load(open(sys.argv[1]))  # tunables
GSF, MONO, CLOCK = "Google Sans Flex", "CaskaydiaCove NF", "GSF Lock Clock"
RR, PAD = 28.0, 16.0  # one radius and padding for every inner card and tile
C = P["container"]; CA = P["container_alpha"]

def clock_group(out, dx, dy, shadow):
    # caelestia center/Clock.qml at 1080p: hours 224 px primary, minutes 121 px secondary,
    # AM/PM chip under the minutes. Group spans x 829..1092 when centred at 960.
    g = P["clock"]
    w("lock-hours", "clock", out, g["h_cx"]+dx, g["h_cy"]+dy, g["h_w"], g["h_h"],
      dict(format="{:%I}", center_text=True, color="primary", font_family=CLOCK, shadow=shadow, background=False))
    w("lock-minutes", "clock", out, g["m_cx"]+dx, g["m_cy"]+dy, g["m_w"], g["m_h"],
      dict(format="{:%M}", center_text=True, color="secondary", font_family=CLOCK, shadow=shadow, background=False))
    # On bare wallpaper (side monitors) the chip needs a real surface fill to stay readable.
    card("lock-ampm-chip", out, g["p_cx"]+dx, g["p_cy"]+dy, g["p_w"], g["p_h"],
         "surface" if shadow else C, P["side_chip_alpha"] if shadow else P["chip_alpha"], 16.0)
    w("lock-ampm", "clock", out, g["p_cx"]+dx, g["p_cy"]+dy+g["p_tdy"], g["p_w"], g["p_th"],
      dict(format="{:%p}", center_text=True, color="on_surface", font_family=CLOCK, shadow=shadow, background=False))
    w("lock-date", "clock", out, 960.0+dx, g["d_cy"]+dy, g["d_w"], g["d_h"],
      dict(format="{:%^A • %-d %^b}", center_text=True, color="on_surface", font_family=GSF, shadow=shadow, background=False))

M = "DP-1"
K = P["card"]  # caelestia's card, enlarged: 1500x840, content inset 32
card("lock-card", M, 960.0, 540.0, K["w"], K["h"], "surface", 1.0, 32.0)
top = 540.0 - K["h"]/2 + 32.0; bottom = 540.0 + K["h"]/2 - 32.0
side_w = (K["w"] - 64.0 - 450.0 - 80.0) / 2
L = 960.0 - 225.0 - 40.0 - side_w/2; R = 960.0 + 225.0 + 40.0 + side_w/2
G = 12.0  # caelestia spacing.medium between stacked cards
# Left column: time and place. Weather with a short forecast, then a month grid (no events on the lock screen).
# The weather widget (5.2.1) lays out a fixed frame, 180 units wide by 72 + 6 + 20 per forecast
# day tall, with left-aligned text that ends near 130 units, and centres that frame in its box.
# Drawn on its own background, its right side stays empty. So the card is a label here, and the
# widget gets a background-less box of the frame's exact shape, scaled to the card's inner height
# and shifted so that weather_text_w units of text sit centred in the card. The box clips, but it
# is transparent past the text, so it may overhang the card.
wh = P["weather_h"]
card("lock-weather-card", M, L, top + wh/2, side_w, wh, C, CA, RR)
fw, fh = 180.0, 72.0 + 6.0 + 20.0*P["forecast_days"]
ws = (wh - 2*PAD) / fh
wx0 = L - P["weather_text_w"]*ws/2
w("lock-weather", "weather", M, wx0 + fw*ws/2, top + wh/2, fw*ws, fh*ws,
  dict(show_forecast=True, forecast_days=P["forecast_days"], color="primary", font_family=GSF, shadow=False, background=False))
ch = bottom - (top + wh + G)
w("lock-calendar", "calendar", M, L, bottom - ch/2, side_w, ch,
  dict(show_events=False, show_week_numbers=False, font_family=GSF, background=True,
       background_color=C, background_opacity=CA, background_radius=RR, background_padding=PAD))
# Centre column: unchanged caelestia centre, shifted for the taller card.
clock_group(M, 0.0, P["center_dy"], False)
if P.get("viz", True):
    w("lock-viz", "fancy_audio_visualizer", M, 960.0, P["avatar_cy"], P["viz_size"], P["viz_size"],
      dict(visualization_mode=P["viz_mode"], inner_diameter=P["viz_inner"], bar_width=0.5, sensitivity=1.3,
           rotation_speed=0.2, bloom_intensity=0.3, ring_opacity=0.6, fade_when_idle=True,
           primary_color="primary", secondary_color="secondary", background=False))
w("lock-avatar", "sticker", M, 960.0, P["avatar_cy"], 315.0, 215.0,
  dict(image_path=f"{LOCK}/avatar-clamshell.png", opacity=1.0, background=False))
# Right column: the machine. Load tiles, temperature and network graphs, then a GIF.
# The GIF card has one fixed shape, the column width by gif_h, bottom-aligned; the tiles
# and graphs share the height above it in proportion to their base sizes.
th0, gh0 = P["tile"] + 32.0, P["graphs_h"]
mw, mh = side_w, P["gif_h"]
avail = bottom - mh - G - top - G
th = float(round(th0*avail/(th0 + gh0)))
card("lock-res-card", M, R, top + th/2, side_w, th, C, CA, RR)
gap = (side_w - 32.0 - 3*P["tile"]) / 2
for i, (stat, role) in enumerate([("cpu_usage", "primary"), ("ram_pct", "tertiary"), ("gpu_usage", "secondary")]):
    w(f"lock-res{i}", "sysmon", M, R - side_w/2 + 16.0 + P["tile"]/2 + i*(P["tile"] + gap), top + th/2, P["tile"], th - 32.0,
      dict(display="gauge", gauge_layout="vertical", stat=stat, color=role, show_label=True, font_family=GSF, shadow=False,
           background=True, background_color=role, background_opacity=P["res_alpha"], background_radius=RR,
           background_padding=P["res_pad"]))
gy = top + th + G; gh = avail - th
card("lock-graphs-card", M, R, gy + gh/2, side_w, gh, C, CA, RR)
hw2 = (side_w - 32.0 - G) / 2  # two graphs side by side: their natural shape is about 2:1
for i, (title, stat, stat2) in enumerate([("Temps", "cpu_temp", "gpu_temp"), ("Network", "net_rx", "net_tx")]):
    x0 = R - side_w/2 + 16.0 + i*(hw2 + G)
    tw = len(title) * 9.6 + 4.0
    text(f"lock-graph{i}-title", M, x0 + 4.0 + tw/2, gy + 26.0, tw, 20.0, title, color="outline", font=MONO)
    w(f"lock-graph{i}", "sysmon", M, x0 + hw2/2, gy + 40.0 + (gh - 56.0)/2, hw2, gh - 56.0,
      dict(display="graph", stat=stat, stat2=stat2, color="primary", color2="tertiary", show_label=True,
           network_speed_compact=True, font_family=GSF, shadow=False, background=False))
# GIF: the sticker draws current.gif, a random GIF from ~/Pictures/lock-gifs that
# reroll.py cover-fits to the card with rounded transparent corners; the card under it
# shows only there. reroll.py runs once now and again after every unlock (the hook below).
mcy = bottom - mh/2
card("lock-gif-card", M, R, mcy, mw, mh, C, CA, RR)
w("lock-gif", "sticker", M, R, mcy, mw, mh,
  dict(image_path=f"{LOCK}/current.gif", opacity=1.0, background=False))
REROLL = f"python3 -I {LOCK}/scripts/reroll.py {mw:g} {mh:g} {RR:g}"
subprocess.run(REROLL.split(), check=True, stdout=sys.stderr)
# Side monitors: the clock group and date, centred, over the blurred wallpaper.
for out in ["DP-2", "HDMI-A-1"]:
    clock_group(out, 0.0, P["side_dy"], True)
LB = dict(layout="compact", show_session_buttons=False, show_media=False, show_weather=False, show_login_button=True,
          show_caps_lock=True, show_keyboard_layout=False, show_unlock_hint=False, center_password_text=P["center_pw"],
          background_color="surface", background_opacity=P["login_alpha"], background_radius=32.0,
          input_opacity=P["input_alpha"], input_radius=19.0)
w("lockscreen-login-box", "login_box", M, 960.0, P["login_cy"], P["login_w"], 70.0, LB)
for out in ["DP-2", "HDMI-A-1"]:
    w("lockscreen-login-box", "login_box", out, 960.0, 898.0, P["login_w"], 70.0, LB, enabled=False)

def val(v):
    if isinstance(v, bool): return "true" if v else "false"
    if isinstance(v, float): return repr(v)
    if isinstance(v, int): return f"{float(v)!r}"
    return json.dumps(v, ensure_ascii=False)
o = []
o.append("""# Lock screen, modelled on caelestia's (caelestia-shell modules/lock, tokens at
# 1080p): one surface card (caelestia: 0.7 x screen height, 16:9) on the blurred
# wallpaper, never a snapshot of the desktop (a lock screen shouldn't show what
# was on screen).
# Card enlarged to 1500x840. Left: weather + 3-day forecast, month calendar
# (no events). Centre: hours/minutes/AM-PM clock in condensed Google Sans Flex,
# date, ClamShell avatar with an audio ring that fades when idle, pill password
# field. Right: CPU/RAM/GPU tiles, temperature and network graphs, a random GIF
# from ~/Pictures/lock-gifs, a new one after every unlock (hook at the end).
# Widgets draw in widget_order, so the card comes first. Side monitors: the
# clock group only. Generated by ~/.local/share/noctalia/lock/scripts/gen.py from
# params.json; edit those and run apply.sh, not this file.
# Assets: ~/.local/share/noctalia/lock (avatar from ~/.face, GIF cards) and
# ~/.local/share/fonts/google-sans-flex (GSF Lock Clock = wdth 30, wght 500).
[lockscreen]
blurred_desktop = false
blur_intensity = %s
tint_intensity = %s
# No lock/unlock animation: an animated lock fades in from a frozen capture of
# the desktop, which could show what was on screen.
transition = []
""" % (P["blur"], P["tint"]))
o.append("[lockscreen_widgets]\nenabled = true")
o.append("widget_order = [\n" + "".join(f'  "{i}",\n' for i, _, _ in W) + "]\n")
for i, t, s in W:
    o.append(f'[lockscreen_widgets.widget."{i}"]')
    for k in ["type", "output", "cx", "cy", "box_width", "box_height"]:
        o.append(f"{k} = {val(t[k])}")
    o.append("rotation = 0.0\nplacement_width = 1920.0\nplacement_height = 1080.0")
    if not t["enabled"]: o.append("enabled = false")
    o.append("")
    o.append(f'[lockscreen_widgets.widget."{i}".settings]')
    for k, v in s.items(): o.append(f"{k} = {val(v)}")
    o.append("")
o.append("[hooks]\nsession_unlocked = " + val(REROLL))
# Write atomically: Noctalia watches its config directory, and a half-written file
# parses without [lockscreen_widgets] (see apply.sh). The temporary name doesn't end
# in .toml, so Noctalia never loads it.
tmp = f"{OUT}.{os.getpid()}.tmp"
with open(tmp, "w") as f:
    f.write("\n".join(o) + "\n")
os.replace(tmp, OUT)
