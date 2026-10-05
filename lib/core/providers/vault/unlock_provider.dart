import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../helpers/router/navigation_helper.dart';
import '../../routes/app_route.dart';
import '../../services/biometrics/service.dart';
import '../../services/di/locator.dart';
import '../../services/vault/service.dart';
import 'biometric_prompt.dart';

part 'unlock_provider.g.dart';

enum UnlockMessage { none, wrongPassword, biometricsChanged }

@riverpod
class Unlock extends _$Unlock {
  @override
  UnlockState build() => UnlockState(biometricsEnabled: locator<BiometricService>().isEnabled);

  void clearMessage() => state = state.copyWith(message: UnlockMessage.none);

  /// On success the router leaves the unlock screen by itself (it listens to
  /// the vault lock state).
  Future<void> unlockWithPassword(String password) async {
    state = state.copyWith(isUnlocking: true, message: UnlockMessage.none);
    final ok = await locator<VaultService>().unlock(password);
    if (!ref.mounted) return;
    state = state.copyWith(isUnlocking: false, message: ok ? UnlockMessage.none : UnlockMessage.wrongPassword);
  }

  Future<void> unlockWithBiometrics() async {
    if (!state.biometricsEnabled || state.isUnlocking) return;

    final biometrics = locator<BiometricService>();
    final result = await biometrics.readKey(localizedBiometricPrompt());
    if (result.status == BiometricReadStatus.cancelled) return;

    if (result.status == BiometricReadStatus.success && await locator<VaultService>().unlockWithKey(result.key!)) return;

    // The stored key is gone or no longer opens the vault.
    await biometrics.disable(localizedBiometricPrompt());
    if (!ref.mounted) return;
    state = state.copyWith(biometricsEnabled: false, message: UnlockMessage.biometricsChanged);
  }

  /// Erases the vault after a forgotten master password and starts over.
  Future<void> eraseVault() async {
    await locator<BiometricService>().disable(localizedBiometricPrompt());
    await locator<VaultService>().destroy();
    locator<NavigationHelper>().go(const CreateVaultRoute().location);
  }
}

class UnlockState {
  final bool biometricsEnabled;
  final bool isUnlocking;
  final UnlockMessage message;

  const UnlockState({
    this.biometricsEnabled = false,
    this.isUnlocking = false,
    this.message = UnlockMessage.none,
  });

  UnlockState copyWith({bool? biometricsEnabled, bool? isUnlocking, UnlockMessage? message}) => UnlockState(
    biometricsEnabled: biometricsEnabled ?? this.biometricsEnabled,
    isUnlocking: isUnlocking ?? this.isUnlocking,
    message: message ?? this.message,
  );
}
