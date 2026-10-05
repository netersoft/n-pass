import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../enums/app_brightness.dart';
import '../../helpers/router/navigation_helper.dart';
import '../../routes/app_route.dart';
import '../../services/di/locator.dart';
import '../../services/i18n/translations.g.dart';
import '../../services/shared_preferences/keys.dart';
import '../../services/shared_preferences/service.dart';

part 'settings_provider.g.dart';

final _navigationHelper = locator<NavigationHelper>();

@Riverpod(keepAlive: true)
class Settings extends _$Settings {
  @override
  SettingsState build() => const SettingsState();

  final SharedPreferencesService prefs = locator<SharedPreferencesService>();

  String get _shareMessage {
    var ctx = _navigationHelper.navigatorKey.currentContext;
    if (ctx == null) return '';
    return t.installApp;
  }

  String get _sharePlayStoreUrl => 'https://play.google.com/store/apps/details?id=com.example.app';

  Future<void> share(ShareOptions options) async {
    try {
      switch (options) {
        case ShareOptions.whatsapp:
          unawaited(
            launchUrl(
              Uri.parse(
                "whatsapp:${Platform.isIOS ? '//wa.me/' : '//send?'}text=${Uri.encodeFull('$_shareMessage\n$_sharePlayStoreUrl')}",
              ),
            ),
          );
        case ShareOptions.email:
          Uri emailLaunchUri = Uri(
            scheme: 'mailto',
            queryParameters: {
              'subject': 'App',
              'body': '$_shareMessage\n$_sharePlayStoreUrl',
            },
          );
          unawaited(launchUrl(emailLaunchUri));
        case ShareOptions.sms:
          Uri smsLaunchUri = Uri(
            scheme: 'sms',
            queryParameters: {'body': '$_shareMessage\n$_sharePlayStoreUrl'},
          );
          unawaited(launchUrl(smsLaunchUri));
        case ShareOptions.free:
          var ctx = _navigationHelper.navigatorKey.currentContext;
          if (ctx != null) {
            final box = ctx.findRenderObject() as RenderBox?;
            await SharePlus.instance.share(
              ShareParams(
                text: '$_shareMessage\n$_sharePlayStoreUrl',
                subject: t.share,
                sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
              ),
            );
          }
      }
    } catch (e) {
      var ctx = _navigationHelper.navigatorKey.currentContext;
      if (ctx != null && ctx.mounted) {
        unawaited(EasyLoading.showError(t.anErrorOccurred));
      }
    }
  }

  void toggleEnableNotificationsState(bool newState) {
    prefs.setBool(PrefKeys.enableNotifications, newState);
  }

  bool? getEnableNotificationsState() => prefs.getBool(PrefKeys.enableNotifications, defaultValue: true);

  Future<void> changeLanguage(String newValue) async {
    final navigator = _navigationHelper.navigatorKey.currentState;
    await LocaleSettings.setLocaleRaw(newValue);

    try {
      _navigationHelper.go(const SettingsRoute().location);
      if (navigator != null && navigator.mounted) {
        Phoenix.rebirth(navigator.context);
      }
    } catch (e) {
      _navigationHelper.pushReplacement(const RedirectionRoute().location);
    }
  }

  String? getAppBrightness() => prefs.getString(
    PrefKeys.brightness,
    defaultValue: AppBrightness.system.name,
  );

  void setAppBrightness(String appBrightness, {bool relaunch = true}) {
    prefs.setString(PrefKeys.brightness, appBrightness);

    if (relaunch) {
      try {
        _navigationHelper.go(const SettingsRoute().location);
        var ctx = _navigationHelper.navigatorKey.currentContext;
        if (ctx != null) Phoenix.rebirth(ctx);
      } catch (e) {
        _navigationHelper.pushReplacement(const RedirectionRoute().location);
      }
    }
  }
}

class SettingsState {
  final bool isLoading;

  const SettingsState({this.isLoading = false});

  SettingsState copyWith({bool? isLoading}) => SettingsState(isLoading: isLoading ?? this.isLoading);
}

enum ShareOptions { whatsapp, email, free, sms }
