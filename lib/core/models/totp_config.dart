import 'package:json_annotation/json_annotation.dart';

part 'totp_config.g.dart';

enum TotpAlgorithm { sha1, sha256, sha512 }

/// Settings of a time-based one-time password (RFC 6238) generator.
@JsonSerializable()
class TotpConfig {
  static const List<int> supportedDigits = [6, 7, 8];
  static const List<int> supportedPeriods = [30, 60];

  /// Base32 secret, normalized: uppercase, no spaces or padding.
  final String secret;
  final TotpAlgorithm algorithm;
  final int digits;
  final int period;

  const TotpConfig({required this.secret, this.algorithm = TotpAlgorithm.sha1, this.digits = 6, this.period = 30});

  factory TotpConfig.fromJson(Map<String, dynamic> json) => _$TotpConfigFromJson(json);

  Map<String, dynamic> toJson() => _$TotpConfigToJson(this);

  TotpConfig copyWith({String? secret, TotpAlgorithm? algorithm, int? digits, int? period}) => TotpConfig(
    secret: secret ?? this.secret,
    algorithm: algorithm ?? this.algorithm,
    digits: digits ?? this.digits,
    period: period ?? this.period,
  );

  @override
  bool operator ==(Object other) =>
      other is TotpConfig && other.secret == secret && other.algorithm == algorithm && other.digits == digits && other.period == period;

  @override
  int get hashCode => Object.hash(secret, algorithm, digits, period);
}
