import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:n_pass/core/models/vault_entry.dart';

void main() {
  test('decodes entries saved before categories, favorites and custom fields', () {
    final entry = VaultEntry.fromJson({
      'id': 'a',
      'title': 'Mail',
      'createdAt': '2026-10-05T00:00:00.000Z',
      'updatedAt': '2026-10-05T00:00:00.000Z',
    });

    expect(entry.category, '');
    expect(entry.favorite, isFalse);
    expect(entry.customFields, isEmpty);
  });

  test('custom fields survive a JSON string round trip', () {
    final entry = VaultEntry(
      id: 'a',
      title: 'Bank',
      category: 'Finances',
      favorite: true,
      customFields: const [
        CustomField(label: 'PIN', value: '1234', hidden: true),
        CustomField(label: 'Branch', value: 'Lomé'),
      ],
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );

    final decoded = VaultEntry.fromJson(jsonDecode(jsonEncode(entry.toJson())) as Map<String, dynamic>);

    expect(decoded.customFields, entry.customFields);
    expect(decoded.category, 'Finances');
    expect(decoded.favorite, isTrue);
  });
}
