"""Captures the raw screens for the Play Store screenshots, in one language.

Starts from a fresh install of the debug build (FLAG_SECURE, which blocks
screenshots, is only off in debug builds) on the shared `test-phone`
emulator (1080x2400) with SystemUI demo mode on, and the demo backup made by
make_demo_backup.dart in /sdcard/Download (see README.md).

    python3 tool/store_screenshots/capture.py <out_dir> <lang>

Writes <out_dir>/<lang>/<screen>.png for the screens listed in config.json.
"""

import sys
import time
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from adb_ui import adb, find, hide_keyboard, labels, screen, tap, wait_until  # noqa: E402

PACKAGE = 'com.neteru.n_pass.dev'
PASSWORD = 'TresorPyramide2026'        # same as make_demo_backup.dart
LOCALES = {'en': 'en-US', 'fr': 'fr-FR'}
BLUE = (0, 0, 205)                     # the app's primary color


def near(p, q, tol=12):
    return all(abs(a - b) <= tol for a, b in zip(p, q))


def list_shown(img):
    """The vault list: the blue + button at the bottom right."""
    return near(img.getpixel((920, 2180)), BLUE)       # left of the white +


def type_text(text):
    # One character at a time: a whole string sometimes lands with letters
    # swapped ("Tersor" for "Tresor"), which breaks a password.
    for c in text:
        adb('input', 'text', c)
        time.sleep(0.05)
    time.sleep(0.5)


def capture(out, lang, resume=False):
    out = Path(out) / lang
    out.mkdir(parents=True, exist_ok=True)
    t = labels(lang)
    if resume:                                          # already on the imported list
        return after_import(out)

    adb('pm', 'clear', PACKAGE)
    adb('cmd', 'locale', 'set-app-locales', PACKAGE, '--locales', LOCALES[lang])
    adb('monkey', '-p', PACKAGE, '-c', 'android.intent.category.LAUNCHER', '1')
    time.sleep(10)                                      # splash, then the intro

    # Intro: three pages, the button at the bottom right goes on and finishes.
    for _ in range(3):
        tap(872, 2230, 1.5)

    # Create the vault: the master password screen, with its strength meter.
    # Its title takes one or two lines depending on the language, so the
    # fields are found by their labels.
    t = labels(lang)
    for label in (t['masterPassword'], t['confirmMasterPassword']):
        tap(*find(label), 1.2)
        type_text(PASSWORD)
        hide_keyboard()
    time.sleep(2)                                       # the field masks its last typed character
    screen().save(out / 'create.png')
    tap(116, find(t['masterPasswordUnderstood'])[1], 0.6)
    tap(*find(t['createVault']), 1)
    wait_until(list_shown, 'the empty vault', 90)       # Argon2 is slow in debug builds

    # Settings, then restore the demo backup from there.
    tap(1016, 206, 2)
    screen().save(out / 'settings.png')
    tap(*find(t['backupAndRestore']), 2)
    tap(*find(t['importBackup']), 3)                    # system file picker
    tap(296, 960, 3)                                    # the only file in Downloads
    find(t['continueLabel'])                           # the password dialog (its keyboard may not open)
    type_text(PASSWORD)
    tap(*find(t['continueLabel']), 1)
    time.sleep(10)
    tap(72, 206, 1.5)                                   # back to settings
    tap(56, 206, 2)                                     # back to the list
    find('Gmail', 30)                                   # the imported accounts
    after_import(out)


def after_import(out):
    screen().save(out / 'list.png')

    # Gmail, second in the list (favorites first), with its 2FA code.
    tap(300, 710, 2.5)
    screen().save(out / 'detail.png')

    # The password generator, from the edit form.
    tap(890, 206, 2)                                    # edit
    hide_keyboard()
    tap(838, 972, 2)                                    # the dice: generator sheet
    screen().save(out / 'generator.png')
    tap(540, 400, 1)                                    # close the sheet
    tap(72, 206, 1.5)                                   # leave the form (nothing changed)
    tap(72, 206, 1.5)                                   # back to the list

    # Lock: the unlock screen.
    tap(890, 206, 3)
    hide_keyboard()                                     # it opens on the password field
    time.sleep(1)
    screen().save(out / 'unlock.png')


if __name__ == '__main__':
    capture(sys.argv[1], sys.argv[2], resume='--resume' in sys.argv)
