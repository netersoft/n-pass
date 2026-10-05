import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/vault/generator_provider.dart';
import '../../../core/services/i18n/translations.g.dart';
import '../../../core/tools/functions/password_generator.dart';
import '../../../core/tools/functions/password_strength.dart';
import '../../themes/app_theme.dart';
import 'strength_meter.dart';

/// Bottom sheet that generates passwords. Resolves to the chosen password, or
/// null when dismissed.
Future<String?> showGeneratorSheet(BuildContext context) => showModalBottomSheet<String>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (context) => const _GeneratorSheet(),
);

class _GeneratorSheet extends ConsumerStatefulWidget {
  const _GeneratorSheet();

  @override
  ConsumerState<_GeneratorSheet> createState() => _GeneratorSheetState();
}

class _GeneratorSheetState extends ConsumerState<_GeneratorSheet> {
  late String _password = generatePassword(ref.read(generatorOptionsProvider));

  void _update(PasswordGeneratorOptions options) {
    ref.read(generatorOptionsProvider.notifier).update(options);
    setState(() => _password = generatePassword(ref.read(generatorOptionsProvider)));
  }

  @override
  Widget build(BuildContext context) {
    final options = ref.watch(generatorOptionsProvider);
    // Disable the last enabled charset so at least one stays on.
    final lastCharset = options.charsets.length == 1;

    Widget charsetSwitch(String label, bool value, PasswordGeneratorOptions Function(bool) toggle) => SwitchListTile(
      dense: true,
      title: Text(label),
      value: value,
      onChanged: value && lastCharset ? null : (v) => _update(toggle(v)),
    );

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(context.t.generatePassword, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                _password,
                textAlign: TextAlign.center,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 20, letterSpacing: 1),
              ),
            ),
            const SizedBox(height: 10),
            StrengthMeter(strength: estimatePasswordStrength(_password)),
            const SizedBox(height: 8),
            Text(context.t.passwordLength(length: options.length)),
            Slider(
              value: options.length.clamp(8, 64).toDouble(),
              min: 8,
              max: 64,
              divisions: 56,
              label: '${options.length}',
              inactiveColor: Colors.grey.withValues(alpha: 0.3),
              onChanged: (v) => _update(options.copyWith(length: v.round())),
            ),
            charsetSwitch(context.t.uppercaseLetters, options.uppercase, (v) => options.copyWith(uppercase: v)),
            charsetSwitch(context.t.lowercaseLetters, options.lowercase, (v) => options.copyWith(lowercase: v)),
            charsetSwitch(context.t.digits, options.digits, (v) => options.copyWith(digits: v)),
            charsetSwitch(context.t.symbols, options.symbols, (v) => options.copyWith(symbols: v)),
            SwitchListTile(
              dense: true,
              title: Text(context.t.excludeAmbiguous),
              value: options.excludeAmbiguous,
              onChanged: (v) => _update(options.copyWith(excludeAmbiguous: v)),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                    onPressed: () => setState(() => _password = generatePassword(options)),
                    icon: const Icon(Icons.refresh),
                    label: Text(context.t.regenerate),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(48),
                    ),
                    onPressed: () => context.pop(_password),
                    child: Text(context.t.useThisPassword, textAlign: TextAlign.center),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
