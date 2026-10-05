import 'dart:math';

import 'package:flutter/foundation.dart';

/// Generates a random alphanumeric sequence
String genRandomAlphaNumeric(
  int length, {
  bool secure = false,
  bool includeNumbers = true,
  bool includeLowercaseLetters = true,
  bool includeUppercaseLetters = true,
}) {
  String chars = '';
  if (includeUppercaseLetters) chars += 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  if (includeLowercaseLetters) chars += 'abcdefghijklmnopqrstuvwxyz';
  if (includeNumbers) chars += '1234567890';

  chars = (chars.split('')..shuffle()).join();

  Random rnd = secure ? Random.secure() : Random();

  return String.fromCharCodes(
    Iterable.generate(
      length,
      (_) => chars.codeUnitAt(rnd.nextInt(chars.length)),
    ),
  );
}

/// Generate a random string to use as the key
ValueKey<String> generateRandomKey() {
  final randomString = Random().nextInt(10000).toString();

  return ValueKey<String>(randomString);
}
