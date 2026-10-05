import 'package:cached_query_flutter/cached_query_flutter.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../services/api/response.dart';
import '../../../services/api/service.dart';

part 'two_factor_challenge.g.dart';

@JsonSerializable()
class TwoFactorChallengeData {
  String? ticket;
  String? code;

  @JsonKey(name: 'recovery_code')
  String? recoveryCode;

  @JsonKey(name: 'device_name')
  String? deviceName;

  TwoFactorChallengeData({
    this.ticket,
    this.code,
    this.recoveryCode,
    this.deviceName,
  });

  factory TwoFactorChallengeData.fromJson(Map<String, dynamic> json) => _$TwoFactorChallengeDataFromJson(json);

  Map<String, dynamic> toJson() => _$TwoFactorChallengeDataToJson(this);
}

final useTwoFactorChallenge = Mutation<ApiResponse, TwoFactorChallengeData>(
  mutationFn: (data) => ApiService.makeRequest(
    path: '/two-factor-challenge',
    type: RequestType.post,
    data: data.toJson(),
  ),
);
