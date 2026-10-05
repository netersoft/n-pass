import 'package:flutter/material.dart';

import '../../themes/app_theme.dart';

class TileContainer extends StatelessWidget {
  final Widget child;

  const TileContainer({required this.child, super.key});

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: const BorderRadius.vertical(
      top: Radius.circular(12),
      bottom: Radius.circular(12),
    ),
    child: Container(
      color: AppTheme.pickColor(
        light: Colors.white,
        dark: const Color.fromARGB(255, 28, 28, 30),
      ),
      padding: const EdgeInsetsDirectional.symmetric(
        vertical: 21,
        horizontal: 16,
      ),
      child: child,
    ),
  );
}
