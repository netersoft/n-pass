import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';

import '../../models/vault_entry.dart';
import 'crypto.dart';
import 'store.dart';

/// Holds the vault key while the vault is unlocked and encrypts/decrypts
/// entries with it.
///
/// Key hierarchy: a random 256-bit vault key encrypts every entry
/// (AES-256-GCM, entry id bound as associated data). The vault key itself is
/// stored encrypted with a key derived from the master password (Argon2id),
/// so changing the password only re-encrypts the vault key.
class VaultService {
  static final List<int> _keyAad = utf8.encode('npass:vault-key:v1');
  static final List<int> _checkAad = utf8.encode('npass:key-check:v1');

  final VaultStore _store;
  final KdfParams Function() _newKdfParams;

  SecretKeyData? _key;

  /// Notifies when the vault gets locked or unlocked (router refresh).
  final ValueNotifier<bool> unlockedListenable = ValueNotifier(false);

  VaultService(this._store, {KdfParams Function()? newKdfParams}) : _newKdfParams = newKdfParams ?? KdfParams.generate;

  bool get isCreated => _store.readHeader() != null;

  bool get isUnlocked => _key != null;

  void _setKey(SecretKeyData? key) {
    _key?.destroy();
    _key = key;
    unlockedListenable.value = key != null;
  }

  /// Creates a new, empty vault protected by [password] and leaves it unlocked.
  Future<void> create(String password) async {
    if (isCreated) throw StateError('A vault already exists');

    final key = VaultCrypto.generateKey();
    final keyCheck = await VaultCrypto.encrypt(const [], key, aad: _checkAad);
    await _store.writeHeader(await _wrapKey(key, password, keyCheck));
    _setKey(key);
  }

  /// Returns false when [password] is wrong.
  Future<bool> unlock(String password) async {
    final header = _requireHeader();
    try {
      final kek = await VaultCrypto.deriveKey(password, header.kdf);
      final key = SecretKeyData(await VaultCrypto.decrypt(header.wrappedKey, kek, aad: _keyAad));
      kek.destroy();
      _setKey(key);
      return true;
    } on VaultAuthException {
      return false;
    }
  }

  /// Raw vault key bytes, for storing behind biometric authentication.
  Future<Uint8List> exportKey() async => Uint8List.fromList(await _requireKey().extractBytes());

  /// Unlocks with key bytes obtained from [exportKey]. Returns false when they
  /// don't open this vault.
  Future<bool> unlockWithKey(List<int> keyBytes) async {
    final header = _requireHeader();
    final candidate = SecretKeyData(keyBytes);
    try {
      await VaultCrypto.decrypt(header.keyCheck, candidate, aad: _checkAad);
    } on VaultAuthException {
      return false;
    }
    _setKey(candidate);
    return true;
  }

  void lock() => _setKey(null);

  /// Re-encrypts the vault key under [newPassword], with fresh Argon2id
  /// parameters. Returns false when [currentPassword] is wrong.
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    final header = _requireHeader();
    final SecretKeyData key;
    try {
      final kek = await VaultCrypto.deriveKey(currentPassword, header.kdf);
      key = SecretKeyData(await VaultCrypto.decrypt(header.wrappedKey, kek, aad: _keyAad));
      kek.destroy();
    } on VaultAuthException {
      return false;
    }
    await _store.writeHeader(await _wrapKey(key, newPassword, header.keyCheck));
    key.destroy();
    return true;
  }

  Future<List<VaultEntry>> readEntries() async {
    final key = _requireKey();
    final entries = <VaultEntry>[];
    for (final MapEntry(key: id, value: blob) in _store.readEntries().entries) {
      final json = utf8.decode(await VaultCrypto.decrypt(blob, key, aad: _entryAad(id)));
      entries.add(VaultEntry.fromJson(jsonDecode(json) as Map<String, dynamic>));
    }
    return entries;
  }

  Future<void> saveEntry(VaultEntry entry) async => _store.putEntry(entry.id, await _encryptEntry(entry));

  Future<void> saveEntries(Iterable<VaultEntry> entries) async => _store.putEntries({for (final entry in entries) entry.id: await _encryptEntry(entry)});

  /// Replaces the whole vault content with [entries]. They are all encrypted
  /// before anything is erased.
  Future<void> replaceEntries(Iterable<VaultEntry> entries) async {
    final blobs = {for (final entry in entries) entry.id: await _encryptEntry(entry)};
    await _store.replaceEntries(blobs);
  }

  Future<void> deleteEntry(String id) {
    _requireKey();
    return _store.deleteEntry(id);
  }

  /// Erases the vault and locks it. Irreversible.
  Future<void> destroy() async {
    lock();
    await _store.clear();
  }

  static String newEntryId() => VaultCrypto.randomBytes(16).map((b) => b.toRadixString(16).padLeft(2, '0')).join();

  Future<Uint8List> _encryptEntry(VaultEntry entry) => VaultCrypto.encrypt(utf8.encode(jsonEncode(entry.toJson())), _requireKey(), aad: _entryAad(entry.id));

  Future<VaultHeader> _wrapKey(SecretKeyData key, String password, Uint8List keyCheck) async {
    final kdf = _newKdfParams();
    final kek = await VaultCrypto.deriveKey(password, kdf);
    final wrapped = await VaultCrypto.encrypt(await key.extractBytes(), kek, aad: _keyAad);
    kek.destroy();
    return VaultHeader(kdf: kdf, wrappedKey: wrapped, keyCheck: keyCheck);
  }

  VaultHeader _requireHeader() => _store.readHeader() ?? (throw StateError('No vault has been created'));

  SecretKeyData _requireKey() => _key ?? (throw StateError('The vault is locked'));

  static List<int> _entryAad(String id) => utf8.encode('npass:entry:v1:$id');
}
