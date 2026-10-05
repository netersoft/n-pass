import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

import '../auto_lock/service.dart';

/// Camera permission for the QR scanner.
///
/// On Android it goes through the `npass/camera` channel: the scanner plugin
/// asks again on every resume while the permission is denied, so the app asks
/// first and only shows the scanner once it is granted. On iOS the system asks
/// once and the plugin handles it.
class CameraPermissionService {
  static const MethodChannel _channel = MethodChannel('npass/camera');

  final AutoLockService _autoLock;
  final MethodChannel _platform;

  CameraPermissionService(this._autoLock, {MethodChannel? channel}) : _platform = channel ?? _channel;

  /// Whether the camera is allowed, without asking.
  Future<bool> check() async => !Platform.isAndroid || (await _platform.invokeMethod<bool>('check') ?? false);

  /// Asks for the camera when needed. Resolves to false when refused.
  Future<bool> request() async => !Platform.isAndroid || (await _platform.invokeMethod<bool>('request') ?? false);

  /// Opens the app page of the system settings, to allow the camera there.
  /// Resolves when the user comes back, so the auto-lock grace covers the trip.
  Future<void> openSettings() => _autoLock.whileExternal(() async {
    final left = Completer<void>();
    final back = Completer<void>();
    final listener = AppLifecycleListener(
      onHide: () => left.isCompleted ? null : left.complete(),
      onResume: () => back.isCompleted ? null : back.complete(),
    );
    try {
      if (Platform.isAndroid) {
        await _platform.invokeMethod<void>('openSettings');
      } else {
        await launchUrl(Uri.parse('app-settings:'));
      }
      // The settings may fail to open: don't wait for a return that won't come.
      await left.future.timeout(const Duration(seconds: 2));
      await back.future;
    } on TimeoutException {
      return;
    } finally {
      listener.dispose();
    }
  });
}
