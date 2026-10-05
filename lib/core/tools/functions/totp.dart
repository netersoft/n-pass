import 'dart:typed_data';

import 'package:crypto/crypto.dart';

import '../../models/totp_config.dart';

const _base32Alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';

/// Uppercases and strips spaces, dashes and padding from a typed secret.
String normalizeBase32(String input) => input.toUpperCase().replaceAll(RegExp(r'[\s\-=]'), '');

/// Decodes RFC 4648 base32. Returns null when [input] is empty or contains
/// characters outside the alphabet.
Uint8List? decodeBase32(String input) {
  final clean = normalizeBase32(input);
  if (clean.isEmpty) return null;

  final bytes = <int>[];
  var buffer = 0;
  var bits = 0;
  for (final char in clean.split('')) {
    final value = _base32Alphabet.indexOf(char);
    if (value < 0) return null;
    buffer = (buffer << 5) | value;
    bits += 5;
    if (bits >= 8) {
      bits -= 8;
      bytes.add((buffer >> bits) & 0xff);
    }
  }
  return Uint8List.fromList(bytes);
}

/// The code valid at [time] (RFC 6238, dynamic truncation of RFC 4226).
String generateTotp(TotpConfig config, DateTime time) {
  final key = decodeBase32(config.secret);
  if (key == null) throw ArgumentError.value(config.secret, 'secret', 'Not base32');

  final counter = time.millisecondsSinceEpoch ~/ 1000 ~/ config.period;
  final message = ByteData(8)..setUint64(0, counter);
  final hash = switch (config.algorithm) {
    TotpAlgorithm.sha1 => sha1,
    TotpAlgorithm.sha256 => sha256,
    TotpAlgorithm.sha512 => sha512,
  };
  final digest = Hmac(hash, key).convert(message.buffer.asUint8List()).bytes;

  final offset = digest.last & 0x0f;
  final binary = ((digest[offset] & 0x7f) << 24) | ((digest[offset + 1] & 0xff) << 16) | ((digest[offset + 2] & 0xff) << 8) | (digest[offset + 3] & 0xff);
  var modulo = 1;
  for (var i = 0; i < config.digits; i++) {
    modulo *= 10;
  }
  return (binary % modulo).toString().padLeft(config.digits, '0');
}

/// Seconds left before the code changes.
int totpSecondsRemaining(TotpConfig config, DateTime time) => config.period - (time.millisecondsSinceEpoch ~/ 1000) % config.period;

/// Groups a code for reading: "123 456", "1234 5678".
String formatTotp(String code) {
  final half = (code.length + 1) ~/ 2;
  return '${code.substring(0, half)} ${code.substring(half)}';
}

/// Shortest accepted secret: 80 bits (16 base32 characters), the minimum
/// used by common services; RFC 4226 recommends 160.
const int minTotpSecretBytes = 10;

bool _isUsableSecret(String secret) => (decodeBase32(secret)?.length ?? 0) >= minTotpSecretBytes;

/// Reads what a user pastes in the 2FA field: an `otpauth://totp/...` link
/// (from a QR code) or a bare base32 secret. Returns null when it is neither,
/// or when its parameters are unsupported (HOTP, unknown algorithm...).
TotpConfig? parseTotpInput(String input) {
  final text = input.trim();
  if (text.isEmpty) return null;

  if (!text.toLowerCase().startsWith('otpauth://')) {
    final secret = normalizeBase32(text);
    return _isUsableSecret(secret) ? TotpConfig(secret: secret) : null;
  }

  final uri = Uri.tryParse(text);
  if (uri == null || uri.host.toLowerCase() != 'totp') return null;
  final params = {for (final e in uri.queryParameters.entries) e.key.toLowerCase(): e.value};

  final secret = normalizeBase32(params['secret'] ?? '');
  if (!_isUsableSecret(secret)) return null;

  final algorithm = switch ((params['algorithm'] ?? 'SHA1').toUpperCase()) {
    'SHA1' => TotpAlgorithm.sha1,
    'SHA256' => TotpAlgorithm.sha256,
    'SHA512' => TotpAlgorithm.sha512,
    _ => null,
  };
  final digits = int.tryParse(params['digits'] ?? '6');
  final period = int.tryParse(params['period'] ?? '30');
  if (algorithm == null || digits == null || !TotpConfig.supportedDigits.contains(digits) || period == null || period <= 0) return null;

  return TotpConfig(secret: secret, algorithm: algorithm, digits: digits, period: period);
}
