import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Generate a SHA256 hash of a string
Future<String> sha256ofString(String input) async {
  final bytes = utf8.encode(input);
  final digest = sha256.convert(bytes);
  return digest.toString();
}
