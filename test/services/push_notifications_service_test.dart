import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_starter/core/services/push_notifications/service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('isConfigured is false with the shipped placeholder options', () {
    // Same safe-by-default contract as CrashReportingService/AnalyticsService:
    // a starter clone with no real Firebase project must not touch FCM.
    expect(PushNotificationsService.isConfigured, isFalse);
  });

  test('init() is a no-op and does not initialize Firebase when unconfigured', () async {
    await PushNotificationsService.init();

    expect(Firebase.apps, isEmpty);
  });

  test('getToken() returns null when unconfigured', () async {
    expect(await PushNotificationsService.getToken(), isNull);
  });
}
