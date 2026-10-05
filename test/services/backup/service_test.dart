import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:n_pass/core/models/vault_entry.dart';
import 'package:n_pass/core/services/backup/service.dart';
import 'package:n_pass/core/services/vault/crypto.dart';

import '../vault/crypto_test.dart' show fastKdf;

VaultEntry entry(String id, {String title = 'Mail', DateTime? updatedAt}) => VaultEntry(
  id: id,
  title: title,
  password: 'p@ss $id',
  notes: 'notes é',
  createdAt: DateTime.utc(2026),
  updatedAt: updatedAt ?? DateTime.utc(2026),
);

Uint8List jsonBytes(Object json) => utf8.encode(jsonEncode(json));

void main() {
  final backup = BackupService(newKdfParams: fastKdf, now: () => DateTime.utc(2026, 10, 5));

  group('BackupService', () {
    test('decodes what it encoded with the same password', () async {
      final entries = [entry('a'), entry('b', title: 'Bank')];

      final decoded = await backup.decode(await backup.encode(entries, 'backup password'), 'backup password');

      expect(decoded.map((e) => e.toJson()), entries.map((e) => e.toJson()));
    });

    test('keeps the entries out of the file in clear', () async {
      final bytes = await backup.encode([entry('a')], 'backup password');
      final text = utf8.decode(bytes);

      expect(text, isNot(contains('p@ss')));
      expect(text, isNot(contains('Mail')));
      expect(jsonDecode(text), containsPair('format', 'npass-backup'));
    });

    test('uses a fresh salt for every export', () async {
      Map<String, dynamic> kdf(Uint8List bytes) => (jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>)['kdf'] as Map<String, dynamic>;

      final a = await backup.encode([entry('a')], 'pw');
      final b = await backup.encode([entry('a')], 'pw');

      expect(kdf(a)['salt'], isNot(kdf(b)['salt']));
    });

    test('rejects a wrong password', () async {
      final bytes = await backup.encode([entry('a')], 'right');

      expect(backup.decode(bytes, 'wrong'), throwsA(isA<VaultAuthException>()));
    });

    test('rejects tampered data', () async {
      final json = jsonDecode(utf8.decode(await backup.encode([entry('a')], 'pw'))) as Map<String, dynamic>;
      final data = base64Decode(json['data'] as String);
      data[20] ^= 1;
      json['data'] = base64Encode(data);

      expect(backup.decode(jsonBytes(json), 'pw'), throwsA(isA<VaultAuthException>()));
    });

    test('rejects files that are not backups before asking for a password', () {
      for (final bytes in [
        Uint8List.fromList([0xff, 0xfe, 0x00]),
        utf8.encode('hello'),
        jsonBytes([1, 2]),
        jsonBytes({'format': 'other', 'version': 1}),
        jsonBytes({'format': 'npass-backup', 'version': 1}),
      ]) {
        expect(
          () => backup.validate(bytes),
          throwsA(isA<BackupFormatException>().having((e) => e.newerVersion, 'newerVersion', isFalse)),
          reason: utf8.decode(bytes, allowMalformed: true),
        );
      }
    });

    test('tells apart a backup from a newer version', () async {
      final json = jsonDecode(utf8.decode(await backup.encode([entry('a')], 'pw'))) as Map<String, dynamic>;
      json['version'] = BackupService.currentVersion + 1;

      expect(() => backup.validate(jsonBytes(json)), throwsA(isA<BackupFormatException>().having((e) => e.newerVersion, 'newerVersion', isTrue)));
    });

    test('accepts its own files', () async {
      final bytes = await backup.encode([], 'pw');

      expect(() => backup.validate(bytes), returnsNormally);
    });
  });

  group('planMergeImport', () {
    final old = DateTime.utc(2025, 12);
    final recent = DateTime.utc(2026, 6);

    test('adds new entries, updates older ones and skips the rest', () {
      final existing = [entry('same', updatedAt: recent), entry('stale', updatedAt: old), entry('newer', updatedAt: recent)];
      final imported = [
        entry('same', updatedAt: recent),
        entry('stale', title: 'Updated', updatedAt: recent),
        entry('newer', updatedAt: old),
        entry('fresh'),
      ];

      final plan = planMergeImport(existing, imported);

      expect(plan.toSave.map((e) => e.id), ['stale', 'fresh']);
      expect(plan.toSave.first.title, 'Updated');
      expect((plan.added, plan.updated, plan.unchanged), (1, 1, 2));
    });
  });
}
