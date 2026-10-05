import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/vault_entry.dart';
import '../../services/di/locator.dart';
import '../../services/shared_preferences/keys.dart';
import '../../services/shared_preferences/service.dart';
import '../../services/vault/service.dart';
import '../../tools/functions/entry_functions.dart';

part 'entries_provider.g.dart';

/// Decrypted entries, held only while the vault is unlocked: locking the
/// vault rebuilds this provider with an empty list.
@Riverpod(keepAlive: true)
class Entries extends _$Entries {
  VaultService get _vault => locator<VaultService>();

  @override
  Future<List<VaultEntry>> build() async {
    final listenable = _vault.unlockedListenable..addListener(ref.invalidateSelf);
    ref.onDispose(() => listenable.removeListener(ref.invalidateSelf));

    if (!_vault.isUnlocked) return const [];
    return _vault.readEntries();
  }

  /// Adds or replaces an entry.
  Future<void> save(VaultEntry entry) async {
    await _vault.saveEntry(entry);
    final current = state.value ?? const [];
    state = AsyncData([...current.where((e) => e.id != entry.id), entry]);
  }

  Future<void> delete(String id) async {
    await _vault.deleteEntry(id);
    state = AsyncData((state.value ?? const []).where((e) => e.id != id).toList());
  }
}

@riverpod
VaultEntry? entryById(Ref ref, String id) => ref.watch(entriesProvider).value?.where((e) => e.id == id).firstOrNull;

@Riverpod(keepAlive: true)
class EntriesFilter extends _$EntriesFilter {
  SharedPreferencesService get _prefs => locator<SharedPreferencesService>();

  @override
  EntriesFilterState build() {
    final sortName = _prefs.getString(PrefKeys.entrySort);
    return EntriesFilterState(sort: EntrySort.values.asNameMap()[sortName] ?? EntrySort.title);
  }

  void setQuery(String query) => state = state.copyWith(query: query);

  void setSort(EntrySort sort) {
    _prefs.setString(PrefKeys.entrySort, sort.name);
    state = state.copyWith(sort: sort);
  }
}

class EntriesFilterState {
  final String query;
  final EntrySort sort;

  const EntriesFilterState({this.query = '', this.sort = EntrySort.title});

  EntriesFilterState copyWith({String? query, EntrySort? sort}) => EntriesFilterState(query: query ?? this.query, sort: sort ?? this.sort);
}

@riverpod
AsyncValue<List<VaultEntry>> visibleEntries(Ref ref) {
  final filter = ref.watch(entriesFilterProvider);
  return ref.watch(entriesProvider).whenData((entries) => filterAndSortEntries(entries, query: filter.query, sort: filter.sort));
}
