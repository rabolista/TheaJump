"""Generates the TheaJump app icon and in-game sprite art as PNG files.

Run with: python3 tool/generate_icon.py
Requires Pillow (pip install pillow).
"""

from PIL import Image, ImageDraw
import math
import os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT_DIR = os.path.join(ROOT, "assets", "images")
os.makedirs(OUT_DIR, exist_ok=True)


def vertical_gradient(size, top_color, bottom_color):
    w, h = size
    img = Image.new("RGB", size)
    draw = ImageDraw.Draw(img)
    for y in range(h):
        t = y / max(h - 1, 1)
        r = round(top_color[0] + (bottom_color[0] - top_color[0]) * t)
        g = round(top_color[1] + (bottom_color[1] - top_color[1]) * t)
        b = round(top_color[2] + (bottom_color[2] - top_color[2]) * t)
        draw.line([(0, y), (w, y)], fill=(r, g, b))
    return img


def draw_blob_character(draw, cx, cy, r, body_color, cheek_color=(255, 140, 140)):
    """A round bouncy creature: body, two eyes, smile, two cheeks, tiny antenna."""
    # squash the body slightly to look bouncy
    bbox = [cx - r, cy - r * 0.92, cx + r, cy + r * 0.92]
    draw.ellipse(bbox, fill=body_color)

    # antenna
    draw.line([(cx, cy - r * 0.92), (cx + r * 0.15, cy - r * 1.25)], fill=body_color, width=max(int(r * 0.09), 2))
    draw.ellipse(
        [cx + r * 0.15 - r * 0.11, cy - r * 1.25 - r * 0.11, cx + r * 0.15 + r * 0.11, cy - r * 1.25 + r * 0.11],
        fill=(255, 221, 89),
    )

    # cheeks
    cheek_r = r * 0.14
    draw.ellipse([cx - r * 0.55 - cheek_r, cy + r * 0.05 - cheek_r, cx - r * 0.55 + cheek_r, cy + r * 0.05 + cheek_r], fill=cheek_color)
    draw.ellipse([cx + r * 0.55 - cheek_r, cy + r * 0.05 - cheek_r, cx + r * 0.55 + cheek_r, cy + r * 0.05 + cheek_r], fill=cheek_color)

    # eyes (white + pupil)
    eye_r = r * 0.22
    for dx in (-0.32, 0.32):
        ex, ey = cx + r * dx, cy - r * 0.12
        draw.ellipse([ex - eye_r, ey - eye_r, ex + eye_r, ey + eye_r], fill=(255, 255, 255))
        pupil_r = eye_r * 0.5
        draw.ellipse([ex - pupil_r, ey - pupil_r * 0.4, ex + pupil_r, ey + pupil_r * 1.6], fill=(40, 30, 30))

    # smile
    smile_bbox = [cx - r * 0.35, cy + r * 0.02, cx + r * 0.35, cy + r * 0.45]
    draw.arc(smile_bbox, start=15, end=165, fill=(80, 40, 20), width=max(int(r * 0.07), 2))


