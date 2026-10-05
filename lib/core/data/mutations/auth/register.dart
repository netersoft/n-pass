import 'package:cached_query_flutter/cached_query_flutter.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../services/api/response.dart';
import '../../../services/api/service.dart';

part 'register.g.dart';

@JsonSerializable()
class RegisterData {
  String? name;
  String? email;
  String? password;

  @JsonKey(name: 'password_confirmation')
  String? passwordConfirmation;

  @JsonKey(name: 'device_name')
  String? deviceName;

  RegisterData({
    this.name,
    this.email,
    this.password,
    this.passwordConfirmation,
    this.deviceName,
  });

  factory RegisterData.fromJson(Map<String, dynamic> json) => _$RegisterDataFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterDataToJson(this);
}

final useRegister = Mutation<ApiResponse, RegisterData>(
  mutationFn: (data) => ApiService.makeRequest(
    path: '/register',
    type: RequestType.post,
    data: data.toJson(),
  ),
);
