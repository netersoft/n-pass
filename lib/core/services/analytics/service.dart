import 'package:firebase_analytics/firebase_analytics.dart';

import '../firebase/service.dart';

/// Thin wrapper around FirebaseAnalytics -- every method is a silent no-op
/// when firebase_options.dart is still a placeholder, so call sites don't
/// need to check FirebaseSetup.isConfigured themselves.
abstract class AnalyticsService {
  static FirebaseAnalytics? get _instance => FirebaseSetup.isConfigured ? FirebaseAnalytics.instance : null;

  static Future<void> logEvent(String name, {Map<String, Object>? parameters}) async {
    await _instance?.logEvent(name: name, parameters: parameters);
  }

  static Future<void> logScreenView(String screenName) async {
    await _instance?.logScreenView(screenName: screenName);
  }

  static Future<void> setUserId(String? id) async {
    await _instance?.setUserId(id: id);
  }

  static Future<void> setUserProperty({required String name, String? value}) async {
    await _instance?.setUserProperty(name: name, value: value);
  }
}
