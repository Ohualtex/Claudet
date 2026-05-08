#!/usr/bin/env python3
"""
Re-trace ``Sources/Claudet/SpritesWorking.swift`` from the raw video frames
in ``~/Desktop/Claudetpng/`` (kare_*.png).

For each PNG:
  1. Detect background (the dark grays from the source video) and treat as empty.
  2. Compute a tight bounding box of the pet/scene.
  3. Sample CELL_SIZE x CELL_SIZE pixel blocks from the bbox.
  4. For each block, pick a palette character using:
       - empty if >60% transparent,
       - else priority for thin features (eye/outline) when even a few
         pixels are present (so 1-pixel outlines don't get drowned out by
         body fill on a majority vote),
       - else the mode of palette-quantized pixels.
  5. Bottom-anchor the resulting cells at row 26 (matches idle feet) and
     center horizontally, so the pet stays at a consistent on-screen size.

Frame durations are derived from the gap between consecutive source frame
indices at 30 fps, so the playback timing matches the original video.

Usage:
    python3 scripts/trace_working.py [SRC_DIR] [OUT_FILE]
defaults:
    SRC_DIR  = ~/Desktop/Claudetpng
    OUT_FILE = Sources/Claudet/SpritesWorking.swift
"""
import os
import sys
from collections import Counter

try:
    from PIL import Image
except ImportError:
    sys.stderr.write(
        "Pillow not installed. Run: python3 -m pip install --user Pillow\n"
    )
    raise


# Palette key matches Sprites.swift's `SpriteCell` raw values.
# Palet anahtarları Sprites.swift'teki `SpriteCell` raw değerleriyle eşleşir.
PALETTE = {
    "O": (216, 118,  85),   # body
    "D": (140,  65,  35),   # dark outline
    "L": (252, 195, 165),   # light highlight
    "E": ( 12,  12,  12),   # eye dark
    "W": (245, 245, 245),   # eye highlight
    "M": (176,  84,  55),   # mid-tone coral
    "N": (153,  60,  30),   # deep coral shadow
    "G": (118, 118, 118),   # laptop gray
    "K": ( 88,  88,  88),   # laptop dark gray
}

GRID_W, GRID_H = 48, 30
ANCHOR_BOTTOM_ROW = 26      # feet row in idle pose
CELL_SIZE = 3                # source pixels per output cell

# Priority for thin features: even a few pixels of these in a cell should
# keep the feature visible (otherwise body fill always wins on majority).
# İnce detaylar için öncelik: bir hücrede birkaç piksel olsa bile detayın
# görünür kalması (gövde dolgusu çoğunluk oyuyla bunları yutmasın diye).
THIN_PRIORITY = [
    ("W", 1),
    ("E", 1),
    ("D", 2),
    ("K", 2),
    ("L", 2),
]


def is_bg(r, g, b, a):
    """Anything translucent or dark-grayish counts as scene background."""
    if a < 64:
        return True
    chroma = max(r, g, b) - min(r, g, b)
    return chroma <= 18 and max(r, g, b) <= 130


def nearest_palette(r, g, b):
    """Map a pet/scene pixel to a `SpriteCell` raw value.

    The mapping does not blindly use Euclidean distance: the source video
    paints eyes as extremely dark red and outlines as a slightly warmer
    dark, but our palette has D as a much lighter coral. Without these
    overrides everything dark would collapse into E, losing the warm
    outline/body separation.
    """
    chroma = max(r, g, b) - min(r, g, b)
    bright = max(r, g, b)

    # Eye dot — extremely dark red with negligible green/blue.
    if bright <= 50 and g <= 6 and b <= 8:
        return "E"
    # Pure-dark grayish (no chroma) — also eye.
    if bright <= 35 and chroma <= 8:
        return "E"
    # Dark warm pixel — body outline (D).
    if bright <= 100 and chroma >= 10 and r > g and g >= b:
        return "D"
    # Bright grayish — laptop screen / specular highlight (W, off-white).
    if bright >= 200 and chroma <= 20:
        return "W"
    # Otherwise nearest palette entry, excluding E.
    best, bd = "O", 10 ** 9
    for k, (pr, pg, pb) in PALETTE.items():
        if k == "E":
            continue
        d = (r - pr) ** 2 + (g - pg) ** 2 + (b - pb) ** 2
        if d < bd:
            bd, best = d, k
    return best


