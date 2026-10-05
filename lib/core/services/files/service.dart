import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../auto_lock/service.dart';

/// Moves backup files in and out of the app, without any storage permission:
/// system document pickers and the share sheet.
class FileTransferService {
  static const MethodChannel _channel = MethodChannel('npass/files');
  static const String _mimeType = 'application/octet-stream';

  final AutoLockService _autoLock;
  final MethodChannel _platform;

  FileTransferService(this._autoLock, {MethodChannel? channel}) : _platform = channel ?? _channel;

  /// Android only: iOS offers "Save to Files" in the share sheet.
  bool get canSaveToDevice => Platform.isAndroid;

  /// Lets the user pick where to save [bytes]. Returns false when cancelled.
  Future<bool> saveToDevice(String name, Uint8List bytes) =>
      _autoLock.whileExternal(() async => await _platform.invokeMethod<bool>('saveFile', {'name': name, 'bytes': bytes}) ?? false);

  /// Returns false when the user dismissed the share sheet.
  Future<bool> share(String name, Uint8List bytes, {required String subject, Rect? origin}) async {
    final result = await _autoLock.whileExternal(
      () => SharePlus.instance.share(
        ShareParams(
          files: [XFile.fromData(bytes, mimeType: _mimeType, name: name)],
          fileNameOverrides: [name],
          subject: subject,
          sharePositionOrigin: origin,
        ),
      ),
    );
    return result.status != ShareResultStatus.dismissed;
  }

  /// Returns the content of the file the user picked, or null when cancelled.
  Future<Uint8List?> pickFile() async {
    final file = await _autoLock.whileExternal(openFile);
    return file?.readAsBytes();
  }
}
