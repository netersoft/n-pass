import 'package:flutter/services.dart';

/// Copies vault data to the clipboard. Secrets go through a native channel:
/// flagged as sensitive and cleared after [clearAfter] on Android, local-only
/// with an expiration date on iOS.
class ClipboardService {
  static const Duration clearAfter = Duration(seconds: 30);
  static const MethodChannel _channel = MethodChannel('npass/clipboard');

  final MethodChannel _platform;

  ClipboardService({MethodChannel? channel}) : _platform = channel ?? _channel;

  Future<void> copy(String text, {bool sensitive = false}) async {
    if (!sensitive) return Clipboard.setData(ClipboardData(text: text));

    try {
      await _platform.invokeMethod<void>('copySensitive', {'text': text, 'clearAfterMs': clearAfter.inMilliseconds});
    } on MissingPluginException {
      await Clipboard.setData(ClipboardData(text: text));
    }
  }
}