def trace_frame(path, cell_size=CELL_SIZE):
    im = Image.open(path).convert("RGBA")
    w, h = im.size
    px = im.load()

    # Bbox of non-background pixels.
    minx, miny, maxx, maxy = w, h, -1, -1
    for y in range(h):
        for x in range(w):
            if not is_bg(*px[x, y]):
                minx = min(minx, x); maxx = max(maxx, x)
                miny = min(miny, y); maxy = max(maxy, y)
    if maxx < 0:
        return [["."] * GRID_W for _ in range(GRID_H)]

    bw = maxx - minx + 1
    bh = maxy - miny + 1
    cells_w = min((bw + cell_size - 1) // cell_size, GRID_W)
    cells_h = min((bh + cell_size - 1) // cell_size, GRID_H)
    base_x = (GRID_W - cells_w) // 2
    base_y = ANCHOR_BOTTOM_ROW - cells_h + 1

    grid = [["."] * GRID_W for _ in range(GRID_H)]
    total = cell_size * cell_size
    for cy in range(cells_h):
        for cx in range(cells_w):
            counts = Counter()
            for py in range(cy * cell_size, (cy + 1) * cell_size):
                for pxc in range(cx * cell_size, (cx + 1) * cell_size):
                    sy, sx = miny + py, minx + pxc
                    if sy > maxy or sx > maxx:
                        counts["."] += 1
                        continue
                    r, g, b, a = px[sx, sy]
                    if is_bg(r, g, b, a):
                        counts["."] += 1
                    else:
                        counts[nearest_palette(r, g, b)] += 1

            if counts.get(".", 0) >= total * 0.6:
                ch = "."
            else:
                ch = None
                for feature, threshold in THIN_PRIORITY:
                    if counts.get(feature, 0) >= threshold:
                        ch = feature
                        break
                if ch is None:
                    non_empty = {k: v for k, v in counts.items() if k != "."}
                    ch = max(non_empty, key=non_empty.get) if non_empty else "."

            gx, gy = base_x + cx, base_y + cy
            if 0 <= gx < GRID_W and 0 <= gy < GRID_H:
                grid[gy][gx] = ch
    return grid


HEADER = """\
import AppKit

// Working-state pixel-art frames, traced cell-by-cell from the official
// Claude Code marketing video frames. Each cell sampled from a 3x3 block
// of the source PNG with mode + thin-feature-priority quantization.
// Frame timing follows the source frame indices at 30 fps.
//
// Working durumu pixel-art frame'leri, resmi Claude Code tanıtım videosunun
// karelerinden hücre-hücre trace edilmiştir. Her hücre kaynak PNG'nin 3x3
// bloğundan mode + ince-detay-önceliği kuantizasyonuyla örneklenmiştir.
// Frame zamanlaması 30 fps'de kaynak indekslerini takip eder.
//
// Generated by scripts/trace_working.py — do not edit by hand.
// scripts/trace_working.py tarafından üretilir — elle düzenleme.

extension Sprites {
    static let workingFrames: [SpriteFrame] = [
"""

FOOTER = """\
    ]
}
"""


def emit_swift(files, src_dir, out_path):
    indices = [int(f[5:9]) for f in files]
    durations = []
    for i, idx in enumerate(indices):
        if i + 1 < len(indices):
            gap = indices[i + 1] - idx
            durations.append(int(round(gap * 1000 / 30)))
        else:
            durations.append(200)

    parts = [HEADER]
    for f, ms in zip(files, durations):
        grid = trace_frame(os.path.join(src_dir, f))
        parts.append(f"        // {f}\n")
        parts.append("        SpriteFrame(rows: [\n")
        for row in grid:
            parts.append(f'            "{"".join(row)}",\n')
        parts.append(f"        ], durationMs: {ms}),\n")
    parts.append(FOOTER)
    with open(out_path, "w") as f:
        f.write("".join(parts))


def main():
    src_dir = sys.argv[1] if len(sys.argv) > 1 else os.path.expanduser(
        "~/Desktop/Claudetpng"
    )
    out_path = sys.argv[2] if len(sys.argv) > 2 else os.path.join(
        os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
        "Sources/Claudet/SpritesWorking.swift",
    )

    files = sorted(
        f for f in os.listdir(src_dir)
        if f.startswith("kare_") and f.endswith(".png")
    )
    if not files:
        sys.stderr.write(f"no kare_*.png frames in {src_dir}\n")
        sys.exit(1)

    emit_swift(files, src_dir, out_path)
    print(f"wrote {out_path} ({len(files)} frames)")


if __name__ == "__main__":
    main()
