import 'dart:math';

class PassphraseOptions {
  static const int minWords = 3;
  static const int maxWords = 10;
  static const List<String> separators = ['-', ' ', '.', '_'];

  final int words;
  final String separator;
  final bool capitalize;
  final bool includeNumber;

  const PassphraseOptions({this.words = 5, this.separator = '-', this.capitalize = true, this.includeNumber = true});

  factory PassphraseOptions.fromJson(Map<String, dynamic> json) {
    final separator = json['separator'] as String? ?? '-';
    return PassphraseOptions(
      words: (json['words'] as int? ?? 5).clamp(minWords, maxWords),
      separator: separators.contains(separator) ? separator : '-',
      capitalize: json['capitalize'] as bool? ?? true,
      includeNumber: json['includeNumber'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {'words': words, 'separator': separator, 'capitalize': capitalize, 'includeNumber': includeNumber};

  PassphraseOptions copyWith({int? words, String? separator, bool? capitalize, bool? includeNumber}) => PassphraseOptions(
    words: words ?? this.words,
    separator: separator ?? this.separator,
    capitalize: capitalize ?? this.capitalize,
    includeNumber: includeNumber ?? this.includeNumber,
  );
}

/// Picks [PassphraseOptions.words] random words from [wordlist] (the EFF
/// large wordlist: 7776 words, about 12.9 bits each). With
/// [PassphraseOptions.includeNumber], one random word gets a digit appended.
String generatePassphrase(PassphraseOptions options, List<String> wordlist, {Random? random}) {
  if (wordlist.isEmpty) throw ArgumentError('The wordlist is empty');
  if (options.words < PassphraseOptions.minWords || options.words > PassphraseOptions.maxWords) {
    throw ArgumentError.value(options.words, 'words');
  }

  final rnd = random ?? Random.secure();
  final words = [
    for (var i = 0; i < options.words; i++)
      switch (wordlist[rnd.nextInt(wordlist.length)]) {
        final word when options.capitalize => word[0].toUpperCase() + word.substring(1),
        final word => word,
      },
  ];
  if (options.includeNumber) {
    final index = rnd.nextInt(words.length);
    words[index] = '${words[index]}${rnd.nextInt(10)}';
  }
  return words.join(options.separator);
}

/// Entropy of a passphrase drawn with [options] from a list of [wordlistSize]
/// words. Capitalizing adds nothing (every word is capitalized).
double passphraseEntropy(PassphraseOptions options, int wordlistSize) {
  var bits = options.words * log(wordlistSize) / ln2;
  if (options.includeNumber) bits += log(options.words * 10) / ln2;
  return bits;
}
