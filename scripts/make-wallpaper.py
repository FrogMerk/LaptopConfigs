#!/usr/bin/env python3
"""Generate an Everforest Dark (medium) wallpaper using only the stdlib.

The output is a soft, abstract forest: green glow, distant trunks, vignette
and grain. It is intentionally low-contrast so terminal windows stay readable.
"""

from __future__ import annotations

import argparse
import math
import os
import struct
import zlib

BG_TOP = (0x23, 0x2A, 0x2E)      # bg_dim
BG_BOTTOM = (0x2D, 0x35, 0x3B)   # bg0
GREEN = (0xA7, 0xC0, 0x80)
AQUA = (0x83, 0xC0, 0x92)
CREAM = (0xD3, 0xC6, 0xAA)
TRUNK = (0x1E, 0x23, 0x26)

TRUNKS = (
    (0.10, 0.035, 0.22),
    (0.18, 0.020, 0.15),
    (0.82, 0.045, 0.20),
    (0.91, 0.020, 0.12),
)


def lerp(a: float, b: float, t: float) -> float:
    return a + (b - a) * t


def smoothstep(edge0: float, edge1: float, x: float) -> float:
    t = max(0.0, min(1.0, (x - edge0) / (edge1 - edge0)))
    return t * t * (3.0 - 2.0 * t)


def radial(x: float, y: float, cx: float, cy: float, radius: float, alpha: float):
    d = math.hypot(x - cx, y - cy) / radius
    if d >= 1.0:
        return 0.0
    return (1.0 - d) ** 2 * alpha


def grain(x: int, y: int) -> float:
    n = (x * 374761393 + y * 668265263) & 0xFFFFFFFF
    n = ((n ^ (n >> 13)) * 1274126177) & 0xFFFFFFFF
    return ((n ^ (n >> 16)) & 0xFF) / 255.0


def generate(width: int, height: int):
    for y in range(height):
        v = y / (height - 1)
        base_r = lerp(BG_TOP[0], BG_BOTTOM[0], v)
        base_g = lerp(BG_TOP[1], BG_BOTTOM[1], v)
        base_b = lerp(BG_TOP[2], BG_BOTTOM[2], v)
        mist = (math.sin(v * math.pi * 3.0) + 1.0) * 0.5 * 0.035
        row = bytearray()

        for x in range(width):
            nx = x / width
            ny = y / height

            r = base_r + CREAM[0] * mist
            g = base_g + CREAM[1] * mist
            b = base_b + CREAM[2] * mist

            gr = radial(nx, ny, 0.68, 0.42, 0.55, 0.16)
            ar = radial(nx, ny, 0.28, 0.72, 0.40, 0.10)
            cr = radial(nx, ny, 0.50, 0.18, 0.65, 0.03)
            r += GREEN[0] * gr + AQUA[0] * ar + CREAM[0] * cr
            g += GREEN[1] * gr + AQUA[1] * ar + CREAM[1] * cr
            b += GREEN[2] * gr + AQUA[2] * ar + CREAM[2] * cr

            for tx, tw, ta in TRUNKS:
                dx = abs(nx - tx)
                if dx < tw:
                    f = (1.0 - dx / tw) ** 2 * ta
                    r = lerp(r, TRUNK[0], f)
                    g = lerp(g, TRUNK[1], f)
                    b = lerp(b, TRUNK[2], f)

            vx = nx * 2.0 - 1.0
            vy = ny * 2.0 - 1.0
            vig = 1.0 - 0.22 * smoothstep(0.55, 1.35, math.hypot(vx, vy))
            r *= vig
            g *= vig
            b *= vig

            n = (grain(x, y) - 0.5) * 6.0
            row += bytes(
                (
                    max(0, min(255, int(r + n))),
                    max(0, min(255, int(g + n))),
                    max(0, min(255, int(b + n))),
                )
            )
        yield row


def write_png(path: str, width: int, height: int, rows) -> None:
    raw = b"".join(b"\x00" + bytes(row) for row in rows)

    def chunk(kind: bytes, data: bytes) -> bytes:
        body = kind + data
        return struct.pack(">I", len(data)) + body + struct.pack(
            ">I", zlib.crc32(body) & 0xFFFFFFFF
        )

    os.makedirs(os.path.dirname(os.path.abspath(path)), exist_ok=True)
    with open(path, "wb") as fh:
        fh.write(b"\x89PNG\r\n\x1a\n")
        fh.write(chunk(b"IHDR", struct.pack(">IIBBBBB", width, height, 8, 2, 0, 0, 0)))
        fh.write(chunk(b"IDAT", zlib.compress(raw, 9)))
        fh.write(chunk(b"IEND", b""))


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--width", type=int, default=1920)
    parser.add_argument("--height", type=int, default=1080)
    parser.add_argument(
        "--output",
        default=os.path.expanduser("~/Pictures/Wallpapers/everforest-forest.png"),
    )
    args = parser.parse_args()

    write_png(
        args.output,
        args.width,
        args.height,
        generate(args.width, args.height),
    )
    print(f"wrote {args.output} ({args.width}x{args.height})")


if __name__ == "__main__":
    main()
