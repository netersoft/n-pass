import 'dart:math';

enum PasswordStrength { veryWeak, weak, fair, good, strong }

const _commonPasswords = {
  'password',
  'motdepasse',
  'azerty',
  'qwerty',
  'letmein',
  'welcome',
  'iloveyou',
  'admin',
  'dragon',
  'monkey',
  'football',
  'soleil',
  'bonjour',
};

/// Rough entropy-based estimate. Repeated characters (`aaa`) add nothing,
/// simple sequences (`abc`, `321`) count for half, and passwords built around
/// a very common word or digits only are capped at weak.
PasswordStrength estimatePasswordStrength(String password) {
  if (password.isEmpty) return PasswordStrength.veryWeak;

  final bits = estimatePasswordEntropy(password);
  final lower = password.toLowerCase();
  final isCommon = _commonPasswords.any(lower.contains) || RegExp(r'^\d+$').hasMatch(password);

  final strength = switch (bits) {
    < 28 => PasswordStrength.veryWeak,
    < 36 => PasswordStrength.weak,
    < 60 => PasswordStrength.fair,
    < 80 => PasswordStrength.good,
    _ => PasswordStrength.strong,
  };

  if (isCommon && strength.index > PasswordStrength.weak.index) return PasswordStrength.weak;
  return strength;
}

double estimatePasswordEntropy(String password) {
  var pool = 0;
  if (password.contains(RegExp('[a-z]'))) pool += 26;
  if (password.contains(RegExp('[A-Z]'))) pool += 26;
  if (password.contains(RegExp('[0-9]'))) pool += 10;
  if (password.contains(RegExp('[!-/:-@[-`{-~ ]'))) pool += 33;
  if (password.runes.any((r) => r > 127)) pool += 100;
  if (pool == 0) return 0;

  final runes = password.runes.toList();
  var effectiveLength = 0.0;
  for (var i = 0; i < runes.length; i++) {
    final step = i == 0 ? null : (runes[i] - runes[i - 1]).abs();
    effectiveLength += switch (step) {
      0 => 0,
      1 => 0.5,
      _ => 1,
    };
  }

  return effectiveLength * log(pool) / ln2;
}
