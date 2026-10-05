import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  int? id;

  String? name;

  String? email;

  String? avatar;

  String? locale;

  @JsonKey(name: 'email_verified_at')
  DateTime? emailVerifiedAt;

  @JsonKey(name: 'two_factor_confirmed_at')
  DateTime? twoFactorConfirmedAt;

  @JsonKey(name: 'created_at')
  DateTime? createdAt;

  @JsonKey(name: 'updated_at')
  DateTime? updatedAt;

  UserModel({
    this.id,
    this.name,
    this.email,
    this.avatar,
    this.locale,
    this.emailVerifiedAt,
    this.twoFactorConfirmedAt,
    this.createdAt,
    this.updatedAt,
  });

  bool get hasTwoFactorEnabled => twoFactorConfirmedAt != null;

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  @override
  String toString() => toJson().toString();
}
