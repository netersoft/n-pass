"""Builds the Play Store feature graphic, one per language.

1024x500 (the size Google Play requires): the app's gradient, its icon, name
and a tagline on the left, and two of the store screenshots in phone frames
on the right, running off the bottom edge.

    python3 tool/store_screenshots/feature.py [lang ...]

The phone screens are cut out of store/screenshots/<lang>/ (built by
compose.py), so run compose.py first. Names and taglines are in config.json,
under "feature". The results go to store/feature_graphic/<lang>.png.
"""

import sys
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont

sys.path.insert(0, str(Path(__file__).resolve().parent))
import compose  # noqa: E402
from compose import CONFIG, ROOT, hex_rgb, rounded_mask, wrap  # noqa: E402

W, H = 1024, 500
FEATURE = CONFIG['feature']
TEXT_LEFT = 64
TEXT_RIGHT = 520        # the phones start past this
ICON = 112
PHONE_H = 520           # screen height inside the frame: taller than the image
BEZEL = 8
RADIUS = 30


def gradient():
    """Top-left to bottom-right, so the text side stays the lighter one."""
    top, bottom = hex_rgb(CONFIG['background_top']), hex_rgb(CONFIG['background_bottom'])
    img = Image.new('RGB', (W, H))
    px = img.load()
    for y in range(H):
        for x in range(W):
            t = (x / W) * 0.6 + (y / H) * 0.4
            px[x, y] = tuple(round(a + (b - a) * t) for a, b in zip(top, bottom))
    return img


def screen_of(shot_path):
    """The phone screen of a compose.py screenshot, cut out of its frame."""
    shot = Image.open(shot_path).convert('RGB')
    if CONFIG.get('fit') == 'full':
        scale = (compose.H - compose.PHONE_TOP - 60 - 2 * compose.BEZEL) / 2400
    else:
        scale = compose.PHONE_W / 1080
    width, height = round(1080 * scale), round(2400 * scale)
    left = (compose.W - width - 2 * compose.BEZEL) // 2 + compose.BEZEL
    top = compose.PHONE_TOP + compose.BEZEL
    return shot.crop((left, top, left + width, min(top + height, compose.H)))


def draw_phone(img, screen, left, top):
    scale = PHONE_H / (screen.height if CONFIG.get('fit') == 'full' else screen.width * 2400 / 1080)
    screen = screen.resize((round(screen.width * scale), round(screen.height * scale)), Image.LANCZOS)
    frame_w, frame_h = screen.width + 2 * BEZEL, round(PHONE_H) + 2 * BEZEL
    # A screen cut at the bottom (compose.py without "fit": "full") must still reach the edge.
    top = max(top, H + 10 - BEZEL - screen.height)

    shadow = Image.new('L', (W, H), 0)
    ImageDraw.Draw(shadow).rounded_rectangle([left, top + 8, left + frame_w, top + 8 + frame_h], RADIUS + BEZEL, fill=110)
    img.paste((0, 0, 0), (0, 0), shadow.filter(ImageFilter.GaussianBlur(14)))

    frame = Image.new('RGB', (frame_w, frame_h), hex_rgb(CONFIG['bezel_color']))
    img.paste(frame, (left, top), rounded_mask(frame.size, RADIUS + BEZEL))
    img.paste(screen, (left + BEZEL, top + BEZEL), rounded_mask(screen.size, RADIUS))
    return frame_w


def balanced(draw, text, font, max_width):
    """wrap(), with the lines evened out: no word left alone on the last line."""
    lines = wrap(draw, text, font, max_width)
    width = max_width
    while len(lines) > 1:
        narrower = wrap(draw, text, font, width - 10)
        if len(narrower) > len(lines):
            break
        lines, width = narrower, width - 10
    return lines


def draw_text(img, lang):
    draw = ImageDraw.Draw(img)
    font_path = str(ROOT / CONFIG['font'])
    color = hex_rgb(CONFIG['title_color'])

    icon = Image.open(ROOT / FEATURE['icon']).convert('RGB').resize((ICON, ICON), Image.LANCZOS)

    # The name: the largest size (down from 60 px) that fits in 2 lines.
    width = TEXT_RIGHT - TEXT_LEFT
    for size in range(60, 30, -2):
        name_font = ImageFont.truetype(font_path, size)
        name_lines = wrap(draw, FEATURE['name'][lang], name_font, width)
        if len(name_lines) <= 2:
            break
    tag_font = ImageFont.truetype(font_path, 26)
    tag_lines = balanced(draw, FEATURE['tagline'][lang], tag_font, width)

    name_h, tag_h = round(size * 1.15), 36
    block = ICON + 28 + name_h * len(name_lines) + 18 + tag_h * len(tag_lines)
    y = (H - block) // 2

    img.paste(icon, (TEXT_LEFT, y), rounded_mask(icon.size, 26))
    y += ICON + 28
    for line in name_lines:
        draw.text((TEXT_LEFT, y), line, font=name_font, fill=color)
        y += name_h
    y += 18
    for line in tag_lines:
        draw.text((TEXT_LEFT, y), line, font=tag_font, fill=(255, 255, 255))
        y += tag_h


def feature(lang):
    img = gradient()
    shots = sorted((ROOT / 'store' / 'screenshots' / lang).glob('*.png'))
    by_name = {p.stem.split('_', 1)[1]: p for p in shots}
    back, front = (screen_of(by_name[name]) for name in FEATURE['screens'])
    # Two phones, the second one lower and in front.
    left = TEXT_RIGHT + 10
    width = draw_phone(img, back, left, 60)
    draw_phone(img, front, left + width - 50, 130)
    draw_text(img, lang)

    out = ROOT / 'store' / 'feature_graphic' / f'{lang}.png'
    out.parent.mkdir(parents=True, exist_ok=True)
    img.save(out, optimize=True)  # 24-bit PNG, no alpha, as Play requires
    return out


def main():
    for lang in sys.argv[1:] or list(CONFIG['titles']):
        print(feature(lang).relative_to(ROOT))


if __name__ == '__main__':
    main()
