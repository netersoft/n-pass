import 'package:collection/collection.dart';

import '../../models/vault_entry.dart';

enum EntrySort { title, recent }

/// Case- and accent-insensitive search on title, username, email, URL and
/// category, optionally limited to favorites or to one [category], then
/// sorted with favorites first.
List<VaultEntry> filterAndSortEntries(
  List<VaultEntry> entries, {
  String query = '',
  EntrySort sort = EntrySort.title,
  bool favoritesOnly = false,
  String? category,
}) {
  final needle = normalizeForSearch(query.trim());
  final categoryKey = category == null ? null : normalizeForSearch(category.trim());
  final matches = entries.where((e) {
    if (favoritesOnly && !e.favorite) return false;
    if (categoryKey != null && normalizeForSearch(e.category.trim()) != categoryKey) return false;
    if (needle.isEmpty) return true;
    return [e.title, e.username, e.email, e.url, e.category].any((field) => normalizeForSearch(field).contains(needle));
  }).toList();

  int byOrder(VaultEntry a, VaultEntry b) => switch (sort) {
    EntrySort.title => compareAsciiLowerCaseNatural(normalizeForSearch(a.title), normalizeForSearch(b.title)),
    EntrySort.recent => b.updatedAt.compareTo(a.updatedAt),
  };
  matches.sort((a, b) => a.favorite == b.favorite ? byOrder(a, b) : (a.favorite ? -1 : 1));
  return matches;
}

/// Categories in use, sorted, merging spellings that differ only by case or
/// accents (the first spelling met wins).
List<String> entryCategoriesOf(List<VaultEntry> entries) {
  final byKey = <String, String>{};
  for (final entry in entries) {
    final category = entry.category.trim();
    if (category.isNotEmpty) byKey.putIfAbsent(normalizeForSearch(category), () => category);
  }
  return byKey.entries.sortedByCompare((e) => e.key, compareAsciiLowerCaseNatural).map((e) => e.value).toList();
}

/// Other entries using [password] (exact match), excluding [exceptId].
List<VaultEntry> entriesSharingPassword(List<VaultEntry> entries, String password, {String? exceptId}) =>
    password.isEmpty ? const [] : entries.where((e) => e.id != exceptId && e.password == password).toList();

const _accents = {
  'à': 'a', 'â': 'a', 'ä': 'a', 'á': 'a', 'ã': 'a', 'å': 'a', //
  'ç': 'c',
  'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
  'î': 'i', 'ï': 'i', 'í': 'i', 'ì': 'i',
  'ñ': 'n',
  'ô': 'o', 'ö': 'o', 'ó': 'o', 'ò': 'o', 'õ': 'o',
  'û': 'u', 'ü': 'u', 'ú': 'u', 'ù': 'u',
  'ÿ': 'y',
  'œ': 'oe', 'æ': 'ae',
};

String normalizeForSearch(String value) => value.toLowerCase().split('').map((c) => _accents[c] ?? c).join();

/// Up to two initials for the entry avatar: first letters of the first and
/// last words ("Google Mail" -> "GM", "github" -> "GI").
String entryInitials(String title) {
  final words = title.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
  if (words.isEmpty) return '?';
  if (words.length == 1) return String.fromCharCodes(words.first.runes.take(2)).toUpperCase();
  return (String.fromCharCode(words.first.runes.first) + String.fromCharCode(words.last.runes.first)).toUpperCase();
}
