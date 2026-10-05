import 'package:flutter_test/flutter_test.dart';
import 'package:n_pass/core/models/vault_entry.dart';
import 'package:n_pass/core/tools/functions/entry_functions.dart';

VaultEntry entry(
  String title, {
  String username = '',
  String email = '',
  String url = '',
  String category = '',
  String password = '',
  bool favorite = false,
  int day = 1,
}) => VaultEntry(
  id: title,
  title: title,
  username: username,
  email: email,
  url: url,
  category: category,
  password: password,
  favorite: favorite,
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026, 1, day),
);

void main() {
  final entries = [
    entry('banque', username: 'jean.dupont', day: 3),
    entry('Énergie', email: 'jean@example.com'),
    entry('Netflix', url: 'netflix.com', day: 5),
    entry('apple ID', day: 2),
  ];

  group('filterAndSortEntries', () {
    test('sorts by title, ignoring case and accents', () {
      expect(filterAndSortEntries(entries).map((e) => e.title), ['apple ID', 'banque', 'Énergie', 'Netflix']);
    });

    test('sorts by most recently updated', () {
      expect(filterAndSortEntries(entries, sort: EntrySort.recent).map((e) => e.title), ['Netflix', 'banque', 'apple ID', 'Énergie']);
    });

    test('searches title, username, email and url, ignoring case and accents', () {
      expect(filterAndSortEntries(entries, query: 'ENERG').map((e) => e.title), ['Énergie']);
      expect(filterAndSortEntries(entries, query: 'jean').map((e) => e.title), ['banque', 'Énergie']);
      expect(filterAndSortEntries(entries, query: 'flix.com').map((e) => e.title), ['Netflix']);
      expect(filterAndSortEntries(entries, query: '  '), hasLength(4));
      expect(filterAndSortEntries(entries, query: 'nothing'), isEmpty);
    });

    test('does not modify the input list', () {
      final copy = [...entries];
      filterAndSortEntries(entries, sort: EntrySort.recent);
      expect(entries, copy);
    });
  });

  test('entryInitials', () {
    expect(entryInitials('Google Mail'), 'GM');
    expect(entryInitials('github'), 'GI');
    expect(entryInitials('  la banque postale '), 'LP');
    expect(entryInitials('é'), 'É');
    expect(entryInitials('   '), '?');
  });

  group('favorites and categories', () {
    final scoped = [
      entry('Zoom', category: 'Travail', favorite: true),
      entry('Banque', category: 'Finances'),
      entry('Slack', category: 'travail'),
      entry('Amazon', favorite: true, day: 9),
    ];

    test('lists favorites first in both sorts', () {
      expect(filterAndSortEntries(scoped).map((e) => e.title), ['Amazon', 'Zoom', 'Banque', 'Slack']);
      expect(filterAndSortEntries(scoped, sort: EntrySort.recent).map((e) => e.title).take(2), ['Amazon', 'Zoom']);
    });

    test('limits to favorites or to a category, ignoring case and accents', () {
      expect(filterAndSortEntries(scoped, favoritesOnly: true).map((e) => e.title), ['Amazon', 'Zoom']);
      expect(filterAndSortEntries(scoped, category: 'TRAVAIL').map((e) => e.title), ['Zoom', 'Slack']);
    });

    test('search also matches the category', () {
      expect(filterAndSortEntries(scoped, query: 'financ').map((e) => e.title), ['Banque']);
    });

    test('collects categories once, keeping the first spelling', () {
      expect(entryCategoriesOf(scoped), ['Finances', 'Travail']);
      expect(entryCategoriesOf([entry('a', category: '  ')]), isEmpty);
    });
  });

  test('entriesSharingPassword finds other entries with the same password', () {
    final list = [entry('A', password: 'same'), entry('B', password: 'same'), entry('C', password: 'other'), entry('D')];

    expect(entriesSharingPassword(list, 'same', exceptId: 'A').map((e) => e.title), ['B']);
    expect(entriesSharingPassword(list, ''), isEmpty, reason: 'empty passwords are not reuse');
  });
}
