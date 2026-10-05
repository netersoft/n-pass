import 'package:collection/collection.dart';

import '../../models/vault_entry.dart';

enum EntrySort { title, recent }

/// Case- and accent-insensitive search on title, username, email and URL,
/// then sort.
List<VaultEntry> filterAndSortEntries(List<VaultEntry> entries, {String query = '', EntrySort sort = EntrySort.title}) {
  final needle = normalizeForSearch(query.trim());
  final matches = needle.isEmpty
      ? [...entries]
      : entries.where((e) => [e.title, e.username, e.email, e.url].any((field) => normalizeForSearch(field).contains(needle))).toList();

  switch (sort) {
    case EntrySort.title:
      matches.sort((a, b) => compareAsciiLowerCaseNatural(normalizeForSearch(a.title), normalizeForSearch(b.title)));
    case EntrySort.recent:
      matches.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }
  return matches;
}

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
