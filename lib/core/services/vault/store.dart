import 'dart:convert';
import 'dart:typed_data';

import 'package:hive_ce/hive.dart';

import 'crypto.dart';

/// What is persisted to unlock the vault: the Argon2id parameters, the vault
/// key encrypted with the key derived from the master password, and a check
/// value encrypted with the vault key itself (to validate a key obtained
/// another way, e.g. through biometrics).
class VaultHeader {
  static const int currentVersion = 1;

  final int version;
  final KdfParams kdf;
  final Uint8List wrappedKey;
  final Uint8List keyCheck;

  const VaultHeader({
    required this.kdf,
    required this.wrappedKey,
    required this.keyCheck,
    this.version = currentVersion,
  });

  factory VaultHeader.fromJson(Map<String, dynamic> json) => VaultHeader(
    version: json['version'] as int,
    kdf: KdfParams.fromJson(json['kdf'] as Map<String, dynamic>),
    wrappedKey: base64Decode(json['wrappedKey'] as String),
    keyCheck: base64Decode(json['keyCheck'] as String),
  );

  Map<String, dynamic> toJson() => {
    'version': version,
    'kdf': kdf.toJson(),
    'wrappedKey': base64Encode(wrappedKey),
    'keyCheck': base64Encode(keyCheck),
  };
}

/// Persistence of the vault. Entries are stored as opaque encrypted blobs
/// keyed by entry id; nothing in here is readable without the vault key.
class VaultStore {
  static const String metaBoxName = 'vault_meta';
  static const String entriesBoxName = 'vault_entries';
  static const String _headerKey = 'header';

  final Box<String> _meta;
  final Box<Uint8List> _entries;

  VaultStore._(this._meta, this._entries);

  static Future<VaultStore> open() async => VaultStore._(
    await Hive.openBox<String>(metaBoxName),
    await Hive.openBox<Uint8List>(entriesBoxName),
  );

  VaultHeader? readHeader() {
    final raw = _meta.get(_headerKey);
    return raw == null ? null : VaultHeader.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> writeHeader(VaultHeader header) => _meta.put(_headerKey, jsonEncode(header.toJson()));

  Map<String, Uint8List> readEntries() => {for (final key in _entries.keys) key as String: _entries.get(key)!};

  Future<void> putEntry(String id, Uint8List blob) => _entries.put(id, blob);

  Future<void> putEntries(Map<String, Uint8List> blobs) => _entries.putAll(blobs);

  Future<void> deleteEntry(String id) => _entries.delete(id);

  /// Erases the whole vault, header included.
  Future<void> clear() async {
    await _entries.clear();
    await _meta.clear();
  }
}
