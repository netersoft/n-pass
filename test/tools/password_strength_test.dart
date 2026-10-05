import 'package:flutter_test/flutter_test.dart';
import 'package:n_pass/core/tools/functions/password_strength.dart';

void main() {
  group('estimatePasswordStrength', () {
    test('rates short, repetitive or common passwords as weak at best', () {
      expect(estimatePasswordStrength(''), PasswordStrength.veryWeak);
      expect(estimatePasswordStrength('abc'), PasswordStrength.veryWeak);
      expect(estimatePasswordStrength('aaaaaaaaaaaa'), PasswordStrength.veryWeak);
      expect(estimatePasswordStrength('12345678901234567890'), PasswordStrength.weak);
      expect(estimatePasswordStrength('Password2026!'), PasswordStrength.weak);
      expect(estimatePasswordStrength('azertyuiop123'), PasswordStrength.weak);
    });

    test('rewards length and character variety', () {
      expect(estimatePasswordStrength('kTq8vZ'), PasswordStrength.weak);
      expect(estimatePasswordStrength('kTq8vZ2m'), PasswordStrength.fair);
      expect(estimatePasswordStrength('kTq8vZ2m!rP4'), PasswordStrength.good);
      expect(estimatePasswordStrength('kTq8vZ2m!rP4#wX9'), PasswordStrength.strong);
      expect(estimatePasswordStrength('cheval agrafe batterie correcte'), PasswordStrength.strong);
    });

    test('counts sequences for half', () {
      expect(estimatePasswordEntropy('abcdef'), lessThan(estimatePasswordEntropy('aqzmxk')));
    });
  });
}
