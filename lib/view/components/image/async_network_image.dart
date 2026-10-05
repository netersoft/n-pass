import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/network_image/async_network_image_param.dart';
import '../../../core/providers/network_image/async_network_image_provider.dart';
import '../loaders/shimmers.dart';

class AsyncNetworkImage extends ConsumerWidget {
  final AsyncNetworkImageParam param;

  const AsyncNetworkImage({required this.param, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageUrlAsync = ref.watch(asyncNetworkImageProvider(param));

    return imageUrlAsync.when(
      loading: () =>
          param.loader ??
          ShimmerContainer(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
      error: (error, stack) => Text('Error: $error'),
      data: (url) => Container(
        width: param.width,
        height: param.height,
        decoration: param.style,
        clipBehavior: param.clipBehavior,
        child: CachedNetworkImage(
          key: param.cacheKey,
          imageUrl: url,
          fit: param.fit,
          placeholder: (context, url) =>
              param.loader ??
              ShimmerContainer(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
          errorWidget: (context, url, error) => Center(
            child: param.alt != null && param.alt!.isNotEmpty
                ? Text(
                    param.alt!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  )
                : param.altWidget ?? const Icon(Icons.error, color: Colors.red),
          ),
          fadeInDuration: const Duration(milliseconds: 300),
        ),
      ),
    );
  }
}
