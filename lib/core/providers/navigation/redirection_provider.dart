import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../enums/app_brightness.dart';
import '../../helpers/account/auth_helper.dart';
import '../../helpers/router/navigation_helper.dart';
import '../../routes/app_route.dart';
import '../../services/di/locator.dart';
import '../../services/i18n/translations.g.dart';
import '../../services/shared_preferences/keys.dart';
import '../../services/shared_preferences/service.dart';

part 'redirection_provider.g.dart';

final _navigationHelper = locator<NavigationHelper>();

@riverpod
class Redirection extends _$Redirection {
  @override
  int build() => 0;

  Future redirect(WidgetRef ref) async {
    final SharedPreferencesService prefs = locator<SharedPreferencesService>();

    unawaited(AuthHelper.reloadUserData());

    bool? firstOpening = prefs.getBool(
      PrefKeys.firstOpening,
      defaultValue: true,
    );

    if (firstOpening ?? false) {
      unawaited(prefs.setString(PrefKeys.brightness, AppBrightness.system.name));

      var ctx = _navigationHelper.navigatorKey.currentContext;
      if (ctx != null) {
        final langCode = Localizations.localeOf(ctx).languageCode;
        await LocaleSettings.setLocaleRaw(langCode);
      }
      _navigationHelper.pushReplacement(const IntroRoute().location);
    } else {
      _navigationHelper.pushReplacement(const MainRoute().location);
    }
  }
}
