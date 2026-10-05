import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n_pass/core/providers/account/security_settings_provider.dart';
import 'package:n_pass/core/services/biometrics/service.dart';
import 'package:n_pass/core/services/shared_preferences/keys.dart';

import '../helpers/test_utils.dart';

void main() {
  late MockVaultService vault;
  late MockBiometricService biometrics;
  late MockAutoLockService autoLock;
  late MockSharedPreferencesService prefs;

  setUpAll(() {
    registerFallbackValue(const BiometricPrompt(title: '', cancel: ''));
    registerFallbackValue(Uint8List(0));
  });

  setUp(() async {
    vault = MockVaultService();
    biometrics = MockBiometricService();
    autoLock = MockAutoLockService();
    prefs = MockSharedPreferencesService();
    await setupTestLocator(sharedPreferencesService: prefs, vaultService: vault, biometricService: biometrics, autoLockService: autoLock);
    when(() => biometrics.isEnabled).thenReturn(false);
    when(() => biometrics.isAvailable()).thenAnswer((_) async => true);
    when(() => autoLock.delaySeconds).thenReturn(60);
    when(() => prefs.getBool(PrefKeys.revealPasswords, defaultValue: any(named: 'defaultValue'))).thenReturn(null);
    when(() => vault.exportKey()).thenAnswer((_) async => Uint8List(32));
  });

  tearDown(teardownTestLocator);

  Future<ProviderContainer> container() async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    c.listen(securitySettingsProvider, (_, _) {});
    await Future<void>.delayed(Duration.zero);
    return c;
  }

  test('reads the current settings and the biometrics availability', () async {
    final state = (await container()).read(securitySettingsProvider);

    expect(state.biometricsAvailable, isTrue);
    expect(state.biometricsEnabled, isFalse);
    expect(state.autoLockDelaySeconds, 60);
    expect(state.revealPasswords, isFalse);
  });

  test('turning biometrics on stores the vault key, off removes it', () async {
    when(() => biometrics.enable(any(), any())).thenAnswer((_) async => true);
    when(() => biometrics.disable(any())).thenAnswer((_) async {});
    final c = await container();
    final notifier = c.read(securitySettingsProvider.notifier);

    expect(await notifier.setBiometrics(true), isTrue);
    expect(c.read(securitySettingsProvider).biometricsEnabled, isTrue);
    verify(() => biometrics.enable(any(that: hasLength(32)), any())).called(1);

    await notifier.setBiometrics(false);
    expect(c.read(securitySettingsProvider).biometricsEnabled, isFalse);
    verify(() => biometrics.disable(any())).called(1);
  });

  test('a cancelled biometric prompt leaves biometrics off', () async {
    when(() => biometrics.enable(any(), any())).thenAnswer((_) async => false);
    final c = await container();

    expect(await c.read(securitySettingsProvider.notifier).setBiometrics(true), isFalse);
    expect(c.read(securitySettingsProvider).biometricsEnabled, isFalse);
  });

  test('persists the auto-lock delay and the reveal preference', () async {
    when(() => autoLock.setDelaySeconds(any())).thenAnswer((_) async {});
    when(() => prefs.setBool(any(), any())).thenAnswer((_) async => true);
    final c = await container();
    final notifier = c.read(securitySettingsProvider.notifier);

    await notifier.setAutoLockDelay(0);
    await notifier.setRevealPasswords(true);

    verify(() => autoLock.setDelaySeconds(0)).called(1);
    verify(() => prefs.setBool(PrefKeys.revealPasswords, true)).called(1);
    expect(c.read(securitySettingsProvider).autoLockDelaySeconds, 0);
    expect(c.read(securitySettingsProvider).revealPasswords, isTrue);
  });
}
