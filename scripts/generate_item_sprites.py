#!/usr/bin/env python3
"""Generate transparent 32x32 pixel icons for weapons and common loot."""
from pathlib import Path
import shutil
import struct
import zlib

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "game/assets/icons"
SIZE = 32
TRANSPARENT = (0, 0, 0, 0)
INK = (34, 29, 38, 255)


class Canvas:
    def __init__(self):
        self.p = [[TRANSPARENT for _ in range(SIZE)] for _ in range(SIZE)]

    def pixel(self, x, y, c):
        if 0 <= x < SIZE and 0 <= y < SIZE:
            self.p[y][x] = c

    def rect(self, x, y, w, h, c):
        for yy in range(y, y + h):
            for xx in range(x, x + w):
                self.pixel(xx, yy, c)

    def poly(self, pts, c):
        ys = [p[1] for p in pts]
        for y in range(max(0, min(ys)), min(SIZE, max(ys) + 1)):
            xs = []
            for i, (x1, y1) in enumerate(pts):
                x2, y2 = pts[(i + 1) % len(pts)]
                if y1 == y2:
                    continue
                if min(y1, y2) <= y < max(y1, y2):
                    xs.append(round(x1 + (y - y1) * (x2 - x1) / (y2 - y1)))
            xs.sort()
            for i in range(0, len(xs) - 1, 2):
                for x in range(xs[i], xs[i + 1] + 1):
                    self.pixel(x, y, c)

    def line(self, a, b, c, width=1):
        x0, y0 = a
        x1, y1 = b
        dx, dy = abs(x1 - x0), abs(y1 - y0)
        sx, sy = (1 if x0 < x1 else -1), (1 if y0 < y1 else -1)
        err = dx - dy
        while True:
            self.rect(x0 - width // 2, y0 - width // 2, width, width, c)
            if x0 == x1 and y0 == y1:
                break
            e2 = 2 * err
            if e2 > -dy:
                err -= dy
                x0 += sx
            if e2 < dx:
                err += dx
                y0 += sy

    def ellipse(self, cx, cy, rx, ry, c):
        for y in range(cy - ry, cy + ry + 1):
            for x in range(cx - rx, cx + rx + 1):
                if ((x - cx) / max(rx, 1)) ** 2 + ((y - cy) / max(ry, 1)) ** 2 <= 1:
                    self.pixel(x, y, c)

    def save(self, path):
        raw = b"".join(b"\x00" + b"".join(bytes(px) for px in row) for row in self.p)
        def chunk(tag, data):
            return struct.pack(">I", len(data)) + tag + data + struct.pack(">I", zlib.crc32(tag + data) & 0xffffffff)
        png = (b"\x89PNG\r\n\x1a\n"
               + chunk(b"IHDR", struct.pack(">2I5B", SIZE, SIZE, 8, 6, 0, 0, 0))
               + chunk(b"IDAT", zlib.compress(raw, 9))
               + chunk(b"IEND", b""))
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_bytes(png)


def weapon(kind):
    c = Canvas()
    steel, steel_hi, wood, gold = (183, 197, 214, 255), (240, 244, 247, 255), (119, 75, 43, 255), (230, 177, 65, 255)
    if kind == "sword":
        c.poly([(5, 24), (8, 24), (22, 7), (25, 6), (24, 10), (10, 27), (8, 28)], INK)
        c.poly([(7, 24), (22, 8), (23, 8), (9, 26)], steel)
        c.line((7, 25), (12, 22), wood, 4); c.line((7, 25), (12, 22), gold, 1)
        c.pixel(5, 27, wood); c.pixel(6, 26, wood)
    elif kind == "spear":
        c.line((8, 28), (23, 8), INK, 5); c.line((9, 27), (23, 8), wood, 3)
        c.poly([(19, 10), (22, 3), (27, 2), (25, 9), (23, 12)], INK)
        c.poly([(21, 9), (23, 4), (25, 4), (24, 9), (22, 11)], steel_hi)
        c.line((13, 21), (16, 18), gold, 2)
    elif kind == "axe":
        c.line((9, 28), (22, 8), INK, 5); c.line((10, 27), (22, 8), wood, 3)
        c.poly([(17, 12), (17, 6), (22, 3), (29, 5), (28, 12), (24, 17), (21, 14)], INK)
        c.poly([(19, 11), (20, 7), (23, 5), (27, 6), (26, 10), (23, 14)], steel)
        c.line((21, 7), (25, 6), steel_hi, 2)
    elif kind == "bow":
        c.line((9, 4), (14, 16), INK, 5); c.line((14, 16), (9, 28), INK, 5)
        c.line((9, 4), (14, 16), wood, 3); c.line((14, 16), (9, 28), wood, 3)
        c.line((9, 4), (9, 28), (226, 216, 187, 255), 1)
        c.line((13, 16), (28, 16), INK, 3); c.line((14, 16), (27, 16), steel_hi, 1)
        c.poly([(27, 16), (23, 13), (23, 19)], steel)
    elif kind in ("staff", "druid_staff"):
        wood = (111, 75, 49, 255) if kind == "staff" else (92, 107, 48, 255)
        orb = (66, 153, 255, 255) if kind == "staff" else (103, 218, 71, 255)
        c.line((9, 28), (22, 9), INK, 6); c.line((10, 27), (22, 9), wood, 4)
        c.line((20, 13), (24, 8), gold if kind == "staff" else (153, 194, 75, 255), 2)
        c.ellipse(23, 6, 5, 5, INK); c.ellipse(23, 6, 4, 4, orb)
        c.pixel(22, 4, (255, 255, 231, 255)); c.pixel(24, 5, (204, 255, 187, 255) if kind == "druid_staff" else (215, 239, 255, 255))
    c.save(OUT / f"{kind}.png")


def drop(kind):
    c = Canvas()
    if kind == "moeda":
        c.ellipse(16, 17, 10, 10, INK); c.ellipse(16, 16, 8, 8, (171, 115, 37, 255)); c.ellipse(15, 15, 6, 6, (245, 196, 70, 255)); c.pixel(14, 12, (255, 231, 142, 255))
    elif kind in ("pocao_vida", "pocao_mana"):
        liquid = (219, 54, 66, 255) if kind == "pocao_vida" else (61, 118, 239, 255)
        c.rect(12, 3, 8, 3, INK); c.rect(13, 4, 6, 2, (220, 220, 219, 255))
        c.poly([(12, 7), (20, 7), (20, 11), (24, 15), (24, 25), (21, 29), (11, 29), (8, 25), (8, 15), (12, 11)], INK)
        c.poly([(13, 9), (19, 9), (19, 12), (22, 16), (22, 24), (20, 27), (12, 27), (10, 24), (10, 16), (13, 12)], (176, 205, 226, 255))
        c.rect(11, 19, 10, 6, liquid); c.rect(13, 17, 6, 2, liquid); c.rect(12, 14, 2, 4, (255, 255, 255, 255))
    elif kind in ("carne", "queijo", "peixe"):
        if kind == "carne":
            c.poly([(5, 18), (8, 12), (17, 10), (25, 14), (27, 21), (21, 26), (9, 26)], INK)
            c.poly([(7, 18), (10, 14), (17, 12), (23, 15), (25, 20), (20, 24), (10, 24)], (159, 57, 48, 255))
            c.ellipse(11, 17, 3, 2, (247, 176, 145, 255)); c.pixel(6, 17, (239, 231, 212, 255)); c.pixel(5, 17, (247, 247, 236, 255))
        elif kind == "queijo":
            c.poly([(5, 23), (22, 8), (28, 23), (27, 27), (6, 27)], INK)
            c.poly([(7, 22), (22, 11), (26, 23), (25, 25), (8, 25)], (250, 207, 80, 255))
            c.pixel(17, 18, (191, 137, 44, 255)); c.pixel(22, 22, (191, 137, 44, 255)); c.pixel(13, 22, (191, 137, 44, 255))
        else:
            c.poly([(4, 17), (10, 12), (22, 12), (27, 17), (22, 22), (10, 22)], INK)
            c.poly([(7, 17), (11, 14), (21, 14), (24, 17), (21, 20), (11, 20)], (109, 157, 196, 255))
            c.poly([(24, 17), (29, 12), (29, 22)], (201, 157, 82, 255)); c.pixel(12, 16, INK)
    elif kind.startswith("runa_"):
        color = {"runa_fogo": (239, 89, 48, 255), "runa_gelo": (102, 192, 238, 255), "runa_trovoada": (242, 214, 61, 255), "runa_cura": (102, 217, 117, 255)}[kind]
        c.poly([(16, 3), (27, 13), (25, 23), (16, 29), (7, 23), (5, 13)], INK)
        c.poly([(16, 6), (24, 14), (22, 22), (16, 26), (9, 22), (8, 14)], (118, 120, 131, 255))
        c.line((16, 9), (16, 22), color, 3); c.line((12, 16), (20, 16), color, 2)
    elif kind == "flecha":
        c.line((7, 25), (25, 7), INK, 4); c.line((8, 24), (25, 7), (148, 104, 57, 255), 2)
        c.poly([(21, 7), (28, 4), (25, 11)], INK); c.poly([(23, 7), (26, 6), (24, 9)], (221, 226, 230, 255))
        c.poly([(8, 23), (4, 23), (7, 19)], INK); c.poly([(8, 22), (6, 22), (8, 20)], (230, 223, 198, 255))
    elif kind == "cajado_druida":
        weapon("druid_staff")
        return
    elif kind == "lanca":
        weapon("spear")
        return
    elif kind == "espada":
        weapon("sword")
        return
    elif kind == "machado":
        weapon("axe")
        return
    elif kind == "arco":
        weapon("bow")
        return
    elif kind == "cajado":
        weapon("staff")
        return
    c.save(OUT / f"{kind}.png")


def main():
    for kind in ("sword", "spear", "axe", "bow", "staff", "druid_staff"):
        weapon(kind)
    for kind in ("moeda", "carne", "queijo", "peixe", "pocao_vida", "pocao_mana", "flecha",
                 "runa_fogo", "runa_gelo", "runa_trovoada", "runa_cura"):
        drop(kind)
    for alias, source in {"lanca": "spear", "espada": "sword", "machado": "axe", "arco": "bow",
                          "cajado": "staff", "cajado_druida": "druid_staff"}.items():
        shutil.copyfile(OUT / f"{source}.png", OUT / f"{alias}.png")
    print(f"Generated transparent pixel icons in {OUT}")


if __name__ == "__main__":
    main()
