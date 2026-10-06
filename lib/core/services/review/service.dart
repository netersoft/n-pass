import 'package:flutter/services.dart';

import '../../helpers/logging/log_helper.dart';
import '../di/locator.dart';
import '../shared_preferences/keys.dart';
import '../shared_preferences/service.dart';

/// Asks once for a store rating with the in-app review sheet, at a moment the
/// user gets value from the app: after they add their fifth account. The store decides whether the
/// sheet actually shows (it limits how often and never reports the outcome);
/// the Settings "Rate" item stays the explicit way to reach the listing.
///
/// The native side is a method channel in the app itself (MainActivity,
/// AppDelegate), not the in_app_review plugin, whose Android build file
/// doesn't build with AGP 9.
class ReviewService {
  static const channel = MethodChannel('com.neteru.n_pass/review');

  SharedPreferencesService get _prefs => locator<SharedPreferencesService>();

  Future<void> requestOnce() async {
    if (_prefs.getBool(PrefKeys.reviewRequested) ?? false) return;
    try {
      if (await channel.invokeMethod<bool>('requestReview') ?? false) {
        await _prefs.setBool(PrefKeys.reviewRequested, true);
      }
    } on Exception catch (e, stackTrace) {
      // PlatformException, or MissingPluginException on a platform without
      // the channel: never worth more than a log line.
      LogHelper.w('In-app review request failed', error: e, stackTrace: stackTrace);
    }
  }
}
