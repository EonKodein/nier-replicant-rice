#!/usr/bin/env python3
"""Draw the fastfetch sigil as truecolor braille. Usage: gen-fetch-logo.py OUT.txt
Braille gives 2x4 dots per terminal cell, which keeps thin geometric lines crisp and round."""
import math
import sys
from PIL import Image, ImageDraw

COLS, ROWS, SS = 34, 17, 6
W, H = COLS * 2, ROWS * 4
BRONZE, DIM, CRIMSON = (184, 159, 116), (138, 120, 88), (201, 60, 56)
LAYERS = {name: Image.new("L", (W * SS, H * SS), 0) for name in ("bronze", "dim", "crimson")}
draw = {k: ImageDraw.Draw(v) for k, v in LAYERS.items()}
cx, cy, U = W * SS / 2, H * SS / 2, min(W, H) * SS / 2 - SS


def pt(r, a):
    return cx + r * math.cos(a), cy + r * math.sin(a)


def ring(layer, r, w):
    draw[layer].ellipse((cx - r, cy - r, cx + r, cy + r), outline=255, width=int(w))


ring("bronze", U, SS)
ring("dim", U * 0.74, SS)
for i in range(14):                                   # glyph band
    a = 2 * math.pi * i / 14 - math.pi / 2
    draw["bronze"].line([pt(U * 0.80, a), pt(U * 0.93, a)], fill=255, width=SS)
star = [pt(U * 0.72, -math.pi / 2 + 2 * math.pi * i * 3 / 7) for i in range(8)]
draw["dim"].line(star, fill=255, width=SS)
s = U * 0.11
draw["crimson"].polygon([(cx, cy - s * 1.6), (cx + s, cy), (cx, cy + s * 1.6), (cx - s, cy)], fill=255)

masks = {k: v.resize((W, H), Image.BOX).point(lambda p: 255 if p > 110 else 0) for k, v in LAYERS.items()}
# Braille dot bits for (x, y) within a cell.
BITS = {(0, 0): 0x01, (0, 1): 0x02, (0, 2): 0x04, (0, 3): 0x40, (1, 0): 0x08, (1, 1): 0x10, (1, 2): 0x20, (1, 3): 0x80}
ORDER = (("crimson", CRIMSON), ("bronze", BRONZE), ("dim", DIM))
out = []
for row in range(ROWS):
    line, current = "", None
    for col in range(COLS):
        bits, colour = 0, None
        for name, rgb in ORDER:
            for (dx, dy), bit in BITS.items():
                if masks[name].getpixel((col * 2 + dx, row * 4 + dy)):
                    bits |= bit
                    colour = colour or rgb
        if bits and colour != current:
            line += "\x1b[38;2;%d;%d;%dm" % colour
            current = colour
        line += chr(0x2800 + bits) if bits else " "
    out.append(line + "\x1b[0m")
open(sys.argv[1], "w", encoding="utf-8").write("\n".join(out) + "\n")
