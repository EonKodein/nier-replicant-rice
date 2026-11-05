#!/usr/bin/env python3
"""Procedural NieR-inspired wallpaper: weathered stone with a worn, carved seal.
Entirely original artwork (no game assets). Usage: gen-wallpaper.py OUT.png [cinzel.ttf]"""
import math, random, sys
import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageFont

W, H, SS = 3840, 2160, 2
OUT = sys.argv[1]
FONT = sys.argv[2] if len(sys.argv) > 2 else None
rng = np.random.default_rng(1224744)
random.seed(1224744)

def fbm(octaves, base, persistence=0.55):
    out, amp, total = np.zeros((H, W), np.float32), 1.0, 0.0
    for o in range(octaves):
        cells = base * 2 ** o
        h = max(2, int(cells * H / W))
        small = (rng.random((h + 1, cells + 1), dtype=np.float32) * 255).astype(np.uint8)
        big = Image.fromarray(small).resize((W, H), Image.BICUBIC)
        out += np.asarray(big, np.float32) / 255 * amp
        total += amp
        amp *= persistence
    return out / total

def norm(a):
    return (a - a.min()) / (a.max() - a.min())

# --- stone -----------------------------------------------------------------
broad, mid = norm(fbm(5, 4)), norm(fbm(6, 18))
stone = np.clip(0.60 * broad + 0.40 * mid, 0, 1)
cr1 = np.abs(norm(fbm(6, 7)) - 0.5)
cr2 = np.abs(norm(fbm(5, 13)) - 0.5)
cracks = np.clip(1 - cr1 / 0.0065, 0, 1) ** 2 * np.clip(norm(fbm(3, 3)) * 1.5 - 0.3, 0, 1)
cracks += 0.5 * np.clip(1 - cr2 / 0.0040, 0, 1) ** 2 * np.clip(norm(fbm(3, 5)) * 1.4 - 0.4, 0, 1)
cracks = np.clip(cracks, 0, 1)

dark = np.array([0x1a, 0x19, 0x17], np.float32)
light = np.array([0x32, 0x2f, 0x2b], np.float32)
t = np.clip((stone - 0.28) * 1.25, 0, 1)[..., None]
img = dark * 0.80 + (light - dark * 0.80) * t * 0.82
img = img * (1 - cracks[..., None] * 0.62)
y, x = np.mgrid[0:H, 0:W].astype(np.float32)
d = np.sqrt(((x - W / 2) / (W * 0.72)) ** 2 + ((y - H * 0.5) / (H * 0.78)) ** 2)
img *= np.clip(1.12 - d ** 2.1 * 0.95, 0.30, 1.12)[..., None]

# --- seal (drawn large, then worn away by noise) ---------------------------
L = Image.new("L", (W * SS, H * SS), 0)      # bronze line mask
R = Image.new("L", (W * SS, H * SS), 0)      # crimson mask
dl, dr = ImageDraw.Draw(L), ImageDraw.Draw(R)
cx, cy = W * SS / 2, H * SS * 0.5
U = H * SS * 0.335

def ring(draw, r, w, v=255):
    draw.ellipse((cx - r, cy - r, cx + r, cy + r), outline=v, width=int(w))
def pt(r, a):
    return cx + r * math.cos(a), cy + r * math.sin(a)
def poly(draw, r, n, rot, w, v=255, step=1):
    p = [pt(r, rot + 2 * math.pi * i * step / n) for i in range(n + 1)]
    draw.line(p, fill=v, width=int(w), joint="curve")

ring(dl, U, 7); ring(dl, U * 0.975, 3, 150)
ring(dl, U * 0.80, 3, 170); ring(dl, U * 0.785, 6)
for i in range(120):                                   # graduated edge
    a = 2 * math.pi * i / 120 - math.pi / 2
    inner = U * (1.018 if i % 10 else 1.002)
    dl.line([pt(inner, a), pt(U * 1.035, a)], fill=210, width=4 if i % 10 else 7)

# invented angular glyphs on the band: strokes on a small lattice, never real script
LAT = [(x_, y_) for x_ in (-1, 0, 1) for y_ in (-1.4, 0, 1.4)]
NG = 36
band = U * 0.885
gs = U * 0.040
for i in range(NG):
    a = 2 * math.pi * i / NG - math.pi / 2
    ca, sa = math.cos(a + math.pi / 2), math.sin(a + math.pi / 2)
    ox, oy = pt(band, a)
    def P(q): return (ox + (q[0] * ca - q[1] * sa) * gs, oy + (q[0] * sa + q[1] * ca) * gs)
    dl.line([P((0, -1.4)), P((0, 1.4))], fill=225, width=6)
    for _ in range(random.randint(2, 3)):
        p1, p2 = random.sample(LAT, 2)
        if abs(p1[0] - p2[0]) + abs(p1[1] - p2[1]) < 1.1:
            p2 = (-p1[0], -p1[1])
        dl.line([P(p1), P(p2)], fill=225, width=6)