def make_icon():
    size = 1024
    img = vertical_gradient((size, size), (76, 201, 240), (123, 79, 224))

    # rounded-square mask for a friendly app-icon shape
    mask = Image.new("L", (size, size), 0)
    mdraw = ImageDraw.Draw(mask)
    radius = int(size * 0.22)
    mdraw.rounded_rectangle([0, 0, size, size], radius=radius, fill=255)

    draw = ImageDraw.Draw(img)

    # sun glow
    draw.ellipse([size * 0.62, size * 0.06, size * 0.98, size * 0.42], fill=(255, 214, 102))

    # soft clouds
    for cx, cy, s in [(0.22, 0.22, 1.0), (0.15, 0.62, 0.7), (0.75, 0.72, 0.9)]:
        cx_, cy_ = cx * size, cy * size
        r = 0.09 * size * s
        draw.ellipse([cx_ - r, cy_ - r * 0.6, cx_ + r, cy_ + r * 0.6], fill=(255, 255, 255, 255))
        draw.ellipse([cx_ - r * 0.6 + r * 0.6, cy_ - r * 0.85, cx_ + r * 0.6 + r * 0.6, cy_ + r * 0.35], fill=(255, 255, 255))

    # stack of bounce platforms
    plat_color = (255, 255, 255)
    platforms = [
        (size * 0.30, size * 0.86, size * 0.86, size * 0.90),
        (size * 0.44, size * 0.68, size * 0.90, size * 0.72),
        (size * 0.20, size * 0.50, size * 0.66, size * 0.54),
    ]
    for x0, y0, x1, y1 in platforms:
        draw.rounded_rectangle([x0, y0, x1, y1], radius=int((y1 - y0) / 2), fill=plat_color)

    # motion arcs to suggest jumping
    for i, r in enumerate([0.30, 0.36, 0.42]):
        bbox = [size * 0.5 - size * r, size * 0.62 - size * r, size * 0.5 + size * r, size * 0.62 + size * r]
        draw.arc(bbox, start=200, end=340, fill=(255, 255, 255), width=int(size * 0.012))

    # main character
    draw_blob_character(draw, size * 0.5, size * 0.40, size * 0.20, body_color=(255, 122, 89))

    img.putalpha(mask)
    img.save(os.path.join(OUT_DIR, "icon.png"))
    print("wrote", os.path.join(OUT_DIR, "icon.png"))


def make_sprite(name, body_color, size=256):
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    draw_blob_character(draw, size * 0.5, size * 0.52, size * 0.36, body_color=body_color)
    img.save(os.path.join(OUT_DIR, name))
    print("wrote", os.path.join(OUT_DIR, name))


def make_platform(name, w, h, color):
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    draw.rounded_rectangle([0, 0, w - 1, h - 1], radius=h // 2, fill=color)
    highlight = tuple(min(255, c + 40) for c in color)
    draw.rounded_rectangle([w * 0.06, h * 0.12, w * 0.94, h * 0.42], radius=h // 4, fill=highlight)
    img.save(os.path.join(OUT_DIR, name))
    print("wrote", os.path.join(OUT_DIR, name))


def make_background():
    size = (800, 1400)
    img = vertical_gradient(size, (135, 206, 250), (255, 255, 255))
    draw = ImageDraw.Draw(img)
    for cx, cy, s in [(0.2, 0.15, 1.2), (0.7, 0.28, 0.9), (0.35, 0.45, 1.0), (0.75, 0.6, 0.8), (0.25, 0.75, 1.1)]:
        cx_, cy_ = cx * size[0], cy * size[1]
        r = 0.11 * size[0] * s
        draw.ellipse([cx_ - r, cy_ - r * 0.55, cx_ + r, cy_ + r * 0.55], fill=(255, 255, 255))
        draw.ellipse([cx_ - r * 0.2, cy_ - r * 0.85, cx_ + r * 1.0, cy_ + r * 0.3], fill=(255, 255, 255))
    img.save(os.path.join(OUT_DIR, "background.png"))
    print("wrote", os.path.join(OUT_DIR, "background.png"))


def make_star(name="star.png", size=128, color=(255, 214, 102)):
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    cx, cy = size / 2, size / 2
    outer, inner = size * 0.46, size * 0.19
    points = []
    for i in range(10):
        angle = -math.pi / 2 + i * math.pi / 5
        r = outer if i % 2 == 0 else inner
        points.append((cx + r * math.cos(angle), cy + r * math.sin(angle)))
    draw.polygon(points, fill=color)
    img.save(os.path.join(OUT_DIR, name))
    print("wrote", os.path.join(OUT_DIR, name))


if __name__ == "__main__":
    make_icon()
    make_sprite("player.png", (255, 122, 89))
    make_sprite("player_hurt.png", (150, 150, 160))
    make_platform("platform_normal.png", 220, 46, (94, 214, 130))
    make_platform("platform_break.png", 220, 46, (222, 148, 96))
    make_platform("platform_spring.png", 220, 46, (240, 210, 90))
    make_background()
    make_star()
    print("done")
