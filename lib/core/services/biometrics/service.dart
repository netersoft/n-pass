import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

import '../../helpers/logging/log_helper.dart';
import '../shared_preferences/keys.dart';
import '../shared_preferences/service.dart';

/// Texts of the system biometric prompt (Android only; iOS uses
/// NSFaceIDUsageDescription).
class BiometricPrompt {
  final String title;
  final String cancel;

  const BiometricPrompt({required this.title, required this.cancel});
}

enum BiometricReadStatus { success, cancelled, unavailable }

class BiometricReadResult {
  final BiometricReadStatus status;
  final Uint8List? key;

  const BiometricReadResult._(this.status, [this.key]);

  const BiometricReadResult.success(Uint8List key) : this._(BiometricReadStatus.success, key);

  /// The user dismissed the prompt or failed to authenticate.
  const BiometricReadResult.cancelled() : this._(BiometricReadStatus.cancelled);

  /// The stored key is gone, typically because biometrics enrolled on the
  /// device changed: the password is needed to enable biometrics again.
  const BiometricReadResult.unavailable() : this._(BiometricReadStatus.unavailable);
}

/// Keeps a copy of the vault key in the platform keystore, readable only
/// after strong biometric authentication (Android Keystore key with user
/// authentication, iOS Keychain item bound to the current biometric set).
class BiometricService {
  static const String _storageKey = 'vault_key';

  final SharedPreferencesService _prefs;
  final LocalAuthentication _localAuth;
  final FlutterSecureStorage Function(BiometricPrompt prompt, {required bool resetOnError}) _storageFor;

  /// flutter_secure_storage 11.2.0 caches the unlocked cipher after the first
  /// write to a new biometric store (its non-biometric to biometric migration
  /// path assigns `storageCipher`, FlutterSecureStorage.java:659), so reads in
  /// the same process skip the prompt despite `requireBiometricsPerOperation`.
  /// Until the app restarts, an explicit local_auth prompt guards the read.
  bool _promptCachedThisSession = false;

  BiometricService(
    this._prefs, {
    LocalAuthentication? localAuth,
    FlutterSecureStorage Function(BiometricPrompt prompt, {required bool resetOnError})? storageFor,
  }) : _localAuth = localAuth ?? LocalAuthentication(),
       _storageFor = storageFor ?? _defaultStorage;

  /// Reads use `resetOnError: false`, so a cancelled prompt never wipes the
  /// stored key. Writes and deletes use `true`: it is the only way to get rid
  /// of a Keystore key invalidated by a biometric enrollment change, since the
  /// plugin fails to initialize the store before any delete otherwise.
  static FlutterSecureStorage _defaultStorage(BiometricPrompt prompt, {required bool resetOnError}) => FlutterSecureStorage(
    aOptions: AndroidOptions.biometric(
      resetOnError: resetOnError,
      enforceBiometrics: true,
      requireBiometricsPerOperation: true,
      biometricType: AndroidBiometricType.strongBiometricOnly,
      storageNamespace: 'npass_biometric',
      biometricPromptTitle: prompt.title,
      biometricPromptNegativeButton: prompt.cancel,
    ),
    iOptions: const IOSOptions(
      accessibility: KeychainAccessibility.unlocked_this_device,
      accessControlFlags: [AccessControlFlag.biometryCurrentSet],
    ),
  );

  bool get isEnabled => _prefs.getBool(PrefKeys.biometricsEnabled, defaultValue: false) ?? false;

  /// Whether the device has strong biometrics enrolled.
  Future<bool> isAvailable() async {
    try {
      if (!await _localAuth.isDeviceSupported()) return false;
      final types = await _localAuth.getAvailableBiometrics();
      return types.any((type) => type != BiometricType.weak);
    } on PlatformException catch (e) {
      LogHelper.w('Biometrics availability check failed', error: e);
      return false;
    }
  }

  /// Stores [vaultKey] behind biometrics. Returns false when the user cancels
  /// the prompt or the keystore refuses the key.
  Future<bool> enable(Uint8List vaultKey, BiometricPrompt prompt) async {
    try {
      await _storageFor(prompt, resetOnError: true).write(key: _storageKey, value: base64Encode(vaultKey));
      await _prefs.setBool(PrefKeys.biometricsEnabled, true);
      _promptCachedThisSession = true;
      return true;
    } on PlatformException catch (e) {
      LogHelper.w('Enabling biometrics failed', error: e);
      return false;
    }
  }

  Future<BiometricReadResult> readKey(BiometricPrompt prompt) async {
    try {
      if (_promptCachedThisSession) {
        final authenticated = await _localAuth.authenticate(localizedReason: prompt.title, biometricOnly: true);
        if (!authenticated) return const BiometricReadResult.cancelled();
      }
      final value = await _storageFor(prompt, resetOnError: false).read(key: _storageKey);
      if (value == null) return const BiometricReadResult.unavailable();
      return BiometricReadResult.success(base64Decode(value));
    } on PlatformException catch (e) {
      LogHelper.w('Biometric unlock failed', error: e);
      return _isKeyInvalidated(e) ? const BiometricReadResult.unavailable() : const BiometricReadResult.cancelled();
    } on Exception catch (e) {
      // LocalAuthException from local_auth.
      LogHelper.w('Biometric unlock failed', error: e);
      return const BiometricReadResult.cancelled();
    }
  }

  Future<void> disable(BiometricPrompt prompt) async {
    await _prefs.setBool(PrefKeys.biometricsEnabled, false);
    try {
      await _storageFor(prompt, resetOnError: true).delete(key: _storageKey);
    } on PlatformException catch (e) {
      LogHelper.w('Deleting the biometric key failed', error: e);
    }
  }

  /// Android: the Keystore key was invalidated because enrolled biometrics
  /// changed. The plugin only reports it inside a generic error.
  static bool _isKeyInvalidated(PlatformException e) => '${e.message} ${e.details}'.contains('KeyPermanentlyInvalidatedException');
}
