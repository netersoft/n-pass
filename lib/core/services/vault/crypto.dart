import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

/// Thrown when a ciphertext fails authentication: wrong key (wrong master
/// password) or tampered data.
class VaultAuthException implements Exception {
  const VaultAuthException();

  @override
  String toString() => 'VaultAuthException: authentication failed';
}

/// Argon2id parameters used to derive the key-encryption key from the master
/// password. Stored in clear next to the wrapped vault key so they can be
/// raised later without breaking existing vaults.
class KdfParams {
  final int memoryKiB;
  final int iterations;
  final int parallelism;
  final Uint8List salt;

  const KdfParams({
    required this.memoryKiB,
    required this.iterations,
    required this.parallelism,
    required this.salt,
  });

  /// Defaults: 64 MiB, 2 passes, 1 lane (~0.3 s on an M-series Mac in AOT,
  /// around 1 s on a mid-range phone).
  factory KdfParams.generate({int memoryKiB = 65536, int iterations = 2, int parallelism = 1}) => KdfParams(
    memoryKiB: memoryKiB,
    iterations: iterations,
    parallelism: parallelism,
    salt: VaultCrypto.randomBytes(16),
  );

  factory KdfParams.fromJson(Map<String, dynamic> json) => KdfParams(
    memoryKiB: json['memoryKiB'] as int,
    iterations: json['iterations'] as int,
    parallelism: json['parallelism'] as int,
    salt: base64Decode(json['salt'] as String),
  );

  Map<String, dynamic> toJson() => {
    'memoryKiB': memoryKiB,
    'iterations': iterations,
    'parallelism': parallelism,
    'salt': base64Encode(salt),
  };
}

/// Low-level primitives: Argon2id key derivation and AES-256-GCM.
///
/// Ciphertexts are laid out as `nonce (12) | ciphertext | mac (16)`.
abstract class VaultCrypto {
  static const int keyLength = 32;
  static const int _nonceLength = 12;
  static const int _macLength = 16;

  static final AesGcm _aes = AesGcm.with256bits();
  static final Random _random = Random.secure();

  static Uint8List randomBytes(int length) => Uint8List.fromList(List<int>.generate(length, (_) => _random.nextInt(256)));

  static SecretKeyData generateKey() => SecretKeyData(randomBytes(keyLength));

  /// Derives a 256-bit key from [password]. Runs in a background isolate:
  /// Argon2id is pure Dart here and would otherwise freeze the UI.
  static Future<SecretKeyData> deriveKey(String password, KdfParams params) async {
    final bytes = await Isolate.run(() async {
      final algorithm = Argon2id(
        memory: params.memoryKiB,
        iterations: params.iterations,
        parallelism: params.parallelism,
        hashLength: keyLength,
      );
      final key = await algorithm.deriveKeyFromPassword(password: password, nonce: params.salt);
      return key.extractBytes();
    });
    return SecretKeyData(bytes);
  }

  static Future<Uint8List> encrypt(List<int> clearText, SecretKey key, {List<int> aad = const []}) async {
    final box = await _aes.encrypt(clearText, secretKey: key, nonce: randomBytes(_nonceLength), aad: aad);
    return Uint8List.fromList(box.concatenation());
  }

  /// Throws [VaultAuthException] when [key] or [aad] don't match, or when
  /// [blob] was modified.
  static Future<Uint8List> decrypt(Uint8List blob, SecretKey key, {List<int> aad = const []}) async {
    if (blob.length < _nonceLength + _macLength) throw const VaultAuthException();

    final box = SecretBox.fromConcatenation(blob, nonceLength: _nonceLength, macLength: _macLength, copy: false);
    try {
      return Uint8List.fromList(await _aes.decrypt(box, secretKey: key, aad: aad));
    } on SecretBoxAuthenticationError {
      throw const VaultAuthException();
    }
  }
}
