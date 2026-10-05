import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../themes/app_theme.dart';

class ShimmerContainer extends StatelessWidget {
  final Widget? child;

  const ShimmerContainer({required this.child, super.key});

  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
    baseColor: AppTheme.pickColor(
      light: Colors.grey[300]!,
      dark: Colors.grey[700]!,
    ),
    highlightColor: AppTheme.pickColor(
      light: Colors.grey[100]!,
      dark: Colors.grey[600]!,
    ),
    child: SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: child,
    ),
  );
}

class SimpleParagraphShimmer extends StatelessWidget {
  final int? lines;

  const SimpleParagraphShimmer({super.key, this.lines = 5});

  @override
  Widget build(BuildContext context) => ShimmerContainer(
    child: ListView(
      children: List.generate(
        lines!,
        (_) => Container(
          color: Colors.white,
          height: 10.0,
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
        ),
      ),
    ),
  );
}

class LongTextShimmer extends StatelessWidget {
  final int? lines;
  final int? paragraphs;

  const LongTextShimmer({super.key, this.lines = 5, this.paragraphs = 5});

  @override
  Widget build(BuildContext context) => ShimmerContainer(
    child: ListView(
      children: List.generate(
        paragraphs!,
        (index) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: Colors.white,
              height: 20.0,
              width: MediaQuery.of(context).size.width * 0.7,
              margin: const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 15,
              ),
            ),
            ...List.generate(
              lines!,
              (_) => Container(
                color: Colors.white,
                height: 10.0,
                width: double.infinity,
                margin: const EdgeInsets.symmetric(
                  vertical: 5,
                  horizontal: 15,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    ),
  );
}
