import 'dart:convert';
import 'dart:typed_data';

import '../../models/vault_entry.dart';
import '../vault/crypto.dart';

/// Thrown when a file is not an NPass backup, or a backup from a newer
/// version of the app.
class BackupFormatException implements Exception {
  /// The file is a backup, but its format version is unknown to this app.
  final bool newerVersion;

  const BackupFormatException({this.newerVersion = false});

  @override
  String toString() => 'BackupFormatException: ${newerVersion ? 'made by a newer version' : 'not an NPass backup'}';
}

/// Encrypted export of the vault entries, independent from the vault key.
///
/// File layout (JSON, UTF-8):
/// `{"format": "npass-backup", "version": 1, "kdf": {...}, "data": "<base64>"}`
/// where `data` is the AES-256-GCM encryption of
/// `{"exportedAt": "...", "entries": [...]}` with a key derived from the
/// backup password (Argon2id, fresh salt per export).
class BackupService {
  static const String format = 'npass-backup';
  static const int currentVersion = 1;
  static const String fileExtension = 'npass';

  /// Far above any real vault; rejects unrelated big files early.
  static const int maxFileSize = 16 * 1024 * 1024;
  static final List<int> _aad = utf8.encode('npass:backup:v1');

  final KdfParams Function() _newKdfParams;
  final DateTime Function() _now;

  BackupService({KdfParams Function()? newKdfParams, DateTime Function()? now})
    : _newKdfParams = newKdfParams ?? KdfParams.generate,
      _now = now ?? DateTime.now;

  Future<Uint8List> encode(List<VaultEntry> entries, String password) async {
    final kdf = _newKdfParams();
    final key = await VaultCrypto.deriveKey(password, kdf);
    final payload = utf8.encode(
      jsonEncode({
        'exportedAt': _now().toUtc().toIso8601String(),
        'entries': [for (final entry in entries) entry.toJson()],
      }),
    );
    final data = await VaultCrypto.encrypt(payload, key, aad: _aad);
    key.destroy();
    return utf8.encode(jsonEncode({'format': format, 'version': currentVersion, 'kdf': kdf.toJson(), 'data': base64Encode(data)}));
  }

  /// Checks that [bytes] look like a backup this version can read, before
  /// asking for its password. Throws [BackupFormatException] otherwise.
  void validate(Uint8List bytes) => _parse(bytes);

  /// Throws [BackupFormatException] when [bytes] are not a backup this
  /// version can read, and [VaultAuthException] when [password] is wrong.
  Future<List<VaultEntry>> decode(Uint8List bytes, String password) async {
    final (kdf, data) = _parse(bytes);
    final key = await VaultCrypto.deriveKey(password, kdf);
    final Uint8List payload;
    try {
      payload = await VaultCrypto.decrypt(data, key, aad: _aad);
    } finally {
      key.destroy();
    }
    final json = jsonDecode(utf8.decode(payload)) as Map<String, dynamic>;
    return [for (final entry in json['entries'] as List<dynamic>) VaultEntry.fromJson(entry as Map<String, dynamic>)];
  }

  (KdfParams, Uint8List) _parse(Uint8List bytes) {
    if (bytes.length > maxFileSize) throw const BackupFormatException();
    try {
      final json = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
      if (json['format'] != format) throw const BackupFormatException();
      if ((json['version'] as int) > currentVersion) throw const BackupFormatException(newerVersion: true);
      return (KdfParams.fromJson(json['kdf'] as Map<String, dynamic>), base64Decode(json['data'] as String));
    } on BackupFormatException {
      rethrow;
    } on Object {
      // Malformed UTF-8 or JSON, missing or mistyped fields.
      throw const BackupFormatException();
    }
  }
}

enum ImportMode {
  /// Adds the backup entries to the vault. An entry already in the vault is
  /// only replaced by a more recently updated copy from the backup.
  merge,

  /// Replaces the whole vault content with the backup.
  replace,
}

class ImportPlan {
  /// Entries to write, in the order of the backup.
  final List<VaultEntry> toSave;
  final int added;
  final int updated;
  final int unchanged;

  const ImportPlan({required this.toSave, required this.added, required this.updated, required this.unchanged});
}

/// Decides which backup entries a merge import writes, matching entries by id.
ImportPlan planMergeImport(List<VaultEntry> existing, List<VaultEntry> imported) {
  final byId = {for (final entry in existing) entry.id: entry};
  final toSave = <VaultEntry>[];
  var added = 0;
  var updated = 0;
  var unchanged = 0;
  for (final entry in imported) {
    final current = byId[entry.id];
    if (current == null) {
      added++;
    } else if (entry.updatedAt.isAfter(current.updatedAt)) {
      updated++;
    } else {
      unchanged++;
      continue;
    }
    toSave.add(entry);
  }
  return ImportPlan(toSave: toSave, added: added, updated: updated, unchanged: unchanged);
}
