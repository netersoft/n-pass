import 'package:flutter/material.dart';

import '../../enums/image_size.dart';

class CustomNetworkImageParam {
  final String src;
  final Widget? loader;
  final Widget? altWidget;
  final String? alt;
  final double? width;
  final double? height;
  final String? title;
  final BoxDecoration? style;
  final Clip clipBehavior;
  final ImageSize size;
  final BoxFit fit;
  final bool sync;
  final Key? cacheKey;

  CustomNetworkImageParam({
    required this.src,
    this.loader,
    this.altWidget,
    this.alt,
    this.width,
    this.height,
    this.title,
    this.style,
    this.clipBehavior = Clip.none,
    this.size = ImageSize.original,
    this.fit = BoxFit.cover,
    this.sync = false,
    this.cacheKey,
  });
}
