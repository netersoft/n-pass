import 'package:flutter/material.dart';

import '../../../core/services/i18n/translations.g.dart';

/// Warns that the password is also used by the entries named [titles].
class ReuseWarning extends StatelessWidget {
  final List<String> titles;
  final EdgeInsetsGeometry margin;

  const ReuseWarning({required this.titles, super.key, this.margin = const EdgeInsets.fromLTRB(16, 4, 16, 8)});

  @override
  Widget build(BuildContext context) => Container(
    margin: margin,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.orange.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.orange.withValues(alpha: 0.5)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.warning_amber_rounded, color: Colors.orange.shade800),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.t.passwordReused(titles: titles.join(', ')),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(context.t.passwordReusedHint, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ],
    ),
  );
}
