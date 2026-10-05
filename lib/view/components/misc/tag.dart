import 'package:flutter/material.dart';

import '../../themes/app_theme.dart';

class Tag extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final Color? textColor;
  final TagSize size;
  final TagType type;

  const Tag({
    required this.label,
    super.key,
    this.backgroundColor,
    this.textColor,
    this.size = TagSize.medium,
    this.type = TagType.none,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: _getPadding(),
    decoration: BoxDecoration(
      color: _getBackgroundColor(),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Text(
      label,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: _getFontSize(),
        color: _getTextColor(),
      ),
    ),
  );

  // Get padding based on tag size
  EdgeInsets _getPadding() {
    switch (size) {
      case TagSize.small:
        return const EdgeInsets.symmetric(horizontal: 8, vertical: 4);
      case TagSize.medium:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
      case TagSize.large:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
    }
  }

  // Get background color based on tag type
  Color _getBackgroundColor() {
    if (backgroundColor != null) {
      return backgroundColor!;
    }
    switch (type) {
      case TagType.primary:
        return AppTheme.primaryColor;
      case TagType.secondary:
        return AppTheme.secondaryColor;
      case TagType.info:
        return Colors.blue;
      case TagType.success:
        return Colors.green;
      case TagType.warning:
        return Colors.orange;
      case TagType.error:
        return Colors.red;
      case TagType.none:
        return Colors.grey;
    }
  }

  // Get text color based on tag type
  Color _getTextColor() {
    if (textColor != null) {
      return textColor!;
    }
    switch (type) {
      case TagType.primary:
        return Colors.white;
      case TagType.secondary:
        return Colors.white;
      case TagType.info:
        return Colors.white;
      case TagType.success:
        return Colors.white;
      case TagType.warning:
        return Colors.white;
      case TagType.error:
        return Colors.white;
      case TagType.none:
        return Colors.black;
    }
  }

  // Get font size based on tag size
  double _getFontSize() {
    switch (size) {
      case TagSize.small:
        return 12.0;
      case TagSize.medium:
        return 14.0;
      case TagSize.large:
        return 16.0;
    }
  }
}

enum TagSize {
  small,
  medium,
  large,
}

enum TagType {
  none,
  primary,
  secondary,
  info,
  success,
  warning,
  error,
}
