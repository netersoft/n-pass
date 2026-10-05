import 'package:flutter/material.dart';

import '../../../core/services/clipboard/service.dart';
import '../../../core/services/di/locator.dart';
import '../../../core/services/i18n/translations.g.dart';

/// Copies [value] and tells the user, mentioning the auto-clear for secrets.
Future<void> copyWithFeedback(BuildContext context, {required String field, required String value, bool sensitive = false}) async {
  final messenger = ScaffoldMessenger.of(context);
  await locator<ClipboardService>().copy(value, sensitive: sensitive);
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(
          sensitive ? t.copiedSecret(field: field, seconds: ClipboardService.clearAfter.inSeconds) : t.copied(field: field),
        ),
      ),
    );
}
