# Play Store screenshots

`store/screenshots/<lang>/` holds the 6 phone screenshots of the store listing, one set per
app language: 1080×1920 (9:16) 24-bit PNGs, a white title over the app's blue gradient and a
light-theme capture in a phone frame.

The vault in them is a demo one: made-up accounts from `make_demo_backup.dart`, no real data.

## Regenerate them

1. Start the shared emulator (`test-phone`, 1080×2400) and install a **debug** build: release
   builds set `FLAG_SECURE`, which turns every screenshot black.

   ```bash
   flutter build apk --debug --flavor dev
   adb install -r build/app/outputs/flutter-apk/app-dev-debug.apk
   ```

2. Clean status bar (10:00, full battery and Wi-Fi, no notifications):

   ```bash
   adb shell settings put global sysui_demo_allowed 1
   adb shell am broadcast -a com.android.systemui.demo -e command enter
   adb shell am broadcast -a com.android.systemui.demo -e command clock -e hhmm 1000
   adb shell am broadcast -a com.android.systemui.demo -e command battery -e level 100 -e plugged false
   adb shell am broadcast -a com.android.systemui.demo -e command network -e wifi show -e level 4 -e fully true
   adb shell am broadcast -a com.android.systemui.demo -e command network -e mobile hide
   adb shell am broadcast -a com.android.systemui.demo -e command notifications -e visible false
   ```

3. In Gboard's settings (Text correction), turn off the suggestion strip and auto-correction;
   turn them back on afterwards.

4. For each language, put that language's demo backup alone in Downloads, then capture:

   ```bash
   dart run tool/store_screenshots/make_demo_backup.dart fr /tmp/npass-demo-fr.npass
   adb shell rm -f /sdcard/Download/*.npass
   adb push /tmp/npass-demo-fr.npass /sdcard/Download/
   python3 tool/store_screenshots/capture.py /tmp/captures fr
   ```

   The script clears the app's data, sets its language, creates a vault, imports the backup
   and takes the screens. `--resume` starts from the imported list, if a run stopped there.

5. Build the images, look at every one before uploading them, then exit demo mode:

   ```bash
   python3 tool/store_screenshots/compose.py /tmp/captures
   adb shell am broadcast -a com.android.systemui.demo -e command exit
   ```

## How it works

- `config.json`: screen order, titles in each language, colors.
- `capture.py` drives the app with `adb`. Buttons whose place depends on the language are
  found by their text, read with macOS Vision (`ocr.swift`) and matched against
  `assets/i18n/<lang>.i18n.json`.
- `adb_ui.py`: taps, typing, keyboard detection and text lookup. `adb shell input text`
  sometimes swaps letters when typing a whole string, so passwords are typed one character
  at a time; and Back is only pressed when the keyboard is up, since otherwise it leaves the
  screen.
- `compose.py` builds the final images.
