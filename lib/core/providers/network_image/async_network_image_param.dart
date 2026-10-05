import 'package:flutter/material.dart';

class AsyncNetworkImageParam {
  final Future<String> Function() load;
  final Widget? loader;
  final Widget? altWidget;
  final String? alt;
  final double? width;
  final double? height;
  final String? title;
  final BoxDecoration? style;
  final Clip clipBehavior;
  final BoxFit fit;
  final Key? cacheKey;

  AsyncNetworkImageParam({
    required this.load,
    this.loader,
    this.altWidget,
    this.alt,
    this.width,
    this.height,
    this.title,
    this.style,
    this.clipBehavior = Clip.none,
    this.fit = BoxFit.cover,
    this.cacheKey,
  });
}
