import 'dart:typed_data';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/vault_entry.dart';
import '../../services/backup/service.dart';
import '../../services/di/locator.dart';
import '../../services/shared_preferences/keys.dart';
import '../../services/shared_preferences/service.dart';
import 'entries_provider.dart';

part 'backup_provider.g.dart';

@riverpod
class Backup extends _$Backup {
  SharedPreferencesService get _prefs => locator<SharedPreferencesService>();

  @override
  BackupState build() => BackupState(lastBackupAt: DateTime.tryParse(_prefs.getString(PrefKeys.lastBackupAt) ?? ''));

  /// Encrypts every entry with [password]. Returns null when the vault is
  /// empty.
  Future<Uint8List?> export(String password) async {
    final entries = await ref.read(entriesProvider.future);
    if (entries.isEmpty) return null;
    return _busy(() => locator<BackupService>().encode(entries, password));
  }

  Future<void> markExported() async {
    final now = DateTime.now().toUtc();
    await _prefs.setString(PrefKeys.lastBackupAt, now.toIso8601String());
    if (ref.mounted) state = state.copyWith(lastBackupAt: now);
  }

  /// Throws [BackupFormatException] when [bytes] are not a readable backup.
  void validate(Uint8List bytes) => locator<BackupService>().validate(bytes);

  /// Throws [BackupFormatException] or, for a wrong password,
  /// VaultAuthException.
  Future<List<VaultEntry>> decrypt(Uint8List bytes, String password) => _busy(() => locator<BackupService>().decode(bytes, password));

  Future<ImportPlan> restore(List<VaultEntry> entries, ImportMode mode) => _busy(() => ref.read(entriesProvider.notifier).import(entries, mode));

  Future<T> _busy<T>(Future<T> Function() run) async {
    state = state.copyWith(isBusy: true);
    try {
      return await run();
    } finally {
      if (ref.mounted) state = state.copyWith(isBusy: false);
    }
  }
}

class BackupState {
  final DateTime? lastBackupAt;
  final bool isBusy;

  const BackupState({this.lastBackupAt, this.isBusy = false});

  BackupState copyWith({DateTime? lastBackupAt, bool? isBusy}) => BackupState(lastBackupAt: lastBackupAt ?? this.lastBackupAt, isBusy: isBusy ?? this.isBusy);
}
