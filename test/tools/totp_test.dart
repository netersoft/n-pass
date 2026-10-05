import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:n_pass/core/models/totp_config.dart';
import 'package:n_pass/core/models/vault_entry.dart';
import 'package:n_pass/core/tools/functions/totp.dart';

String base32(List<int> bytes) {
  const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
  final out = StringBuffer();
  var buffer = 0;
  var bits = 0;
  for (final byte in bytes) {
    buffer = (buffer << 8) | byte;
    bits += 8;
    while (bits >= 5) {
      bits -= 5;
      out.write(alphabet[(buffer >> bits) & 31]);
    }
  }
  if (bits > 0) out.write(alphabet[(buffer << (5 - bits)) & 31]);
  return out.toString();
}

DateTime at(int seconds) => DateTime.fromMillisecondsSinceEpoch(seconds * 1000, isUtc: true);

void main() {
  group('generateTotp matches the RFC 6238 test vectors', () {
    final secrets = {
      TotpAlgorithm.sha1: base32(ascii.encode('12345678901234567890')),
      TotpAlgorithm.sha256: base32(ascii.encode('12345678901234567890123456789012')),
      TotpAlgorithm.sha512: base32(ascii.encode('1234567890123456789012345678901234567890123456789012345678901234')),
    };
    const vectors = {
      59: ['94287082', '46119246', '90693936'],
      1111111109: ['07081804', '68084774', '25091201'],
      1111111111: ['14050471', '67062674', '99943326'],
      1234567890: ['89005924', '91819424', '93441116'],
      2000000000: ['69279037', '90698825', '38618901'],
      20000000000: ['65353130', '77737706', '47863826'],
    };

    for (final MapEntry(key: time, value: codes) in vectors.entries) {
      for (final algorithm in TotpAlgorithm.values) {
        test('$algorithm at $time', () {
          final config = TotpConfig(secret: secrets[algorithm]!, algorithm: algorithm, digits: 8);
          expect(generateTotp(config, at(time)), codes[algorithm.index]);
        });
      }
    }

    test('6 digits keeps the last six', () {
      expect(generateTotp(TotpConfig(secret: secrets[TotpAlgorithm.sha1]!), at(59)), '287082');
    });
  });

  test('decodeBase32 ignores case, spaces and padding, rejects other characters', () {
    expect(decodeBase32('mzxw 6ytb oi======'), ascii.encode('foobar'));
    expect(decodeBase32('MZXW6YTBOI'), ascii.encode('foobar'));
    expect(decodeBase32('MZXW1'), isNull, reason: '1 is not base32');
    expect(decodeBase32('  '), isNull);
  });

  test('seconds remaining and formatting', () {
    const config = TotpConfig(secret: 'MZXW6YTBOI');
    expect(totpSecondsRemaining(config, at(59)), 1);
    expect(totpSecondsRemaining(config, at(60)), 30);
    expect(formatTotp('123456'), '123 456');
    expect(formatTotp('12345678'), '1234 5678');
    expect(formatTotp('1234567'), '1234 567');
  });

  group('parseTotpInput', () {
    test('reads a bare secret with defaults', () {
      expect(parseTotpInput(' jbsw y3dp ehpk 3pxp '), const TotpConfig(secret: 'JBSWY3DPEHPK3PXP'));
    });

    test('reads an otpauth link with its parameters', () {
      final config = parseTotpInput('otpauth://totp/GitHub:jean%40example.com?secret=jbswy3dpehpk3pxp&issuer=GitHub&algorithm=SHA256&digits=8&period=60');

      expect(config, const TotpConfig(secret: 'JBSWY3DPEHPK3PXP', algorithm: TotpAlgorithm.sha256, digits: 8, period: 60));
    });

    test('rejects HOTP, unknown algorithms, odd digits, invalid or too short secrets', () {
      for (final input in [
        'otpauth://hotp/X?secret=JBSWY3DPEHPK3PXP&counter=1',
        'otpauth://totp/X?secret=JBSWY3DPEHPK3PXP&algorithm=MD5',
        'otpauth://totp/X?secret=JBSWY3DPEHPK3PXP&digits=4',
        'otpauth://totp/X?secret=not-base32!',
        'otpauth://totp/X',
        'otpauth://totp/X?secret=J',
        'JBSWY3DP',
        'hello world!',
        '',
      ]) {
        expect(parseTotpInput(input), isNull, reason: input);
      }
    });
  });

  test('entries without 2FA decode and keep no totp key', () {
    final entry = VaultEntry(id: 'a', title: 'A', createdAt: DateTime.utc(2026), updatedAt: DateTime.utc(2026));
    expect(entry.toJson().containsKey('totp'), isFalse);

    final withTotp = entry.copyWith(totp: const TotpConfig(secret: 'JBSWY3DPEHPK3PXP', digits: 8));
    final decoded = VaultEntry.fromJson(jsonDecode(jsonEncode(withTotp.toJson())) as Map<String, dynamic>);
    expect(decoded.totp, withTotp.totp);
    expect(decoded.copyWith(clearTotp: true).totp, isNull);
  });
}
