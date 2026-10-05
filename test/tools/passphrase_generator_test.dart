import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:n_pass/core/tools/functions/passphrase_generator.dart';

void main() {
  const wordlist = ['alpha', 'bravo', 'charlie', 'delta'];

  test('joins the requested number of words with the separator', () {
    final phrase = generatePassphrase(
      const PassphraseOptions(words: 6, separator: '.', capitalize: false, includeNumber: false),
      wordlist,
      random: Random(1),
    );

    final words = phrase.split('.');
    expect(words, hasLength(6));
    expect(words.every(wordlist.contains), isTrue);
  });

  test('capitalizes every word and appends exactly one digit', () {
    final phrase = generatePassphrase(const PassphraseOptions(words: 4), wordlist, random: Random(2));
    final words = phrase.split('-');

    expect(words.every((w) => w[0] == w[0].toUpperCase()), isTrue);
    expect(RegExp(r'\d').allMatches(phrase), hasLength(1));
    expect(words.where((w) => RegExp(r'\d$').hasMatch(w)), hasLength(1));
  });

  test('rejects an empty wordlist or an out-of-range word count', () {
    expect(() => generatePassphrase(const PassphraseOptions(), const []), throwsArgumentError);
    expect(() => generatePassphrase(const PassphraseOptions(words: 2), wordlist), throwsArgumentError);
  });

  test('entropy grows by about 12.9 bits per EFF word', () {
    const options = PassphraseOptions(includeNumber: false);

    expect(passphraseEntropy(options, 7776), closeTo(64.6, 0.1));
    expect(passphraseEntropy(options.copyWith(includeNumber: true), 7776), greaterThan(passphraseEntropy(options, 7776)));
  });

  test('options survive JSON and reject unknown separators', () {
    const options = PassphraseOptions(words: 7, separator: '_', capitalize: false, includeNumber: false);
    final decoded = PassphraseOptions.fromJson(options.toJson());

    expect(decoded.toJson(), options.toJson());
    expect(PassphraseOptions.fromJson({'separator': '#', 'words': 99}).toJson(), {
      'words': PassphraseOptions.maxWords,
      'separator': '-',
      'capitalize': true,
      'includeNumber': true,
    });
  });

  test('the bundled EFF wordlist has 7776 distinct lowercase words', () {
    final words = File('assets/wordlists/eff_large_wordlist.txt').readAsLinesSync().where((w) => w.isNotEmpty).toList();

    expect(words, hasLength(7776));
    expect(words.toSet(), hasLength(7776));
    expect(words.every((w) => RegExp(r'^[a-z-]+$').hasMatch(w)), isTrue);
  });
}
