import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/vault_entry.dart';
import '../../services/backup/service.dart';
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

  /// Not an edit: keeps [VaultEntry.updatedAt], so the entry doesn't jump to
  /// the top of the recently modified list.
  Future<void> toggleFavorite(VaultEntry entry) => save(entry.copyWith(favorite: !entry.favorite));

  Future<void> delete(String id) async {
    await _vault.deleteEntry(id);
    state = AsyncData((state.value ?? const []).where((e) => e.id != id).toList());
  }

  /// Writes entries restored from a backup and returns what changed.
  Future<ImportPlan> import(List<VaultEntry> imported, ImportMode mode) async {
    final current = await future;
    switch (mode) {
      case ImportMode.replace:
        await _vault.replaceEntries(imported);
        state = AsyncData(List.of(imported));
        return ImportPlan(toSave: imported, added: imported.length, updated: 0, unchanged: 0);
      case ImportMode.merge:
        final plan = planMergeImport(current, imported);
        await _vault.saveEntries(plan.toSave);
        final saved = {for (final entry in plan.toSave) entry.id};
        state = AsyncData([...current.where((e) => !saved.contains(e.id)), ...plan.toSave]);
        return plan;
    }
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

  /// Shows every entry, only favorites, or one category.
  void setScope({bool favoritesOnly = false, String? category}) =>
      state = EntriesFilterState(query: state.query, sort: state.sort, favoritesOnly: favoritesOnly, category: category);

  void setSort(EntrySort sort) {
    _prefs.setString(PrefKeys.entrySort, sort.name);
    state = state.copyWith(sort: sort);
  }
}

class EntriesFilterState {
  final String query;
  final EntrySort sort;
  final bool favoritesOnly;

  /// Only entries of this category when set.
  final String? category;

  const EntriesFilterState({this.query = '', this.sort = EntrySort.title, this.favoritesOnly = false, this.category});

  bool get isScoped => favoritesOnly || category != null;

  EntriesFilterState copyWith({String? query, EntrySort? sort}) =>
      EntriesFilterState(query: query ?? this.query, sort: sort ?? this.sort, favoritesOnly: favoritesOnly, category: category);
}

@riverpod
AsyncValue<List<VaultEntry>> visibleEntries(Ref ref) {
  final filter = ref.watch(entriesFilterProvider);
  return ref
      .watch(entriesProvider)
      .whenData(
        (entries) => filterAndSortEntries(entries, query: filter.query, sort: filter.sort, favoritesOnly: filter.favoritesOnly, category: filter.category),
      );
}

@riverpod
List<String> entryCategories(Ref ref) => entryCategoriesOf(ref.watch(entriesProvider).value ?? const []);