poly(dl, U * 0.77, 4, -math.pi / 2, 4, 180)            # interlaced squares
poly(dl, U * 0.77, 4, -math.pi / 4, 4, 180)
ring(dl, U * 0.545, 4, 190); ring(dl, U * 0.53, 2, 130)
poly(dl, U * 0.53, 7, -math.pi / 2, 4, 200, step=3)    # heptagram: the seven verses
ring(dl, U * 0.205, 5, 225); ring(dl, U * 0.19, 2, 130)
for i in range(7):                                     # seven nodes
    a = 2 * math.pi * i / 7 - math.pi / 2
    x0, y0 = pt(U * 0.53, a)
    s = U * 0.017
    dl.polygon([(x0, y0 - s * 1.5), (x0 + s, y0), (x0, y0 + s * 1.5), (x0 - s, y0)], fill=255)

# the sealed verse: one crimson arc and a central mark
A = U * 0.905
dr.arc((cx - U * 0.66, cy - U * 0.66, cx + U * 0.66, cy + U * 0.66), 200, 305, fill=255, width=10)
dr.arc((cx - U * 0.645, cy - U * 0.645, cx + U * 0.645, cy + U * 0.645), 200, 305, fill=120, width=3)
s = U * 0.055
dr.polygon([(cx, cy - s * 1.7), (cx + s, cy), (cx, cy + s * 1.7), (cx - s, cy)], outline=255, width=8)
s2 = s * 0.42
dr.polygon([(cx, cy - s2 * 1.7), (cx + s2, cy), (cx, cy + s2 * 1.7), (cx - s2, cy)], fill=255)

# small ornamental rule with the version string beneath the seal
rule_y = cy + U * 1.17
for sign in (-1, 1):
    dl.line([(cx + sign * U * 0.05, rule_y), (cx + sign * U * 0.40, rule_y)], fill=170, width=3)
    px = cx + sign * U * 0.42
    q = U * 0.008
    dl.polygon([(px, rule_y - q), (px + q, rule_y), (px, rule_y + q), (px - q, rule_y)], fill=210)
if FONT:
    f = ImageFont.truetype(FONT, int(H * SS * 0.0135))
    label = "V E R .  1 . 2 2 4 7 4 4 8 7 1 3 9"
    tw = dl.textlength(label, font=f)
    dl.text((cx - tw / 2, rule_y + U * 0.035), label, fill=200, font=f)

def down(im):
    return np.asarray(im.resize((W, H), Image.LANCZOS), np.float32) / 255

bronze_m, crimson_m = down(L), down(R)
wear = np.clip(0.30 + norm(fbm(6, 16)) * 1.15, 0, 1)
pits = np.clip(norm(fbm(3, 240)) * 2.2 - 0.25, 0, 1)
wear = wear * (0.55 + 0.45 * pits) * (1 - cracks * 0.9)
bronze_m *= wear
crimson_m *= np.clip(wear * 1.25, 0, 1)

# carved look: a dark lip offset up-left, a faint highlight down-right
blurred = np.asarray(Image.fromarray((bronze_m * 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(2.2)), np.float32) / 255
lip = np.roll(np.roll(blurred, -2, 0), -2, 1)
glow = np.asarray(Image.fromarray((bronze_m * 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(14)), np.float32) / 255
img *= 1 - np.clip(lip * 0.42, 0, 0.6)[..., None]
bronze = np.array([0xb8, 0x9f, 0x74], np.float32)
crimson = np.array([0x96, 0x2d, 0x2d], np.float32)
img += bronze * glow[..., None] * 0.055
img = img * (1 - bronze_m[..., None] * 0.50) + bronze * bronze_m[..., None] * 0.50
img = img * (1 - crimson_m[..., None] * 0.80) + crimson * crimson_m[..., None] * 0.80

img += rng.normal(0, 1.0, (H, W, 1)).astype(np.float32)    # grain, also hides banding
Image.fromarray(np.clip(img, 0, 255).astype(np.uint8), "RGB").save(OUT, optimize=False, compress_level=6)
