import 'package:flutter/material.dart';

import '../../themes/app_theme.dart';

class CustomText extends StatelessWidget {
  final String text;
  final Color? textColor;
  final TextStyle? textStyle;
  final double? fontSize;
  final EdgeInsets padding;
  final FontWeight? fontWeight;
  final int? maxLine;
  final TextOverflow overflow;
  final TextAlign? textAlign;
  final Color? backColor;

  const CustomText({
    required this.text,
    super.key,
    this.textColor,
    this.textStyle,
    this.padding = EdgeInsets.zero,
    this.fontSize,
    this.fontWeight,
    this.maxLine = 3,
    this.overflow = TextOverflow.ellipsis,
    this.textAlign = TextAlign.start,
    this.backColor = Colors.transparent,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: padding,
    child: Text(
      text,
      maxLines: maxLine,
      overflow: overflow,
      textAlign: textAlign,
      style:
          textStyle ??
          TextStyle(
            fontSize: fontSize ?? 16,
            fontWeight: fontWeight ?? FontWeight.normal,
            color: textColor ?? AppTheme.getTextColor(),
            backgroundColor: backColor,
          ),
    ),
  );
}
