from __future__ import annotations

from pathlib import Path

import numpy as np
from PIL import Image


def main() -> None:
    src = Path(r"c:\work\github\baggage_management_app\flutter_app\assets\bag_view_logo.png")
    dst = Path(r"c:\work\github\baggage_management_app\flutter_app\assets\bag_view_logo_fg.png")

    img = Image.open(src).convert("RGBA")
    a = np.array(img)
    r, g, b, alpha = (a[..., i] for i in range(4))

    # Consider near-white as background.
    bg = (r > 245) & (g > 245) & (b > 245)
    mask = (~bg) & (alpha > 0)

    ys, xs = np.where(mask)
    if len(xs) == 0:
        raise SystemExit("No foreground detected")

    x0, x1 = int(xs.min()), int(xs.max())
    y0, y1 = int(ys.min()), int(ys.max())

    margin = int(max(img.size) * 0.04)
    x0 = max(0, x0 - margin)
    y0 = max(0, y0 - margin)
    x1 = min(img.size[0] - 1, x1 + margin)
    y1 = min(img.size[1] - 1, y1 + margin)

    crop = img.crop((x0, y0, x1 + 1, y1 + 1))

    # Make near-white fully transparent.
    c = np.array(crop)
    r2, g2, b2, a2 = (c[..., i] for i in range(4))
    near_white = (r2 > 245) & (g2 > 245) & (b2 > 245)
    c[..., 3] = np.where(near_white, 0, a2)
    fg = Image.fromarray(c, mode="RGBA")

    # Fit into 1024x1024, scaling foreground to 90% of canvas.
    size = 1024
    max_side = max(fg.size)
    target = int(size * 0.90)
    new_w = int(fg.size[0] * target / max_side)
    new_h = int(fg.size[1] * target / max_side)
    fg2 = fg.resize((new_w, new_h), Image.Resampling.LANCZOS)

    canvas = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    canvas.paste(fg2, ((size - new_w) // 2, (size - new_h) // 2), fg2)
    dst.parent.mkdir(parents=True, exist_ok=True)
    canvas.save(dst)
    print(f"Wrote {dst}")


if __name__ == "__main__":
    main()

