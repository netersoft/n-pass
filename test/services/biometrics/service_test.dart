import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n_pass/core/services/biometrics/service.dart';
import 'package:n_pass/core/services/shared_preferences/keys.dart';

import '../../helpers/test_utils.dart';

class MockLocalAuthentication extends Mock implements LocalAuthentication {}

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  const prompt = BiometricPrompt(title: 'Unlock', cancel: 'Cancel');
  final key = Uint8List.fromList(List.generate(32, (i) => i));

  late MockSharedPreferencesService prefs;
  late MockLocalAuthentication localAuth;
  late MockFlutterSecureStorage storage;
  late BiometricService biometrics;

  setUp(() {
    prefs = MockSharedPreferencesService();
    localAuth = MockLocalAuthentication();
    storage = MockFlutterSecureStorage();
    biometrics = BiometricService(prefs, localAuth: localAuth, storageFor: (_) => storage);
    when(() => prefs.setBool(any(), any())).thenAnswer((_) async => true);
  });

  group('isAvailable', () {
    test('needs a supported device with strong biometrics enrolled', () async {
      when(() => localAuth.isDeviceSupported()).thenAnswer((_) async => true);
      when(() => localAuth.getAvailableBiometrics()).thenAnswer((_) async => [BiometricType.strong]);
      expect(await biometrics.isAvailable(), isTrue);

      when(() => localAuth.getAvailableBiometrics()).thenAnswer((_) async => [BiometricType.weak]);
      expect(await biometrics.isAvailable(), isFalse);

      when(() => localAuth.isDeviceSupported()).thenAnswer((_) async => false);
      expect(await biometrics.isAvailable(), isFalse);
    });

    test('is false when the platform throws', () async {
      when(() => localAuth.isDeviceSupported()).thenThrow(PlatformException(code: 'x'));

      expect(await biometrics.isAvailable(), isFalse);
    });
  });

  test('isEnabled reads the preference', () {
    when(() => prefs.getBool(PrefKeys.biometricsEnabled, defaultValue: any(named: 'defaultValue'))).thenReturn(true);

    expect(biometrics.isEnabled, isTrue);
  });

  group('enable', () {
    test('stores the key and turns the preference on', () async {
      when(
        () => storage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        ),
      ).thenAnswer((_) async {});

      expect(await biometrics.enable(key, prompt), isTrue);
      verify(() => storage.write(key: 'vault_key', value: base64Encode(key))).called(1);
      verify(() => prefs.setBool(PrefKeys.biometricsEnabled, true)).called(1);
    });

    test('returns false and leaves the preference off when the prompt fails', () async {
      when(
        () => storage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        ),
      ).thenThrow(PlatformException(code: 'cancel'));

      expect(await biometrics.enable(key, prompt), isFalse);
      verifyNever(() => prefs.setBool(any(), any()));
    });
  });

  group('readKey', () {
    test('returns the stored key', () async {
      when(() => storage.read(key: 'vault_key')).thenAnswer((_) async => base64Encode(key));

      final result = await biometrics.readKey(prompt);
      expect(result.status, BiometricReadStatus.success);
      expect(result.key, key);
    });

    test('reports a cancelled prompt', () async {
      when(() => storage.read(key: 'vault_key')).thenThrow(PlatformException(code: 'cancel'));

      expect((await biometrics.readKey(prompt)).status, BiometricReadStatus.cancelled);
    });

    test('reports a missing key as unavailable', () async {
      when(() => storage.read(key: 'vault_key')).thenAnswer((_) async => null);

      expect((await biometrics.readKey(prompt)).status, BiometricReadStatus.unavailable);
    });
  });

  test('after enabling, reads are guarded by an explicit prompt until restart', () async {
    when(
      () => storage.write(
        key: any(named: 'key'),
        value: any(named: 'value'),
      ),
    ).thenAnswer((_) async {});
    when(() => storage.read(key: 'vault_key')).thenAnswer((_) async => base64Encode(key));
    when(
      () => localAuth.authenticate(localizedReason: any(named: 'localizedReason'), biometricOnly: true),
    ).thenAnswer((_) async => false);

    expect((await biometrics.readKey(prompt)).status, BiometricReadStatus.success, reason: 'no guard before enabling');

    await biometrics.enable(key, prompt);
    expect((await biometrics.readKey(prompt)).status, BiometricReadStatus.cancelled);

    when(
      () => localAuth.authenticate(localizedReason: any(named: 'localizedReason'), biometricOnly: true),
    ).thenAnswer((_) async => true);
    expect((await biometrics.readKey(prompt)).status, BiometricReadStatus.success);
  });

  test('disable deletes the key even when the keystore throws', () async {
    when(() => storage.delete(key: any(named: 'key'))).thenThrow(PlatformException(code: 'x'));

    await biometrics.disable(prompt);

    verify(() => prefs.setBool(PrefKeys.biometricsEnabled, false)).called(1);
    verify(() => storage.delete(key: 'vault_key')).called(1);
  });
}
