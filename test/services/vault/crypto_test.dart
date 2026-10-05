import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:n_pass/core/services/vault/crypto.dart';

// Minimal Argon2id cost so the suite stays fast.
KdfParams fastKdf({Uint8List? salt}) => KdfParams(memoryKiB: 64, iterations: 1, parallelism: 1, salt: salt ?? VaultCrypto.randomBytes(16));

void main() {
  group('VaultCrypto', () {
    test('encrypt then decrypt returns the clear text', () async {
      final key = VaultCrypto.generateKey();
      final blob = await VaultCrypto.encrypt(utf8.encode('secret'), key, aad: [1, 2]);

      expect(utf8.decode(await VaultCrypto.decrypt(blob, key, aad: [1, 2])), 'secret');
    });

    test('encrypting twice gives different ciphertexts (random nonce)', () async {
      final key = VaultCrypto.generateKey();

      expect(await VaultCrypto.encrypt([1, 2, 3], key), isNot(await VaultCrypto.encrypt([1, 2, 3], key)));
    });

    test('decrypt rejects a wrong key, a wrong aad, a tampered or truncated blob', () async {
      final key = VaultCrypto.generateKey();
      final blob = await VaultCrypto.encrypt(utf8.encode('secret'), key, aad: [1]);
      final tampered = Uint8List.fromList(blob)..[14] ^= 1;

      await expectLater(VaultCrypto.decrypt(blob, VaultCrypto.generateKey(), aad: [1]), throwsA(isA<VaultAuthException>()));
      await expectLater(VaultCrypto.decrypt(blob, key, aad: [2]), throwsA(isA<VaultAuthException>()));
      await expectLater(VaultCrypto.decrypt(tampered, key, aad: [1]), throwsA(isA<VaultAuthException>()));
      await expectLater(VaultCrypto.decrypt(blob.sublist(0, 20), key, aad: [1]), throwsA(isA<VaultAuthException>()));
    });

    test('deriveKey is deterministic for a password and salt', () async {
      final params = fastKdf();
      final a = await VaultCrypto.deriveKey('password', params);
      final b = await VaultCrypto.deriveKey('password', params);
      final otherSalt = await VaultCrypto.deriveKey('password', fastKdf());
      final otherPassword = await VaultCrypto.deriveKey('Password', params);

      expect(a.bytes, hasLength(VaultCrypto.keyLength));
      expect(a.bytes, b.bytes);
      expect(a.bytes, isNot(otherSalt.bytes));
      expect(a.bytes, isNot(otherPassword.bytes));
    });

    test('KdfParams survive a JSON round trip', () {
      final params = KdfParams.generate();
      final copy = KdfParams.fromJson(jsonDecode(jsonEncode(params.toJson())) as Map<String, dynamic>);

      expect(params.memoryKiB, 65536);
      expect(copy.memoryKiB, params.memoryKiB);
      expect(copy.iterations, params.iterations);
      expect(copy.parallelism, params.parallelism);
      expect(copy.salt, params.salt);
    });
  });
}
