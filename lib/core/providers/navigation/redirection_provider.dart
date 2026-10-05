import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../enums/app_brightness.dart';
import '../../helpers/router/navigation_helper.dart';
import '../../routes/app_route.dart';
import '../../services/di/locator.dart';
import '../../services/i18n/locale_preference.dart';
import '../../services/i18n/translations.g.dart';
import '../../services/shared_preferences/keys.dart';
import '../../services/shared_preferences/service.dart';
import '../../services/vault/service.dart';

part 'redirection_provider.g.dart';

final _navigationHelper = locator<NavigationHelper>();

@riverpod
class Redirection extends _$Redirection {
  @override
  int build() => 0;

  Future redirect(WidgetRef ref) async {
    final SharedPreferencesService prefs = locator<SharedPreferencesService>();

    bool? firstOpening = prefs.getBool(
      PrefKeys.firstOpening,
      defaultValue: true,
    );

    if (firstOpening ?? false) {
      unawaited(prefs.setString(PrefKeys.brightness, AppBrightness.system.name));

      var ctx = _navigationHelper.navigatorKey.currentContext;
      if (ctx != null && !LocalePreference.hasSaved(prefs)) {
        final langCode = Localizations.localeOf(ctx).languageCode;
        await LocaleSettings.setLocaleRaw(langCode);
      }
      _navigationHelper.pushReplacement(const IntroRoute().location);
    } else if (!locator<VaultService>().isCreated) {
      _navigationHelper.pushReplacement(const CreateVaultRoute().location);
    } else {
      _navigationHelper.pushReplacement(const UnlockRoute().location);
    }
  }
}
