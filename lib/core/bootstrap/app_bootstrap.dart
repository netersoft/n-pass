import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import '../services/di/locator.dart';
import '../services/i18n/translations.g.dart';

class AppBootstrapConfig {
  final bool preserveNativeSplash;
  final bool skipBindingInit;

  const AppBootstrapConfig({
    this.preserveNativeSplash = true,
    this.skipBindingInit = false,
  });
}

Future<void> bootstrapApp({
  AppBootstrapConfig config = const AppBootstrapConfig(),
}) async {
  final WidgetsBinding widgetsBinding = config.skipBindingInit ? WidgetsBinding.instance : WidgetsFlutterBinding.ensureInitialized();

  if (config.preserveNativeSplash) {
    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  }

  GoRouter.optionURLReflectsImperativeAPIs = true;

  await Hive.initFlutter();

  await setupLocator();

  await LocaleSettings.useDeviceLocale();

  LicenseRegistry.addLicense(_bundledContentLicenses);
}

/// Content shipped with the app that is not a Dart package, so it shows in
/// the open source licenses page.
Stream<LicenseEntry> _bundledContentLicenses() async* {
  yield const LicenseEntryWithLineBreaks(
    ['EFF large wordlist'],
    '''
EFF's Long Wordlist for passphrases (https://www.eff.org/dice), by the Electronic Frontier Foundation.
Used with the dice numbers removed.

Licensed under the Creative Commons Attribution 3.0 United States License (CC BY 3.0 US): https://creativecommons.org/licenses/by/3.0/us/''',
  );
}
