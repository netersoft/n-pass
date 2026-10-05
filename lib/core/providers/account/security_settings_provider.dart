import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../services/auto_lock/service.dart';
import '../../services/biometrics/service.dart';
import '../../services/di/locator.dart';
import '../../services/shared_preferences/keys.dart';
import '../../services/shared_preferences/service.dart';
import '../../services/vault/service.dart';
import '../vault/biometric_prompt.dart';

part 'security_settings_provider.g.dart';

@riverpod
class SecuritySettings extends _$SecuritySettings {
  BiometricService get _biometrics => locator<BiometricService>();
  SharedPreferencesService get _prefs => locator<SharedPreferencesService>();

  @override
  SecuritySettingsState build() {
    _loadBiometricsAvailability();
    return SecuritySettingsState(
      biometricsEnabled: _biometrics.isEnabled,
      autoLockDelaySeconds: locator<AutoLockService>().delaySeconds,
      revealPasswords: _prefs.getBool(PrefKeys.revealPasswords, defaultValue: false) ?? false,
    );
  }

  Future<void> _loadBiometricsAvailability() async {
    final available = await _biometrics.isAvailable();
    if (!ref.mounted) return;
    state = state.copyWith(biometricsAvailable: available);
  }

  /// Returns false when biometrics could not be turned on (prompt cancelled,
  /// keystore error).
  Future<bool> setBiometrics(bool enabled) async {
    if (!enabled) {
      await _biometrics.disable(localizedBiometricPrompt());
      if (ref.mounted) state = state.copyWith(biometricsEnabled: false);
      return true;
    }

    final ok = await _biometrics.enable(await locator<VaultService>().exportKey(), localizedBiometricPrompt());
    if (ref.mounted) state = state.copyWith(biometricsEnabled: ok);
    return ok;
  }

  Future<void> setAutoLockDelay(int seconds) async {
    await locator<AutoLockService>().setDelaySeconds(seconds);
    if (ref.mounted) state = state.copyWith(autoLockDelaySeconds: seconds);
  }

  Future<void> setRevealPasswords(bool value) async {
    await _prefs.setBool(PrefKeys.revealPasswords, value);
    if (ref.mounted) state = state.copyWith(revealPasswords: value);
  }
}

class SecuritySettingsState {
  final bool biometricsAvailable;
  final bool biometricsEnabled;
  final int autoLockDelaySeconds;
  final bool revealPasswords;

  const SecuritySettingsState({
    this.biometricsAvailable = false,
    this.biometricsEnabled = false,
    this.autoLockDelaySeconds = AutoLockService.defaultDelay,
    this.revealPasswords = false,
  });

  SecuritySettingsState copyWith({bool? biometricsAvailable, bool? biometricsEnabled, int? autoLockDelaySeconds, bool? revealPasswords}) =>
      SecuritySettingsState(
        biometricsAvailable: biometricsAvailable ?? this.biometricsAvailable,
        biometricsEnabled: biometricsEnabled ?? this.biometricsEnabled,
        autoLockDelaySeconds: autoLockDelaySeconds ?? this.autoLockDelaySeconds,
        revealPasswords: revealPasswords ?? this.revealPasswords,
      );
}
