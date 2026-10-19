# Generates the lock screen's config, ~/.config/noctalia/lock.toml (or the path in
# the second argument). usage: gen.py params.json [out.toml]
# Noctalia merges every *.toml in ~/.config/noctalia, so this file sits next to
# config.toml. Paths in it are absolute, so the generated file is not tracked.
import os, pwd, sys, json, subprocess
LOCK = os.path.expanduser("~/.local/share/noctalia/lock")
# Your own avatar, not in the repo: a transparent PNG, already cut to shape.
AVATAR = os.path.expanduser("~/Pictures/lock-avatar.png")
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
GSF, CLOCK = "Google Sans Flex", "GSF Lock Clock"
RR, PAD = 28.0, 16.0  # one radius and padding for every inner card and tile
C = P["container"]; CA = P["container_alpha"]

def clock_group(out, dx, dy, shadow):
    # Hours in primary, minutes in secondary, the AM/PM chip under the minutes.
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
K = P["card"]  # content inset 32 from the card's edges
# Frosted like the login screen's card: the blurred wallpaper shows through.
# Widgets draw in widget_order, so the card goes first.
card("lock-card", M, 960.0, 540.0, K["w"], K["h"], "surface", P["card_alpha"], 32.0)
top = 540.0 - K["h"]/2 + 32.0; bottom = 540.0 + K["h"]/2 - 32.0
side_w = (K["w"] - 64.0 - 450.0 - 80.0) / 2
L = 960.0 - 225.0 - 40.0 - side_w/2; R = 960.0 + 225.0 + 40.0 + side_w/2
G = 12.0  # between stacked cards
# Left column: time and place. Weather with a short forecast, then a month grid (no events on the lock screen).
# The weather widget lays out a fixed frame, 180 units wide by 72 + 6 + 20 per forecast
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
# Centre column: the clock group, the avatar with its audio ring, the login name.
clock_group(M, 0.0, P["center_dy"], False)
if P.get("viz", True):
    w("lock-viz", "fancy_audio_visualizer", M, 960.0, P["avatar_cy"], P["viz_size"], P["viz_size"],
      dict(visualization_mode=P["viz_mode"], inner_diameter=P["viz_inner"], bar_width=0.5, sensitivity=1.3,
           rotation_speed=0.2, bloom_intensity=0.3, ring_opacity=0.6, fade_when_idle=True,
           primary_color="primary", secondary_color="secondary", background=False))
w("lock-avatar", "sticker", M, 960.0, P["avatar_cy"], 315.0, 215.0,
  dict(image_path=AVATAR, opacity=1.0, background=False))
# The login name under the avatar.
NAME = pwd.getpwuid(os.getuid()).pw_name
text("lock-name", M, 960.0, P["avatar_cy"] + P["name_dy"], 320.0, P["name_h"], NAME, font=GSF, bold=True)
# Right column, laid out as on the login screen (linux/sddm, LoginScreen.qml): a GIF on
# top, the machine's load where the login has its session card, power buttons below.
# GIF: the sticker draws current.gif, a random GIF from ~/Pictures/lock-gifs that
# reroll.py cover-fits to the card with rounded transparent corners; the card under it
# shows only there. reroll.py runs once now and again after every unlock (the hook below).
mw, mh = side_w, P["gif_h"]
mcy = top + mh/2
card("lock-gif-card", M, R, mcy, mw, mh, C, CA, RR)
w("lock-gif", "sticker", M, R, mcy, mw, mh,
  dict(image_path=f"{LOCK}/current.gif", opacity=1.0, background=False))
REROLL = f"python3 -I {LOCK}/scripts/reroll.py {mw:g} {mh:g} {RR:g}"
subprocess.run(REROLL.split(), check=True, stdout=sys.stderr)
# Power row: Suspend, Reboot, Shut down, as in the login's PowerRow.qml (three cards,
# 12 apart). The button widget puts its glyph and label side by side, scaled to the box
# height. So each card gets a glyph-only button in its upper part and a text label under
# it, as on the login. Box height 104 makes the glyph about the login's 34 px. The label
# takes no clicks. Tabler's moon stands in for the login's bedtime glyph, because
# Noctalia's own "suspend" glyph is a pause sign.
ph = P["power_h"]; pw = (side_w - 2*G) / 3; pcy = bottom - ph/2
for i, (glyph, label, action) in enumerate([("moon", "Suspend", "suspend"), ("reboot", "Reboot", "reboot"),
                                            ("shutdown", "Shut down", "shutdown")]):
    x = R - side_w/2 + pw/2 + i*(pw + G)
    card(f"lock-power{i}-card", M, x, pcy, pw, ph, C, CA, RR)
    # These offsets centre the glyph and the label in the card, 12 px apart.
    w(f"lock-power{i}", "button", M, x, pcy - ph/2 + 40.0, pw, 104.0,
      dict(glyph=glyph, label="", command=f"noctalia msg session {action}", color="primary", background=False))
    text(f"lock-power{i}-label", M, x, pcy - ph/2 + 79.0, pw, 23.0, label, font=GSF)
# The machine's load between them, in the login's session card slot.
ty = top + mh + G; th = bottom - ph - G - ty
card("lock-res-card", M, R, ty + th/2, side_w, th, C, CA, RR)
gap = (side_w - 32.0 - 3*P["tile"]) / 2
for i, (stat, role, name) in enumerate([("cpu_usage", "primary", "CPU"), ("ram_pct", "tertiary", "RAM"),
                                        ("gpu_usage", "secondary", "GPU")]):
    x = R - side_w/2 + 16.0 + P["tile"]/2 + i*(P["tile"] + gap)
    w(f"lock-res{i}", "sysmon", M, x, ty + th/2, P["tile"], th - 32.0,
      dict(display="gauge", gauge_layout="vertical", stat=stat, color=role, show_label=True, font_family=GSF, shadow=False,
           background=True, background_color=role, background_opacity=P["res_alpha"], background_radius=RR,
           background_padding=P["res_pad"]))
    # The gauge draws its icon, bar and percentage in the middle of the tile and leaves
    # about 60 px free at the bottom; the name goes there, styled like the power labels.
    text(f"lock-res{i}-label", M, x, ty + th - 16.0 - 30.0, P["tile"], 23.0, name, font=GSF)
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
o.append("""# The lock screen. Generated by ~/.local/share/noctalia/lock/scripts/gen.py
# from params.json. Edit those and run apply.sh, not this file.
[lockscreen]
# The blurred wallpaper, never a snapshot of the desktop: a lock screen must
# not show what was on screen.
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
# Write atomically: Noctalia watches its config directory. A half-written file parses
# without [lockscreen_widgets], and the lock controller then saves an "enabled = false"
# copy to settings.toml, which overrides every config file. The temporary name doesn't
# end in .toml, so Noctalia never loads it.
tmp = f"{OUT}.{os.getpid()}.tmp"
with open(tmp, "w") as f:
    f.write("\n".join(o) + "\n")
os.replace(tmp, OUT)
