import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_starter/core/services/crash_reporting/service.dart';
import 'package:flutter_starter/firebase_options.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('isConfigured is false with the shipped placeholder options', () {
    // Locks in the safe-by-default behavior: a starter clone with no real
    // Firebase project must not try to report crashes to a project that
    // doesn't exist.
    expect(CrashReportingService.isConfigured, isFalse);
  });

  test('init() is a no-op and does not initialize Firebase when unconfigured', () async {
    await CrashReportingService.init();

    expect(Firebase.apps, isEmpty);
  });

  test('placeholder options are shared across the platforms the starter ships', () {
    expect(DefaultFirebaseOptions.android.apiKey, DefaultFirebaseOptions.placeholderApiKey);
    expect(DefaultFirebaseOptions.ios.apiKey, DefaultFirebaseOptions.placeholderApiKey);
    expect(DefaultFirebaseOptions.web.apiKey, DefaultFirebaseOptions.placeholderApiKey);
  });
}
