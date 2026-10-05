import 'package:flutter/material.dart';

import '../../themes/app_theme.dart';

class Status extends StatelessWidget {
  final String? title;
  final String? text;
  final IconData icon;
  final Widget? iconWidget;
  final Widget? footerWidget;

  const Status({
    super.key,
    this.icon = Icons.info,
    this.iconWidget,
    this.text,
    this.title,
    this.footerWidget,
  });

  @override
  Widget build(BuildContext context) => Container(
    alignment: Alignment.center,
    padding: const EdgeInsets.symmetric(horizontal: 25),
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          iconWidget ??
              Icon(
                icon,
                size: 100,
                color: AppTheme.pickColor(
                  light: AppTheme.secondaryColor,
                  dark: Colors.grey,
                ),
              ),
          const SizedBox(height: 15),
          if (title != null)
            Text(
              title ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppTheme.pickColor(
                  light: Colors.black54,
                  dark: Colors.white54,
                ),
              ),
            )
          else
            const SizedBox.shrink(),
          if (title != null) const SizedBox(height: 5) else const SizedBox.shrink(),
          if (text != null)
            Text(
              text ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.pickColor(
                  light: Colors.black54,
                  dark: Colors.white54,
                ),
              ),
            )
          else
            const SizedBox.shrink(),
          if (footerWidget != null) footerWidget! else const SizedBox.shrink(),
        ],
      ),
    ),
  );
}
