"""Builds the Play Store phone screenshots from raw emulator captures.

Each screenshot is 1080x1920 (9:16, the size Google Play recommends): a
gradient background, a title, and the capture inside a phone frame that
runs off the bottom edge.

    python3 tool/store_screenshots/compose.py <captures_dir> [lang ...]

<captures_dir>/<lang>/<name>.png are full-screen captures (1080x2400, light
theme, clean status bar), where <name> is a screen id from config.json.
The results go to store/screenshots/<lang>/<n>_<name>.png.
"""

import json
import sys
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont

HERE = Path(__file__).resolve().parent
ROOT = HERE.parent.parent
CONFIG = json.loads((HERE / 'config.json').read_text(encoding='utf-8'))

W, H = 1080, 1920
PHONE_W = 820          # width of the screen inside the frame
BEZEL = 16
RADIUS = 56
PHONE_TOP = 430
TITLE_BOX = (90, 110, W - 90, PHONE_TOP - 60)


def gradient(top, bottom):
    img = Image.new('RGB', (W, H))
    draw = ImageDraw.Draw(img)
    for y in range(H):
        t = y / (H - 1)
        draw.line([(0, y), (W, y)], fill=tuple(round(a + (b - a) * t) for a, b in zip(top, bottom)))
    return img


def hex_rgb(value):
    value = value.lstrip('#')
    return tuple(int(value[i:i + 2], 16) for i in (0, 2, 4))


def wrap(draw, text, font, max_width):
    lines, line = [], ''
    for word in text.split():
        candidate = f'{line} {word}'.strip()
        if draw.textlength(candidate, font=font) <= max_width:
            line = candidate
        else:
            lines.append(line)
            line = word
    lines.append(line)
    return lines


def draw_title(img, text):
    """Centred title, the largest size (down from 72 px) that fits in 2 lines."""
    draw = ImageDraw.Draw(img)
    x0, y0, x1, y1 = TITLE_BOX
    for size in range(72, 40, -2):
        font = ImageFont.truetype(str(ROOT / CONFIG['font']), size)
        lines = wrap(draw, text, font, x1 - x0)
        line_h = round(size * 1.25)
        if len(lines) <= 2 and line_h * len(lines) <= y1 - y0:
            break
    top = y0 + ((y1 - y0) - line_h * len(lines)) // 2
    for i, line in enumerate(lines):
        width = draw.textlength(line, font=font)
        draw.text(((W - width) / 2, top + i * line_h), line, font=font, fill=hex_rgb(CONFIG['title_color']))


def rounded_mask(size, radius):
    mask = Image.new('L', size, 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, size[0] - 1, size[1] - 1], radius, fill=255)
    return mask


def draw_phone(img, capture):
    # "fit": "full" shrinks the phone so the whole screen shows, for apps whose
    # key content sits at the bottom; otherwise it runs off the bottom edge.
    if CONFIG.get('fit') == 'full':
        scale = (H - PHONE_TOP - 60 - 2 * BEZEL) / capture.height
    else:
        scale = PHONE_W / capture.width
    screen = capture.resize((round(capture.width * scale), round(capture.height * scale)), Image.LANCZOS)
    frame_w, frame_h = screen.width + 2 * BEZEL, screen.height + 2 * BEZEL
    left = (W - frame_w) // 2

    # Soft shadow under the frame.
    shadow = Image.new('L', (W, H), 0)
    ImageDraw.Draw(shadow).rounded_rectangle([left, PHONE_TOP + 12, left + frame_w, PHONE_TOP + 12 + frame_h], RADIUS + BEZEL, fill=90)
    shadow = shadow.filter(ImageFilter.GaussianBlur(24))
    img.paste((0, 0, 0), (0, 0), shadow)

    frame = Image.new('RGB', (frame_w, frame_h), hex_rgb(CONFIG['bezel_color']))
    img.paste(frame, (left, PHONE_TOP), rounded_mask(frame.size, RADIUS + BEZEL))
    img.paste(screen, (left + BEZEL, PHONE_TOP + BEZEL), rounded_mask(screen.size, RADIUS))


def compose(capture_path, title, out_path):
    img = gradient(hex_rgb(CONFIG['background_top']), hex_rgb(CONFIG['background_bottom']))
    draw_title(img, title)
    draw_phone(img, Image.open(capture_path).convert('RGB'))
    out_path.parent.mkdir(parents=True, exist_ok=True)
    img.save(out_path, optimize=True)  # 24-bit PNG, no alpha, as Play requires


def main():
    captures = Path(sys.argv[1])
    langs = sys.argv[2:] or list(CONFIG['titles'])
    for lang in langs:
        for n, (name, title) in enumerate(zip(CONFIG['screens'], CONFIG['titles'][lang]), start=1):
            out = ROOT / 'store' / 'screenshots' / lang / f'{n}_{name}.png'
            compose(captures / lang / f'{name}.png', title, out)
            print(out.relative_to(ROOT))


if __name__ == '__main__':
    main()
