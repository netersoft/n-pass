import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n_pass/core/providers/vault/unlock_provider.dart';
import 'package:n_pass/core/services/biometrics/service.dart';

import '../helpers/test_utils.dart';

void main() {
  final key = Uint8List(32);

  late MockVaultService vault;
  late MockBiometricService biometrics;
  late MockNavigationHelper nav;

  setUpAll(() {
    registerFallbackValue(const BiometricPrompt(title: '', cancel: ''));
    registerFallbackValue(Uint8List(0));
  });

  setUp(() async {
    vault = MockVaultService();
    biometrics = MockBiometricService();
    nav = MockNavigationHelper();
    await setupTestLocator(navigationHelper: nav, vaultService: vault, biometricService: biometrics);
    when(() => biometrics.isEnabled).thenReturn(true);
    when(() => biometrics.disable(any())).thenAnswer((_) async {});
  });

  tearDown(teardownTestLocator);

  ProviderContainer container() {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    return container;
  }

  test('starts with the biometrics preference', () {
    expect(container().read(unlockProvider).biometricsEnabled, isTrue);
  });

  test('a wrong password shows an error, a right one clears it', () async {
    final c = container();
    when(() => vault.unlock('wrong')).thenAnswer((_) async => false);
    when(() => vault.unlock('right')).thenAnswer((_) async => true);

    await c.read(unlockProvider.notifier).unlockWithPassword('wrong');
    expect(c.read(unlockProvider).message, UnlockMessage.wrongPassword);
    expect(c.read(unlockProvider).isUnlocking, isFalse);

    await c.read(unlockProvider.notifier).unlockWithPassword('right');
    expect(c.read(unlockProvider).message, UnlockMessage.none);
  });

  test('biometrics unlock the vault with the stored key', () async {
    final c = container();
    when(() => biometrics.readKey(any())).thenAnswer((_) async => BiometricReadResult.success(key));
    when(() => vault.unlockWithKey(key)).thenAnswer((_) async => true);

    await c.read(unlockProvider.notifier).unlockWithBiometrics();

    verify(() => vault.unlockWithKey(key)).called(1);
    verifyNever(() => biometrics.disable(any()));
  });

  test('a cancelled prompt changes nothing', () async {
    final c = container();
    when(() => biometrics.readKey(any())).thenAnswer((_) async => const BiometricReadResult.cancelled());

    await c.read(unlockProvider.notifier).unlockWithBiometrics();

    expect(c.read(unlockProvider).biometricsEnabled, isTrue);
    expect(c.read(unlockProvider).message, UnlockMessage.none);
    verifyNever(() => biometrics.disable(any()));
  });

  test('a lost or stale key disables biometrics', () async {
    final c = container();
    when(() => biometrics.readKey(any())).thenAnswer((_) async => BiometricReadResult.success(key));
    when(() => vault.unlockWithKey(key)).thenAnswer((_) async => false);

    await c.read(unlockProvider.notifier).unlockWithBiometrics();

    expect(c.read(unlockProvider).biometricsEnabled, isFalse);
    expect(c.read(unlockProvider).message, UnlockMessage.biometricsChanged);
    verify(() => biometrics.disable(any())).called(1);
  });

  test('does not prompt when biometrics are off', () async {
    when(() => biometrics.isEnabled).thenReturn(false);

    await container().read(unlockProvider.notifier).unlockWithBiometrics();

    verifyNever(() => biometrics.readKey(any()));
  });

  test('eraseVault destroys the vault and goes to creation', () async {
    when(() => vault.destroy()).thenAnswer((_) async {});

    await container().read(unlockProvider.notifier).eraseVault();

    verify(() => biometrics.disable(any())).called(1);
    verify(() => vault.destroy()).called(1);
    verify(() => nav.go('/create')).called(1);
  });
}
