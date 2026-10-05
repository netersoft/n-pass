import 'package:flutter/material.dart';

import '../../../core/services/i18n/translations.g.dart';
import '../../../core/tools/functions/password_strength.dart';

extension PasswordStrengthUi on PasswordStrength {
  Color get color => switch (this) {
    PasswordStrength.veryWeak => Colors.red.shade700,
    PasswordStrength.weak => Colors.orange.shade700,
    PasswordStrength.fair => Colors.amber.shade700,
    PasswordStrength.good => Colors.lightGreen.shade700,
    PasswordStrength.strong => Colors.green.shade700,
  };

  String label(BuildContext context) => switch (this) {
    PasswordStrength.veryWeak => context.t.strengthVeryWeak,
    PasswordStrength.weak => context.t.strengthWeak,
    PasswordStrength.fair => context.t.strengthFair,
    PasswordStrength.good => context.t.strengthGood,
    PasswordStrength.strong => context.t.strengthStrong,
  };
}

class StrengthMeter extends StatelessWidget {
  final PasswordStrength strength;

  const StrengthMeter({required this.strength, super.key});

  @override
  Widget build(BuildContext context) {
    final steps = PasswordStrength.values.length;
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: TweenAnimationBuilder<double>(
              tween: Tween(end: (strength.index + 1) / steps),
              duration: const Duration(milliseconds: 250),
              builder: (context, value, _) => LinearProgressIndicator(
                value: value,
                minHeight: 6,
                color: strength.color,
                backgroundColor: Colors.grey.withValues(alpha: 0.25),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 80,
          child: Text(
            strength.label(context),
            textAlign: TextAlign.end,
            style: TextStyle(color: strength.color, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
