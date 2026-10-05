import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every app language has a privacy policy', () {
    final locales = Directory('assets/i18n').listSync().map((f) => f.uri.pathSegments.last.split('.').first).toList();

    expect(locales, isNotEmpty);
    for (final locale in locales) {
      final policy = File('assets/docs/$locale/privacy_policy.html');
      expect(policy.existsSync(), isTrue, reason: locale);
      expect(policy.readAsStringSync(), contains('<h1>'), reason: locale);
    }
  });
}
