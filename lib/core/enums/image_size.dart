import 'package:json_annotation/json_annotation.dart';

@JsonEnum(valueField: 'size')
enum ImageSize {
  small('small'),
  medium('medium'),
  large('large'),
  original('original');

  const ImageSize(this.size);
  final String size;
}
