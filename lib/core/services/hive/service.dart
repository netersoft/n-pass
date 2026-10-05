import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import 'hive_registrar.g.dart';
import 'keys.dart';

class HiveService {
  static HiveService? _instance;

  static Future<HiveService?> getInstance() async {
    _instance ??= HiveService();

    await _instance?.openBoxes();

    return _instance;
  }

  Box? authBox;
  Box? helperBox;

  HiveService();

  Future<void> openBoxes() async {
    // Register adapters
    Hive.registerAdapters();

    const secureStorage = FlutterSecureStorage();
    // if key not exists return null
    final encryptionKeyString = await secureStorage.read(key: 'key');
    if (encryptionKeyString == null) {
      final key = Hive.generateSecureKey();
      await secureStorage.write(
        key: 'key',
        value: base64UrlEncode(key),
      );
    }
    final key = await secureStorage.read(key: 'key');
    final encryptionKeyUint8List = base64Url.decode(key!);

    authBox = await Hive.openBox(
      HiveKeys.auth,
      encryptionCipher: HiveAesCipher(encryptionKeyUint8List),
    );
    helperBox = await Hive.openBox(
      HiveKeys.helper,
      encryptionCipher: HiveAesCipher(encryptionKeyUint8List),
    );
  }
}
