import 'package:cached_query_flutter/cached_query_flutter.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../services/api/response.dart';
import '../../../services/api/service.dart';

part 'login.g.dart';

@JsonSerializable()
class LoginData {
  String? email;
  String? password;
  bool remember;

  @JsonKey(name: 'device_name')
  String? deviceName;

  LoginData({
    this.email,
    this.password,
    this.remember = true,
    this.deviceName,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) => _$LoginDataFromJson(json);

  Map<String, dynamic> toJson() => _$LoginDataToJson(this);
}

final useLogin = Mutation<ApiResponse, LoginData>(
  mutationFn: (data) => ApiService.makeRequest(
    path: '/login',
    type: RequestType.post,
    data: data.toJson(),
  ),
);
