"""Small adb helpers shared by the capture scripts."""

import subprocess
import time
from io import BytesIO

from PIL import Image


def adb(*args):
    subprocess.run(['adb', 'shell', *map(str, args)], check=True, capture_output=True)


def tap(x, y, wait=0.8):
    adb('input', 'tap', x, y)
    time.sleep(wait)


def keyboard_shown(img=None):
    """Gboard's light lilac background along a row near the bottom (the IME
    service's own mInputShown flag stays false on this emulator)."""
    img = img or screen()
    bg = lambda p: all(abs(a - b) <= 4 for a, b in zip(p, (238, 237, 244)))
    # Look at several rows: one of them always falls between two key rows.
    return any(sum(1 for x in range(0, 1080, 10) if bg(img.getpixel((x, y)))) > 60 for y in range(1900, 2320, 6))


def hide_keyboard():
    """Back closes the keyboard, but closes the screen when there is none:
    only press it when the keyboard is up."""
    if keyboard_shown():
        adb('input', 'keyevent', 'KEYCODE_BACK')
        time.sleep(0.7)


def type_into(x, y, text):
    tap(x, y, 1.2)                        # let the field take focus first
    adb('input', 'text', text.replace(' ', '%s'))
    time.sleep(0.4)
    hide_keyboard()


def screen():
    png = subprocess.run(['adb', 'exec-out', 'screencap', '-p'], check=True, capture_output=True).stdout
    return Image.open(BytesIO(png)).convert('RGB')


def wait_until(check, what, timeout=30):
    deadline = time.time() + timeout
    while time.time() < deadline:
        img = screen()
        if check(img):
            return img
        time.sleep(1)
    raise RuntimeError(f'{what} did not show up within {timeout}s')


# The account form, once the password is filled (its strength bar pushes
# every later field 80 px down).
FORM = {'title': 404, 'username': 594, 'email': 782, 'password': 972, 'generate': (838, 972),
        'totp': 1324, 'website': 1566, 'category': 1756, 'favorite': (948, 2258), 'save': (1016, 206)}


def add_account(title, username='', email='', totp='', website='', category='', favorite=False):
    tap(964, 2220, 2)                          # the + button
    wait_until(keyboard_shown, 'the account form')   # it opens with the title focused
    type_into(540, FORM['title'], title)
    if username:
        type_into(540, FORM['username'], username)
    if email:
        type_into(540, FORM['email'], email)
    tap(*FORM['generate'], 1)
    for field, value in (('totp', totp), ('website', website), ('category', category)):
        if value:
            type_into(540, FORM[field], value)
    if favorite:
        tap(*FORM['favorite'])
    hide_keyboard()
    tap(*FORM['save'], 2.5)


# --- Finding labels on screen (macOS Vision, see ocr.swift) ----------------

import difflib  # noqa: E402
import json  # noqa: E402
import tempfile  # noqa: E402
from pathlib import Path  # noqa: E402

_HERE = Path(__file__).resolve().parent
_OCR_BIN = Path(tempfile.gettempdir()) / 'store_screenshots_ocr'
_SHOT = Path(tempfile.gettempdir()) / 'store_screenshots_shot.png'


def ocr(img=None):
    """[(x, y, w, h, text)] of the text lines on screen."""
    if not _OCR_BIN.exists() or _OCR_BIN.stat().st_mtime < (_HERE / 'ocr.swift').stat().st_mtime:
        subprocess.run(['swiftc', '-O', str(_HERE / 'ocr.swift'), '-o', str(_OCR_BIN)], check=True, timeout=300)
    (img or screen()).save(_SHOT)
    out = subprocess.run([str(_OCR_BIN), str(_SHOT)], check=True, capture_output=True, text=True, timeout=60).stdout
    lines = []
    for row in out.splitlines():
        box, text = row.split('\t', 1)
        x, y, w, h = map(int, box.split())
        lines.append((x, y, w, h, text))
    return lines


def find(label, timeout=20):
    """Centre of the on-screen line that best matches `label`."""
    deadline = time.time() + timeout
    while True:
        best = max(ocr(), key=lambda l: difflib.SequenceMatcher(None, l[4].lower(), label.lower()).ratio(), default=None)
        if best and difflib.SequenceMatcher(None, best[4].lower(), label.lower()).ratio() > 0.75:
            x, y, w, h, _ = best
            return x + w // 2, y + h // 2
        if time.time() > deadline:
            raise RuntimeError(f'"{label}" is not on screen')
        time.sleep(1)


def labels(lang):
    """The app's own strings, so lookups follow the translations."""
    root = _HERE.parent.parent / 'assets' / 'i18n'
    return json.loads((root / f'{lang}.i18n.json').read_text(encoding='utf-8'))
