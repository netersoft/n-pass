import 'package:json_annotation/json_annotation.dart';

part 'vault_entry.g.dart';

/// A stored account. Serialized to JSON, then encrypted as a whole: new
/// fields must have defaults so older entries still decode.
@JsonSerializable()
class VaultEntry {
  final String id;
  final String title;
  final String username;
  final String email;
  final String password;
  final String url;
  final String notes;
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
    DateTime? updatedAt,
  }) => VaultEntry(
    id: id,
    title: title ?? this.title,
    username: username ?? this.username,
    email: email ?? this.email,
    password: password ?? this.password,
    url: url ?? this.url,
    notes: notes ?? this.notes,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
