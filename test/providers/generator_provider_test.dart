import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:n_pass/core/providers/vault/generator_provider.dart';
import 'package:n_pass/core/services/shared_preferences/keys.dart';
import 'package:n_pass/core/tools/functions/passphrase_generator.dart';
import 'package:n_pass/core/tools/functions/password_generator.dart';

import '../helpers/test_utils.dart';

void main() {
  late MockSharedPreferencesService prefs;

  setUp(() async {
    prefs = MockSharedPreferencesService();
    await setupTestLocator(sharedPreferencesService: prefs);
    when(() => prefs.setString(any(), any())).thenAnswer((_) async => true);
  });

  tearDown(teardownTestLocator);

  GeneratorSettings read(String? raw) {
    when(() => prefs.getString(PrefKeys.generatorOptions, defaultValue: any(named: 'defaultValue'))).thenReturn(raw);
    final c = ProviderContainer();
    addTearDown(c.dispose);
    return c.read(generatorOptionsProvider);
  }

  test('falls back to defaults on missing, malformed or older settings', () {
    for (final raw in [null, 'not json', jsonEncode(const PasswordGeneratorOptions(length: 30).toJson())]) {
      final settings = read(raw);
      expect(settings.mode, GeneratorMode.password, reason: raw);
      expect(settings.password.length, 20, reason: raw);
    }
  });

  test('restores the saved mode and options', () {
    const saved = GeneratorSettings(
      mode: GeneratorMode.passphrase,
      password: PasswordGeneratorOptions(length: 32),
      passphrase: PassphraseOptions(words: 7),
    );

    final settings = read(jsonEncode(saved.toJson()));

    expect(settings.toJson(), saved.toJson());
  });

  test('persists updates but refuses settings without any charset', () {
    when(() => prefs.getString(PrefKeys.generatorOptions, defaultValue: any(named: 'defaultValue'))).thenReturn(null);
    final c = ProviderContainer();
    addTearDown(c.dispose);
    c.read(generatorOptionsProvider.notifier).update(const GeneratorSettings(mode: GeneratorMode.passphrase));
    expect(c.read(generatorOptionsProvider).mode, GeneratorMode.passphrase);

    c
        .read(generatorOptionsProvider.notifier)
        .update(
          const GeneratorSettings(
            password: PasswordGeneratorOptions(uppercase: false, lowercase: false, digits: false, symbols: false),
          ),
        );
    expect(c.read(generatorOptionsProvider).mode, GeneratorMode.passphrase, reason: 'refused');
    verify(() => prefs.setString(PrefKeys.generatorOptions, any())).called(1);
  });
}
