import 'package:material_ui/material_ui.dart';

import '../../services/di/locator.dart';
import '../../services/i18n/translations.g.dart';
import '../router/navigation_helper.dart';

enum RateChoice { rate, later, never }

/// The dialog that sends the user to the store listing. Closing it without
/// choosing counts as "later".
Future<RateChoice?> showRateDialog() async {
  final context = locator<NavigationHelper>().navigatorKey.currentContext;
  if (context == null) return null;
  final choice = await showDialog<RateChoice>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(context.t.rateTitle),
      content: Text(context.t.rateMessage),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, RateChoice.never), child: Text(context.t.rateNever)),
        TextButton(onPressed: () => Navigator.pop(context, RateChoice.later), child: Text(context.t.rateLater)),
        FilledButton(onPressed: () => Navigator.pop(context, RateChoice.rate), child: Text(context.t.rateAction)),
      ],
    ),
  );
  return choice ?? RateChoice.later;
}
