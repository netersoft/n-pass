import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_starter/core/services/analytics/service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every method is a silent no-op when Firebase is unconfigured', () async {
    // The starter ships with placeholder firebase_options.dart, so none of
    // these should touch FirebaseAnalytics.instance (which would throw
    // without an initialized Firebase app) or throw themselves.
    await AnalyticsService.logEvent('test_event', parameters: {'k': 'v'});
    await AnalyticsService.logScreenView('TestScreen');
    await AnalyticsService.setUserId('user-1');
    await AnalyticsService.setUserProperty(name: 'plan', value: 'free');

    expect(Firebase.apps, isEmpty);
  });
}
