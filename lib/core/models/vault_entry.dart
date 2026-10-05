import 'package:json_annotation/json_annotation.dart';

import 'totp_config.dart';

part 'vault_entry.g.dart';

/// A stored account. Serialized to JSON, then encrypted as a whole: new
/// fields must have defaults so older entries still decode.
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class VaultEntry {
  final String id;
  final String title;
  final String username;
  final String email;
  final String password;
  final String url;
  final String notes;

  /// Free-form category chosen by the user; empty when uncategorized.
  final String category;
  final bool favorite;
  final List<CustomField> customFields;

  /// Two-factor code generator, when the account uses one.
  final TotpConfig? totp;
  final DateTime createdAt;
  final DateTime updatedAt;

  const VaultEntry({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.username = '',
    this.email = '',
    this.password = '',
    this.url = '',
    this.notes = '',
    this.category = '',
    this.favorite = false,
    this.customFields = const [],
    this.totp,
  });

  factory VaultEntry.fromJson(Map<String, dynamic> json) => _$VaultEntryFromJson(json);

  Map<String, dynamic> toJson() => _$VaultEntryToJson(this);

  VaultEntry copyWith({
    String? title,
    String? username,
    String? email,
    String? password,
    String? url,
    String? notes,
    String? category,
    bool? favorite,
    List<CustomField>? customFields,
    TotpConfig? totp,
    bool clearTotp = false,
    DateTime? updatedAt,
  }) => VaultEntry(
    id: id,
    title: title ?? this.title,
    username: username ?? this.username,
    email: email ?? this.email,
    password: password ?? this.password,
    url: url ?? this.url,
    notes: notes ?? this.notes,
    category: category ?? this.category,
    favorite: favorite ?? this.favorite,
    customFields: customFields ?? this.customFields,
    totp: clearTotp ? null : (totp ?? this.totp),
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}

/// An extra labelled value on an entry (PIN, security answer, account
/// number...). [hidden] values are masked and copied as secrets.
@JsonSerializable()
class CustomField {
  final String label;
  final String value;
  final bool hidden;

  const CustomField({required this.label, this.value = '', this.hidden = false});

  factory CustomField.fromJson(Map<String, dynamic> json) => _$CustomFieldFromJson(json);

  Map<String, dynamic> toJson() => _$CustomFieldToJson(this);

  CustomField copyWith({String? label, String? value, bool? hidden}) =>
      CustomField(label: label ?? this.label, value: value ?? this.value, hidden: hidden ?? this.hidden);

  @override
  bool operator ==(Object other) => other is CustomField && other.label == label && other.value == value && other.hidden == hidden;

  @override
  int get hashCode => Object.hash(label, value, hidden);
}
