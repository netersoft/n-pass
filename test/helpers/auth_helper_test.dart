import 'dart:io';

import 'package:flutter_starter/core/helpers/account/auth_helper.dart';
import 'package:flutter_starter/core/models/user_model.dart';
import 'package:flutter_starter/core/services/hive/hive_registrar.g.dart';
import 'package:flutter_starter/core/services/hive/keys.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_auth_helper_test');
    Hive
      ..init(tempDir.path)
      ..registerAdapters();
    // Touching AuthHelper for the first time resolves its static `authBox`
    // field via `Hive.box(HiveKeys.auth)`, which requires the box to already
    // be open -- unlike production, no encryption cipher is needed here
    // since AuthHelper never reads or writes the cipher itself.
    await Hive.openBox(HiveKeys.auth);
  });

  tearDownAll(() async {
    await Hive.deleteFromDisk();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  tearDown(() async {
    await AuthHelper.authBox.clear();
  });

  UserModel buildUser({int id = 1}) => UserModel(id: id);

  group('when no session is stored', () {
    test('getToken returns null', () {
      expect(AuthHelper.getToken(), isNull);
    });

    test('getUserData returns null', () {
      expect(AuthHelper.getUserData(), isNull);
    });

    test('isUserLogged is false and isUserNotLogged is true', () {
      expect(AuthHelper.isUserLogged(), isFalse);
      expect(AuthHelper.isUserNotLogged(), isTrue);
    });
  });

  group('when only a token is stored (no user data)', () {
    test('isUserLogged stays false', () async {
      await AuthHelper.authBox.put(HiveKeys.authToken, 'a-token');

      expect(AuthHelper.getToken(), 'a-token');
      expect(AuthHelper.isUserLogged(), isFalse);
    });
  });

  group('when a full session is stored', () {
    test('getToken, getUserData, and isUserLogged reflect it', () async {
      final user = buildUser(id: 42);

      await AuthHelper.authBox.put(HiveKeys.authToken, 'a-token');
      await AuthHelper.authBox.put(HiveKeys.authUserData, user);

      expect(AuthHelper.getToken(), 'a-token');
      expect(AuthHelper.getUserData()?.id, 42);
      expect(AuthHelper.isUserLogged(), isTrue);
      expect(AuthHelper.isUserNotLogged(), isFalse);
    });
  });
}
