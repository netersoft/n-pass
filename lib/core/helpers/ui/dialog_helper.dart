import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../view/themes/app_theme.dart';
import '../../services/di/locator.dart';
import '../../services/i18n/translations.g.dart';
import '../router/navigation_helper.dart';

abstract class DialogHelper {
  static void open({
    Widget? title,
    Widget? content,
    List<Widget>? actions,
    bool isDismissible = false,
  }) {
    showDialog(
      barrierDismissible: isDismissible,
      context: locator<NavigationHelper>().navigatorKey.currentContext!,
      builder: (BuildContext context) => AlertDialog(
        title: title ?? const SizedBox.shrink(),
        content: content ?? const SizedBox.shrink(),
        actions: actions ?? <Widget>[],
      ),
    );
  }

  static void showInfo(
    BuildContext context, {
    String title = '',
    String content = '',
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
        ),
        content: Text(content),
        actions: <Widget>[
          TextButton(
            child: Text(
              context.t.ok,
              style: TextStyle(color: AppTheme.primaryColor, fontSize: 16.0),
            ),
            onPressed: () {
              context.pop();
            },
          ),
        ],
      ),
    );
  }

  static void showContent(
    BuildContext context, {
    Widget? title,
    Widget? content,
    List<Widget>? actions,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: title ?? const SizedBox.shrink(),
        content: content ?? const SizedBox.shrink(),
        actions:
            actions ??
            <Widget>[
              TextButton(
                child: Text(
                  context.t.ok,
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 16.0,
                  ),
                ),
                onPressed: () {
                  context.pop();
                },
              ),
            ],
      ),
    );
  }

  static void showConnectionError(
    BuildContext context,
  ) {
    showInfo(
      context,
      title: context.t.connectionErrorTitle,
      content: context.t.connectionErrorContent,
    );
  }
}
