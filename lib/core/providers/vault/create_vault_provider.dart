import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../helpers/router/navigation_helper.dart';
import '../../routes/app_route.dart';
import '../../services/biometrics/service.dart';
import '../../services/di/locator.dart';
import '../../services/vault/service.dart';
import '../../tools/functions/password_strength.dart';
import 'biometric_prompt.dart';

part 'create_vault_provider.g.dart';

@riverpod
class CreateVault extends _$CreateVault {
  static const int minLength = 8;

  @override
  CreateVaultState build() {
    _loadBiometricsAvailability();
    return const CreateVaultState();
  }

  Future<void> _loadBiometricsAvailability() async {
    final available = await locator<BiometricService>().isAvailable();
    if (!ref.mounted) return;
    state = state.copyWith(biometricsAvailable: available);
  }

  void setPassword(String password) => state = state.copyWith(strength: estimatePasswordStrength(password));

  void setUseBiometrics(bool value) => state = state.copyWith(useBiometrics: value);

  void setAcknowledged(bool value) => state = state.copyWith(acknowledged: value);

  /// Creates the vault, then stores its key behind biometrics when asked.
  /// Returns false when biometrics could not be enabled (the vault is still
  /// created and unlocked).
  Future<bool> submit(String password) async {
    state = state.copyWith(isSubmitting: true);

    final vault = locator<VaultService>();
    await vault.create(password);

    var biometricsEnabled = true;
    if (state.biometricsAvailable && state.useBiometrics) {
      biometricsEnabled = await locator<BiometricService>().enable(await vault.exportKey(), localizedBiometricPrompt());
    }

    locator<NavigationHelper>().go(const MainRoute().location);
    return biometricsEnabled;
  }
}

class CreateVaultState {
  final PasswordStrength strength;
  final bool biometricsAvailable;
  final bool useBiometrics;
  final bool acknowledged;
  final bool isSubmitting;

  const CreateVaultState({
    this.strength = PasswordStrength.veryWeak,
    this.biometricsAvailable = false,
    this.useBiometrics = true,
    this.acknowledged = false,
    this.isSubmitting = false,
  });

  bool get isStrongEnough => strength.index >= PasswordStrength.fair.index;

  CreateVaultState copyWith({
    PasswordStrength? strength,
    bool? biometricsAvailable,
    bool? useBiometrics,
    bool? acknowledged,
    bool? isSubmitting,
  }) => CreateVaultState(
    strength: strength ?? this.strength,
    biometricsAvailable: biometricsAvailable ?? this.biometricsAvailable,
    useBiometrics: useBiometrics ?? this.useBiometrics,
    acknowledged: acknowledged ?? this.acknowledged,
    isSubmitting: isSubmitting ?? this.isSubmitting,
  );
}
