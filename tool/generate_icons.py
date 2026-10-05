"""Generates the launcher icon, splash logo and About logo from one vector
padlock, redrawn after the legacy NPass icon (white padlock with a long
shadow on a blue square).

Run from the project root: python3 tool/generate_icons.py
(needs cairosvg and Pillow), then:
  dart run icons_launcher:create
  dart run flutter_native_splash:create
"""

import io

import cairosvg
from PIL import Image, ImageDraw

OUT = 'assets/images/launcher'
SIZE = 1024  # drawing units
BLUE_LIGHT, BLUE, BLUE_DARK = '#1A1AE0', '#0000CD', '#0000A8'

# Padlock geometry, in drawing units, centered on (512, 512).
SHACKLE = 'M334,392 L334,368 A178,178 0 0 1 690,368 L690,392'
BODY = 'M228,374 H796 A18,18 0 0 1 814,392 V776 A18,18 0 0 1 796,794 H228 A18,18 0 0 1 210,776 V392 A18,18 0 0 1 228,374 Z'
KEYHOLE = 'M486,563 A42,42 0 1 1 538,563 L556,700 L468,700 Z'


def lock(fill, keyhole=None):
    """The padlock; the keyhole is cut out unless [keyhole] gives its color."""
    shackle = f'<path d="{SHACKLE}" fill="none" stroke="{fill}" stroke-width="60"/>'
    if keyhole is None:
        return shackle + f'<path d="{BODY} {KEYHOLE}" fill="{fill}" fill-rule="evenodd"/>'
    return shackle + f'<path d="{BODY}" fill="{fill}"/><path d="{KEYHOLE}" fill="{keyhole}"/>'


def long_shadow():
    """Copies of the padlock silhouette slid along the diagonal, composited at a
    uniform opacity."""
    silhouette = lock('black', keyhole='black')
    copies = ''.join(f'<g transform="translate({i},{i})">{silhouette}</g>' for i in range(4, 700, 4))
    return f'<g opacity="0.22">{copies}</g>'


def background():
    return (
        f'<defs><linearGradient id="bg" x1="0" y1="0" x2="1" y2="1">'
        f'<stop offset="0" stop-color="{BLUE_LIGHT}"/><stop offset="1" stop-color="{BLUE_DARK}"/></linearGradient></defs>'
        f'<rect width="{SIZE}" height="{SIZE}" fill="url(#bg)"/>'
    )


def svg(content, scale=1.0):
    group = f'<g transform="translate(512,512) scale({scale}) translate(-512,-512)">{content}</g>'
    return f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {SIZE} {SIZE}">{group}</svg>'


def render(markup, size):
    return Image.open(io.BytesIO(cairosvg.svg2png(bytestring=markup.encode(), output_width=size, output_height=size))).convert('RGBA')


def full_icon():
    """Background, shadow and padlock on one layer (iOS, legacy Android)."""
    return background() + f'<clipPath id="square"><rect width="{SIZE}" height="{SIZE}"/></clipPath><g clip-path="url(#square)">{long_shadow()}{lock("white", keyhole=BLUE)}</g>'


def save(image, name, opaque=False):
    if opaque:
        image = image.convert('RGB')
    image.save(f'{OUT}/{name}', optimize=True)
    print(name, image.size)


def main():
    with open(f'{OUT}/icon.svg', 'w') as f:
        f.write(svg(full_icon()))

    icon = render(svg(full_icon()), 900)
    save(icon, 'icon.png', opaque=True)  # App Store icons must not have alpha

    mask = Image.new('L', (900, 900), 0)
    ImageDraw.Draw(mask).ellipse((0, 0, 899, 899), fill=255)
    round_icon = Image.new('RGBA', (900, 900), (0, 0, 0, 0))
    round_icon.paste(icon, mask=mask)
    save(round_icon, 'icon_round.png')

    # Adaptive icon: the padlock must fit in the 66/108 safe zone.
    save(render(svg(background()), 900), 'background.png', opaque=True)
    save(render(svg(long_shadow() + lock('white', keyhole=BLUE), scale=0.6), 900), 'foreground.png')
    save(render(svg(lock('white'), scale=0.6), 900), 'icon_monochrome.png')

    # Splash: the Android 12 splash masks the image with a circle of 2/3 of its side.
    save(render(svg(lock('white'), scale=0.55), 1440), 'splash_logo.png')

    # About page: the icon with rounded corners.
    logo = render(svg(full_icon()), 512)
    corners = Image.new('L', (512, 512), 0)
    ImageDraw.Draw(corners).rounded_rectangle((0, 0, 511, 511), radius=112, fill=255)
    rounded = Image.new('RGBA', (512, 512), (0, 0, 0, 0))
    rounded.paste(logo, mask=corners)
    save(rounded, 'logo.png')


if __name__ == '__main__':
    main()
