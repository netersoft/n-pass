import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:n_pass/core/tools/functions/password_generator.dart';

void main() {
  group('generatePassword', () {
    test('has the requested length and one char of every enabled charset', () {
      const options = PasswordGeneratorOptions(length: 8);
      for (var i = 0; i < 200; i++) {
        final password = generatePassword(options);

        expect(password, hasLength(8));
        for (final charset in options.charsets) {
          expect(password.split('').any(charset.contains), isTrue, reason: '$password lacks $charset');
        }
      }
    });

    test('only uses enabled charsets', () {
      final password = generatePassword(const PasswordGeneratorOptions(length: 64, uppercase: false, symbols: false));

      expect(RegExp(r'^[a-z0-9]+$').hasMatch(password), isTrue);
    });

    test('can exclude ambiguous characters', () {
      final password = generatePassword(const PasswordGeneratorOptions(length: 128, excludeAmbiguous: true));

      expect(password.split('').any(PasswordGeneratorOptions.ambiguousChars.contains), isFalse);
    });

    test('is reproducible with a seeded random', () {
      const options = PasswordGeneratorOptions();

      expect(generatePassword(options, random: Random(1)), generatePassword(options, random: Random(1)));
    });

    test('rejects invalid options', () {
      expect(
        () => generatePassword(const PasswordGeneratorOptions(uppercase: false, lowercase: false, digits: false, symbols: false)),
        throwsArgumentError,
      );
      expect(() => generatePassword(const PasswordGeneratorOptions(length: 3)), throwsArgumentError);
      expect(() => generatePassword(const PasswordGeneratorOptions(length: 129)), throwsArgumentError);
    });
  });

  test('generatedPasswordEntropy is length times log2 of the pool', () {
    expect(generatedPasswordEntropy(const PasswordGeneratorOptions(length: 10, uppercase: false, symbols: false)), closeTo(10 * 5.17, 0.01));
  });
}
