import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../themes/app_theme.dart';

class CustomLoadingIcon extends ConsumerWidget {
  final bool isLoading;
  final double size;
  final double strokeWidth;
  final IconData icon;
  final Color? iconColor;
  final Color? loaderColor;

  const CustomLoadingIcon({
    required this.isLoading,
    required this.icon,
    super.key,
    this.size = 20.0,
    this.strokeWidth = 2.0,
    this.iconColor,
    this.loaderColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) => isLoading
      ? SizedBox(
          height: size,
          width: size,
          child: CircularProgressIndicator(
            strokeWidth: strokeWidth,
            color: loaderColor ?? AppTheme.getIconColor(),
          ),
        )
      : Icon(
          icon,
          color: iconColor ?? AppTheme.getIconColor(),
          size: size,
        );
}
