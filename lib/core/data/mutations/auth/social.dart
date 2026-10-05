import 'package:cached_query_flutter/cached_query_flutter.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../services/api/response.dart';
import '../../../services/api/service.dart';

part 'social.g.dart';

enum SocialAuthProvider { google, apple }

@JsonSerializable()
class SocialAuthData {
  String? token;

  @JsonKey(name: 'device_name')
  String? deviceName;

  SocialAuthData({this.token, this.deviceName});

  factory SocialAuthData.fromJson(Map<String, dynamic> json) => _$SocialAuthDataFromJson(json);

  Map<String, dynamic> toJson() => _$SocialAuthDataToJson(this);
}

class SocialAuthMutationParams {
  final SocialAuthProvider provider;
  final SocialAuthData data;

  SocialAuthMutationParams(this.provider, this.data);
}

final useSocialAuth = Mutation<ApiResponse, SocialAuthMutationParams>(
  mutationFn: (params) => ApiService.makeRequest(
    path: '/auth/${params.provider.name}',
    type: RequestType.post,
    data: params.data.toJson(),
  ),
);
