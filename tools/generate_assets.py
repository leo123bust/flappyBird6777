#!/usr/bin/env python3
"""Generates the pixel-art bird sprites and Android launcher icons.

Requires Pillow:  pip install pillow
Run from the project root:  python3 tools/generate_assets.py
"""
import os
from PIL import Image, ImageDraw

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
IMG_DIR = os.path.join(ROOT, 'assets', 'images')
RES_DIR = os.path.join(ROOT, 'android', 'app', 'src', 'main', 'res')
W, H = 20, 14  # native sprite size, scaled up with nearest-neighbour in the game

OUTLINE = (58, 30, 22, 255)
WHITE = (255, 255, 255, 255)
PUPIL = (30, 20, 30, 255)
BEAK = (255, 138, 38, 255)
BEAK_DARK = (222, 82, 34, 255)

# skin: (body, body light, belly, wing, wing light)
SKINS = {
    'yellow': ((255, 206, 38), (255, 234, 110), (255, 244, 176), (244, 140, 22), (255, 180, 60)),
    'red': ((232, 62, 52), (255, 118, 96), (255, 176, 150), (170, 32, 40), (214, 70, 64)),
    'blue': ((58, 164, 238), (128, 212, 255), (206, 238, 255), (255, 150, 30), (255, 190, 80)),
    'green': ((82, 202, 72), (150, 236, 112), (214, 246, 170), (34, 130, 52), (70, 170, 70)),
    'purple': ((168, 92, 222), (208, 144, 252), (228, 194, 252), (112, 52, 170), (150, 90, 205)),
    'black': ((66, 66, 78), (116, 116, 130), (160, 160, 172), (30, 30, 38), (62, 62, 72)),
}


def inside(x, y, cx, cy, rx, ry):
    return ((x + 0.5 - cx) / rx) ** 2 + ((y + 0.5 - cy) / ry) ** 2 <= 1.0


def rgba(c):
    return (c[0], c[1], c[2], 255)


def make_bird(skin, frame):
    base, light, belly, wing, wing_l = [rgba(c) for c in SKINS[skin]]
    img = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    px = img.load()
    cx, cy, rx, ry = 8.6, 7.0, 8.4, 6.5

    # body
    for y in range(H):
        for x in range(W):
            if inside(x, y, cx, cy, rx, ry):
                if inside(x, y, cx, cy, rx - 1.1, ry - 1.1):
                    col = base
                    if y + 0.5 < cy - 2.2:
                        col = light
                    if inside(x, y, cx + 1.8, cy + 4.0, 5.2, 2.3):
                        col = belly
                    px[x, y] = col
                else:
                    px[x, y] = OUTLINE

    # beak
    for y in range(6, 11):
        for x in range(16, 20):
            if y in (6, 10):
                if x <= 18:
                    px[x, y] = OUTLINE
            elif x == 19:
                px[x, y] = OUTLINE
            elif y == 9:
                px[x, y] = BEAK_DARK
            else:
                px[x, y] = BEAK

    # eye
    ex, ey = 12.9, 4.9
    for y in range(H):
        for x in range(W):
            if inside(x, y, ex, ey, 2.9, 2.9) and px[x, y][3] != 0:
                px[x, y] = WHITE if inside(x, y, ex, ey, 1.9, 1.9) else OUTLINE
    for (x, y) in [(13, 4), (14, 4), (13, 5), (14, 5)]:
        px[x, y] = PUPIL

    # wing (3 animation frames: up, middle, down)
    wy, wh = {0: (5.4, 3.4), 1: (8.0, 3.0), 2: (9.8, 2.7)}[frame]
    wx = 5.2
    for y in range(H):
        for x in range(W):
            if inside(x, y, wx, wy, 4.4, wh):
                if inside(x, y, wx, wy, 3.3, wh - 1.1):
                    px[x, y] = wing_l if y + 0.5 < wy - 0.2 else wing
                else:
                    px[x, y] = OUTLINE
    return img


def launcher(size):
    img = Image.new('RGBA', (size, size))
    px = img.load()
    for y in range(size):
        t = y / (size - 1)
        col = (int(30 + 100 * t), int(140 + 76 * t), int(240 + 15 * t), 255)
        for x in range(size):
            px[x, y] = col
    bw = int(size * 0.74)
    bh = int(bw * H / W)
    bird = make_bird('yellow', 1).resize((bw, bh), Image.NEAREST)
    img.alpha_composite(bird, ((size - bw) // 2, (size - bh) // 2))
    mask = Image.new('L', (size, size), 0)
    ImageDraw.Draw(mask).rounded_rectangle(
        (0, 0, size - 1, size - 1), radius=int(size * 0.22), fill=255)
    img.putalpha(mask)
    return img


def main():
    os.makedirs(IMG_DIR, exist_ok=True)
    for skin in SKINS:
        for frame in range(3):
            make_bird(skin, frame).save(
                os.path.join(IMG_DIR, f'bird_{skin}_{frame}.png'))
    sizes = {'mdpi': 48, 'hdpi': 72, 'xhdpi': 96, 'xxhdpi': 144, 'xxxhdpi': 192}
    for folder, size in sizes.items():
        d = os.path.join(RES_DIR, f'mipmap-{folder}')
        os.makedirs(d, exist_ok=True)
        launcher(size).save(os.path.join(d, 'ic_launcher.png'))
    print('Assets generated.')


if __name__ == '__main__':
    main()
