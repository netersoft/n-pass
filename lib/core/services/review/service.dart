import 'dart:io';

import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../helpers/logging/log_helper.dart';
import '../../helpers/ui/rate_dialog.dart';
import '../di/locator.dart';
import '../shared_preferences/keys.dart';
import '../shared_preferences/service.dart';

/// Asks for a store rating at a moment the user gets value from the app: when
/// they add their fifth account, then each new one.
///
/// 1. The first time, the in-app review sheet, once in the app's life. The
///    store decides whether it actually shows (it limits how often and never
///    reports the outcome), and it only collects stars.
/// 2. On Android, later, our own dialog that opens the Play Store listing,
///    where a comment can be written: at most [maxDialogs] times, [dialogGap]
///    apart and [dialogDelay] after the sheet, until the user rates or asks
///    not to be asked again. iOS forbids custom rating prompts, so it keeps
///    the system sheet only.
///
/// The native side is a method channel in the app itself (MainActivity,
/// AppDelegate), not the in_app_review plugin, whose Android build file
/// doesn't build with AGP 9.
class ReviewService {
  static const channel = MethodChannel('com.neteru.n_pass/review');

  static const playStoreId = 'com.neteru.n_pass';
  static const maxDialogs = 3;
  static const dialogDelay = Duration(days: 14);
  static const dialogGap = Duration(days: 30);

  ReviewService({DateTime Function()? now, bool? isAndroid, Future<RateChoice?> Function()? ask, Future<void> Function()? openListing})
    : _now = now ?? DateTime.now,
      _isAndroid = isAndroid ?? Platform.isAndroid,
      _ask = ask ?? showRateDialog,
      _openListing = openListing ?? _openPlayStore;

  final DateTime Function() _now;
  final bool _isAndroid;
  final Future<RateChoice?> Function() _ask;
  final Future<void> Function() _openListing;

  SharedPreferencesService get _prefs => locator<SharedPreferencesService>();

  /// Called at a good moment; does nothing when it is not time to ask.
  Future<void> requestOnce() async {
    if (_prefs.getBool(PrefKeys.rateDone) ?? false) return;
    if (!(_prefs.getBool(PrefKeys.reviewRequested) ?? false)) return _requestSheet();
    if (_isAndroid) await _askWithDialog();
  }

  Future<void> _requestSheet() async {
    try {
      if (await channel.invokeMethod<bool>('requestReview') ?? false) {
        await _prefs.setBool(PrefKeys.reviewRequested, true);
        await _prefs.setInt(PrefKeys.reviewRequestedAt, _now().millisecondsSinceEpoch);
      }
    } on Exception catch (e, stackTrace) {
      // PlatformException, or MissingPluginException on a platform without
      // the channel: never worth more than a log line.
      LogHelper.w('In-app review request failed', error: e, stackTrace: stackTrace);
    }
  }

  Future<void> _askWithDialog() async {
    final now = _now();
    final sheetAt = _prefs.getInt(PrefKeys.reviewRequestedAt);
    if (sheetAt != null && now.difference(DateTime.fromMillisecondsSinceEpoch(sheetAt)) < dialogDelay) return;
    final count = _prefs.getInt(PrefKeys.rateDialogCount) ?? 0;
    if (count >= maxDialogs) return;
    final lastAt = _prefs.getInt(PrefKeys.rateDialogLastAt);
    if (lastAt != null && now.difference(DateTime.fromMillisecondsSinceEpoch(lastAt)) < dialogGap) return;

    // Counted before showing: an app closed with the dialog open still counts.
    await _prefs.setInt(PrefKeys.rateDialogCount, count + 1);
    await _prefs.setInt(PrefKeys.rateDialogLastAt, now.millisecondsSinceEpoch);
    final choice = await _ask();
    switch (choice) {
      case RateChoice.rate:
        await _prefs.setBool(PrefKeys.rateDone, true);
        await _openListing();
      case RateChoice.never:
        await _prefs.setBool(PrefKeys.rateDone, true);
      case RateChoice.later:
      case null:
        break;
    }
  }

  /// The Settings "Rate" item: straight to the listing.
  Future<void> openListing() => _openListing();

  /// The Play Store app if installed (launchUrl throws when nothing handles market://), the web page otherwise.
  static Future<void> _openPlayStore() async {
    try {
      if (await launchUrl(Uri.parse('market://details?id=$playStoreId'))) return;
    } on PlatformException catch (_) {}
    await launchUrl(Uri.parse('https://play.google.com/store/apps/details?id=$playStoreId'), mode: LaunchMode.externalApplication);
  }
}
