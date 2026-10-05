import 'package:cached_query_flutter/cached_query_flutter.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../services/api/response.dart';
import '../../../services/api/service.dart';

part 'update_profile.g.dart';

@JsonSerializable()
class UpdateProfileData {
  String? name;
  String? email;

  UpdateProfileData({this.name, this.email});

  factory UpdateProfileData.fromJson(Map<String, dynamic> json) => _$UpdateProfileDataFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateProfileDataToJson(this);
}

final useUpdateProfile = Mutation<ApiResponse, UpdateProfileData>(
  mutationFn: (data) => ApiService.makeRequest(
    path: '/profile',
    type: RequestType.patch,
    data: data.toJson(),
  ),
);
