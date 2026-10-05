import 'dart:math';

class PasswordGeneratorOptions {
  static const int minLength = 4;
  static const int maxLength = 128;

  static const String uppercaseChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const String lowercaseChars = 'abcdefghijklmnopqrstuvwxyz';
  static const String digitChars = '0123456789';
  static const String symbolChars = r'!#$%&*+-=?@^_~.,:;/';
  static const String ambiguousChars = 'Il1O0o';

  final int length;
  final bool uppercase;
  final bool lowercase;
  final bool digits;
  final bool symbols;
  final bool excludeAmbiguous;

  const PasswordGeneratorOptions({
    this.length = 20,
    this.uppercase = true,
    this.lowercase = true,
    this.digits = true,
    this.symbols = true,
    this.excludeAmbiguous = false,
  });

  factory PasswordGeneratorOptions.fromJson(Map<String, dynamic> json) => PasswordGeneratorOptions(
    length: (json['length'] as int? ?? 20).clamp(minLength, maxLength),
    uppercase: json['uppercase'] as bool? ?? true,
    lowercase: json['lowercase'] as bool? ?? true,
    digits: json['digits'] as bool? ?? true,
    symbols: json['symbols'] as bool? ?? true,
    excludeAmbiguous: json['excludeAmbiguous'] as bool? ?? false,
  );

  Map<String, dynamic> toJson() => {
    'length': length,
    'uppercase': uppercase,
    'lowercase': lowercase,
    'digits': digits,
    'symbols': symbols,
    'excludeAmbiguous': excludeAmbiguous,
  };

  PasswordGeneratorOptions copyWith({int? length, bool? uppercase, bool? lowercase, bool? digits, bool? symbols, bool? excludeAmbiguous}) =>
      PasswordGeneratorOptions(
        length: length ?? this.length,
        uppercase: uppercase ?? this.uppercase,
        lowercase: lowercase ?? this.lowercase,
        digits: digits ?? this.digits,
        symbols: symbols ?? this.symbols,
        excludeAmbiguous: excludeAmbiguous ?? this.excludeAmbiguous,
      );

  List<String> get charsets => [
    if (uppercase) uppercaseChars,
    if (lowercase) lowercaseChars,
    if (digits) digitChars,
    if (symbols) symbolChars,
  ].map(_filter).toList();

  String _filter(String chars) => excludeAmbiguous ? chars.split('').where((c) => !ambiguousChars.contains(c)).join() : chars;
}

/// Generates a random password containing at least one character of every
/// enabled charset.
///
/// Throws [ArgumentError] when no charset is enabled or [PasswordGeneratorOptions.length]
/// is out of range.
String generatePassword(PasswordGeneratorOptions options, {Random? random}) {
  final rnd = random ?? Random.secure();
  final charsets = options.charsets;

  if (charsets.isEmpty) throw ArgumentError('At least one charset must be enabled');
  if (options.length < max(PasswordGeneratorOptions.minLength, charsets.length) || options.length > PasswordGeneratorOptions.maxLength) {
    throw ArgumentError.value(options.length, 'length');
  }

  final all = charsets.join();
  final chars = [
    for (final charset in charsets) charset[rnd.nextInt(charset.length)],
    for (var i = charsets.length; i < options.length; i++) all[rnd.nextInt(all.length)],
  ]..shuffle(rnd);

  return chars.join();
}

/// Entropy of a password generated with [options] (slightly overestimated:
/// ignores the one-character-per-charset guarantee).
double generatedPasswordEntropy(PasswordGeneratorOptions options) => options.length * log(options.charsets.join().length) / ln2;
