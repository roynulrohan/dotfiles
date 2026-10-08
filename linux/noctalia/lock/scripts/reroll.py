# Puts a random GIF from ~/Pictures/lock-gifs on the lock screen's GIF card.
# usage: reroll.py <width> <height> <radius>   (gen.py passes the card's size)
# Noctalia runs it from the session_unlocked hook that gen.py writes. The lock
# screen builds its widgets again at every lock, and the sticker then reads
# current.gif from disk, so swapping the link is enough: no config change, no reload.
import os, sys, random, hashlib, subprocess
W, H, R = sys.argv[1:4]
SRC = os.path.expanduser("~/Pictures/lock-gifs")
LOCK = os.path.expanduser("~/.local/share/noctalia/lock")
CUR, CARDS = f"{LOCK}/current.gif", f"{LOCK}/cards"

def card_path(name):
    # Keyed by the source's content, so an edited or replaced GIF renders again.
    digest = hashlib.sha1(open(f"{SRC}/{name}", "rb").read()).hexdigest()[:12]
    return f"{CARDS}/{os.path.splitext(name)[0]}-{digest}-{W}x{H}-r{R}.gif"

def render(src, out):
    # Cover the card (lanczos), centre crop, then cut the rounded corners into the GIF's
    # own transparency: the sticker has no corner radius and clips with a plain rectangle.
    # 1-bit, so a pixel is kept when its centre is inside the rounded rectangle.
    mask = f"lte(hypot(X+0.5-clip(X+0.5,{R},W-{R}),Y+0.5-clip(Y+0.5,{R},H-{R})),{R})"
    tmp = f"{out}.{os.getpid()}.tmp.gif"
    subprocess.run(["ffmpeg", "-v", "error", "-y", "-i", src, "-filter_complex",
                    f"[0:v]scale={W}:{H}:force_original_aspect_ratio=increase:flags=lanczos,crop={W}:{H},"
                    f"format=rgba,geq=r='r(X,Y)':g='g(X,Y)':b='b(X,Y)':a='alpha(X,Y)*{mask}',"
                    "split[a][b];[a]palettegen=reserve_transparent=1[p];[b][p]paletteuse=alpha_threshold=128",
                    "-loop", "0", tmp], check=True, stdin=subprocess.DEVNULL)
    os.replace(tmp, out)

gifs = [f for f in os.listdir(SRC) if f.lower().endswith(".gif")]
if not gifs:
    sys.exit(f"no GIFs in {SRC}; current.gif stays as it is")
random.shuffle(gifs)
# Never the same card twice in a row, unless it is the only one.
current = os.path.realpath(CUR)
for name in gifs:
    out = card_path(name)
    if out != current:
        break
os.makedirs(CARDS, exist_ok=True)
if not os.path.exists(out):
    render(f"{SRC}/{name}", out)
# Swap atomically: a lock that starts now sees the old card or the new one, never neither.
tmp = f"{CUR}.{os.getpid()}.tmp"
os.symlink(out, tmp)
os.replace(tmp, CUR)
print(out)
