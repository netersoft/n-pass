import 'package:json_annotation/json_annotation.dart';

@JsonEnum(valueField: 'brightness')
enum AppBrightness {
  light(1),
  dark(2),
  system(3);

  const AppBrightness(this.brightness);
  final int brightness;
}
