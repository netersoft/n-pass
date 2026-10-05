import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/vault/generator_provider.dart';
import '../../../core/services/i18n/translations.g.dart';
import '../../../core/tools/functions/passphrase_generator.dart';
import '../../../core/tools/functions/password_generator.dart';
import '../../../core/tools/functions/password_strength.dart';
import '../../themes/app_theme.dart';
import 'strength_meter.dart';

/// Bottom sheet that generates passwords or passphrases. Resolves to the
/// chosen value, or null when dismissed.
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
  String _value = '';

  @override
  void initState() {
    super.initState();
    _value = _generate();
  }

  /// Empty while the wordlist is loading in passphrase mode.
  String _generate() {
    final settings = ref.read(generatorOptionsProvider);
    return switch (settings.mode) {
      GeneratorMode.password => generatePassword(settings.password),
      GeneratorMode.passphrase => switch (ref.read(passphraseWordlistProvider).value) {
        final words? => generatePassphrase(settings.passphrase, words),
        null => '',
      },
    };
  }

  void _update(GeneratorSettings settings) {
    ref.read(generatorOptionsProvider.notifier).update(settings);
    setState(() => _value = _generate());
  }

  PasswordStrength _strength(GeneratorSettings settings, List<String>? words) => strengthFromEntropy(switch (settings.mode) {
    GeneratorMode.password => generatedPasswordEntropy(settings.password),
    GeneratorMode.passphrase => passphraseEntropy(settings.passphrase, words?.length ?? 0),
  });

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(generatorOptionsProvider);
    final words = ref.watch(passphraseWordlistProvider).value;
    ref.listen(passphraseWordlistProvider, (_, next) {
      if (next.hasValue && _value.isEmpty) setState(() => _value = _generate());
    });

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(context.t.generatePassword, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            SegmentedButton<GeneratorMode>(
              style: SegmentedButton.styleFrom(selectedBackgroundColor: AppTheme.primaryColor, selectedForegroundColor: Colors.white),
              segments: [
                ButtonSegment(value: GeneratorMode.password, icon: const Icon(Icons.password), label: Text(context.t.password)),
                ButtonSegment(value: GeneratorMode.passphrase, icon: const Icon(Icons.short_text), label: Text(context.t.passphrase)),
              ],
              selected: {settings.mode},
              onSelectionChanged: (selection) => _update(settings.copyWith(mode: selection.single)),
            ),
            const SizedBox(height: 16),
            Container(
              constraints: const BoxConstraints(minHeight: 64),
              alignment: Alignment.center,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _value.isEmpty
                  ? const SizedBox.square(dimension: 24, child: CircularProgressIndicator(strokeWidth: 2))
                  : SelectableText(
                      _value,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 20, letterSpacing: 1),
                    ),
            ),
            const SizedBox(height: 10),
            StrengthMeter(strength: _strength(settings, words)),
            const SizedBox(height: 8),
            ...switch (settings.mode) {
              GeneratorMode.password => _passwordOptions(settings),
              GeneratorMode.passphrase => _passphraseOptions(settings),
            },
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                    onPressed: () => setState(() => _value = _generate()),
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
                    onPressed: _value.isEmpty ? null : () => context.pop(_value),
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

  List<Widget> _passwordOptions(GeneratorSettings settings) {
    final options = settings.password;
    // Disable the last enabled charset so at least one stays on.
    final lastCharset = options.charsets.length == 1;
    void update(PasswordGeneratorOptions options) => _update(settings.copyWith(password: options));

    Widget charsetSwitch(String label, bool value, PasswordGeneratorOptions Function(bool) toggle) => SwitchListTile(
      dense: true,
      title: Text(label),
      value: value,
      onChanged: value && lastCharset ? null : (v) => update(toggle(v)),
    );

    return [
      Text(context.t.passwordLength(length: options.length)),
      Slider(
        value: options.length.clamp(8, 64).toDouble(),
        min: 8,
        max: 64,
        divisions: 56,
        label: '${options.length}',
        inactiveColor: Colors.grey.withValues(alpha: 0.3),
        onChanged: (v) => update(options.copyWith(length: v.round())),
      ),
      charsetSwitch(context.t.uppercaseLetters, options.uppercase, (v) => options.copyWith(uppercase: v)),
      charsetSwitch(context.t.lowercaseLetters, options.lowercase, (v) => options.copyWith(lowercase: v)),
      charsetSwitch(context.t.digits, options.digits, (v) => options.copyWith(digits: v)),
      charsetSwitch(context.t.symbols, options.symbols, (v) => options.copyWith(symbols: v)),
      SwitchListTile(
        dense: true,
        title: Text(context.t.excludeAmbiguous),
        value: options.excludeAmbiguous,
        onChanged: (v) => update(options.copyWith(excludeAmbiguous: v)),
      ),
    ];
  }

  List<Widget> _passphraseOptions(GeneratorSettings settings) {
    final options = settings.passphrase;
    void update(PassphraseOptions options) => _update(settings.copyWith(passphrase: options));
    String separatorLabel(String separator) => separator == ' ' ? context.t.separatorSpace : separator;

    return [
      Text(context.t.passphraseWords(count: options.words)),
      Slider(
        value: options.words.toDouble(),
        min: PassphraseOptions.minWords.toDouble(),
        max: PassphraseOptions.maxWords.toDouble(),
        divisions: PassphraseOptions.maxWords - PassphraseOptions.minWords,
        label: '${options.words}',
        inactiveColor: Colors.grey.withValues(alpha: 0.3),
        onChanged: (v) => update(options.copyWith(words: v.round())),
      ),
      ListTile(
        dense: true,
        title: Text(context.t.separator),
        trailing: DropdownButton<String>(
          value: options.separator,
          underline: const SizedBox.shrink(),
          items: [
            for (final separator in PassphraseOptions.separators)
              DropdownMenuItem(
                value: separator,
                child: Text(separatorLabel(separator), style: const TextStyle(fontFamily: 'monospace')),
              ),
          ],
          onChanged: (v) => update(options.copyWith(separator: v)),
        ),
      ),
      SwitchListTile(
        dense: true,
        title: Text(context.t.capitalizeWords),
        value: options.capitalize,
        onChanged: (v) => update(options.copyWith(capitalize: v)),
      ),
      SwitchListTile(
        dense: true,
        title: Text(context.t.includeNumber),
        value: options.includeNumber,
        onChanged: (v) => update(options.copyWith(includeNumber: v)),
      ),
    ];
  }
}
