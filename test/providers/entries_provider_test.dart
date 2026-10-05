import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n_pass/core/models/vault_entry.dart';
import 'package:n_pass/core/providers/vault/entries_provider.dart';
import 'package:n_pass/core/services/backup/service.dart';
import 'package:n_pass/core/services/shared_preferences/keys.dart';
import 'package:n_pass/core/tools/functions/entry_functions.dart';

import '../helpers/test_utils.dart';

VaultEntry entry(String id, String title) => VaultEntry(id: id, title: title, createdAt: DateTime.utc(2026), updatedAt: DateTime.utc(2026));

void main() {
  late MockVaultService vault;
  late MockSharedPreferencesService prefs;
  late ValueNotifier<bool> unlocked;

  setUpAll(() {
    registerFallbackValue(entry('x', 'x'));
    registerFallbackValue(<VaultEntry>[]);
  });

  setUp(() async {
    vault = MockVaultService();
    prefs = MockSharedPreferencesService();
    unlocked = ValueNotifier(true);
    await setupTestLocator(sharedPreferencesService: prefs, vaultService: vault);
    when(() => vault.unlockedListenable).thenReturn(unlocked);
    when(() => vault.isUnlocked).thenAnswer((_) => unlocked.value);
    when(() => vault.readEntries()).thenAnswer((_) async => [entry('1', 'Mail'), entry('2', 'Bank')]);
    when(() => vault.saveEntry(any())).thenAnswer((_) async {});
    when(() => vault.deleteEntry(any())).thenAnswer((_) async {});
    when(() => vault.saveEntries(any())).thenAnswer((_) async {});
    when(() => vault.replaceEntries(any())).thenAnswer((_) async {});
    when(() => prefs.getString(any(), defaultValue: any(named: 'defaultValue'))).thenReturn(null);
    when(() => prefs.setString(any(), any())).thenAnswer((_) async => true);
  });

  tearDown(teardownTestLocator);

  ProviderContainer container() {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    return c;
  }

  test('loads the decrypted entries while unlocked', () async {
    final entries = await container().read(entriesProvider.future);

    expect(entries.map((e) => e.title), ['Mail', 'Bank']);
  });

  test('drops the entries from memory when the vault locks', () async {
    final c = container();
    await c.read(entriesProvider.future);

    unlocked.value = false;

    expect(await c.read(entriesProvider.future), isEmpty);
  });

  test('save adds or replaces, delete removes', () async {
    final c = container();
    await c.read(entriesProvider.future);
    final notifier = c.read(entriesProvider.notifier);

    await notifier.save(entry('3', 'Netflix'));
    await notifier.save(entry('1', 'Gmail'));
    await notifier.delete('2');

    expect(c.read(entriesProvider).value!.map((e) => e.title), unorderedEquals(['Netflix', 'Gmail']));
    verify(() => vault.saveEntry(any())).called(2);
    verify(() => vault.deleteEntry('2')).called(1);
    expect(c.read(entryByIdProvider('1'))?.title, 'Gmail');
    expect(c.read(entryByIdProvider('2')), isNull);
  });

  test('visible entries follow the query and the persisted sort', () async {
    when(() => prefs.getString(PrefKeys.entrySort, defaultValue: any(named: 'defaultValue'))).thenReturn('title');
    final c = container();
    await c.read(entriesProvider.future);

    expect(c.read(visibleEntriesProvider).value!.map((e) => e.title), ['Bank', 'Mail']);

    c.read(entriesFilterProvider.notifier).setQuery('ma');
    expect(c.read(visibleEntriesProvider).value!.map((e) => e.title), ['Mail']);

    c.read(entriesFilterProvider.notifier).setSort(EntrySort.recent);
    verify(() => prefs.setString(PrefKeys.entrySort, 'recent')).called(1);
  });

  test('a merge import writes only new or more recent entries', () async {
    final c = container();
    await c.read(entriesProvider.future);
    final newer = entry('1', 'Gmail').copyWith(updatedAt: DateTime.utc(2027));

    final plan = await c.read(entriesProvider.notifier).import([newer, entry('2', 'Bank'), entry('3', 'Netflix')], ImportMode.merge);

    expect((plan.added, plan.updated, plan.unchanged), (1, 1, 1));
    final saved = verify(() => vault.saveEntries(captureAny())).captured.single as Iterable<VaultEntry>;
    expect(saved.map((e) => e.id), ['1', '3']);
    expect(c.read(entriesProvider).value!.map((e) => e.title), unorderedEquals(['Gmail', 'Bank', 'Netflix']));
  });

  test('a replace import swaps every entry', () async {
    final c = container();
    await c.read(entriesProvider.future);

    await c.read(entriesProvider.notifier).import([entry('9', 'Only')], ImportMode.replace);

    verify(() => vault.replaceEntries(any())).called(1);
    expect(c.read(entriesProvider).value!.map((e) => e.title), ['Only']);
  });
}
