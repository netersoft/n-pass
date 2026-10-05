import 'package:cached_query_flutter/cached_query_flutter.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../services/api/response.dart';
import '../../../services/api/service.dart';

part 'reset_password.g.dart';

@JsonSerializable()
class ResetPasswordData {
  String? token;
  String? email;
  String? password;

  @JsonKey(name: 'password_confirmation')
  String? passwordConfirmation;

  ResetPasswordData({
    this.token,
    this.email,
    this.password,
    this.passwordConfirmation,
  });

  factory ResetPasswordData.fromJson(Map<String, dynamic> json) => _$ResetPasswordDataFromJson(json);

  Map<String, dynamic> toJson() => _$ResetPasswordDataToJson(this);
}

final useResetPassword = Mutation<ApiResponse, ResetPasswordData>(
  mutationFn: (data) => ApiService.makeRequest(
    path: '/reset-password',
    type: RequestType.post,
    data: data.toJson(),
  ),
);
