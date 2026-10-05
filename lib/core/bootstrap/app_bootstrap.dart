import 'package:cached_query_flutter/cached_query_flutter.dart';
import 'package:cached_storage/cached_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import '../data/observers/global_observer.dart';
import '../services/crash_reporting/service.dart';
import '../services/di/locator.dart';
import '../services/firebase/service.dart';
import '../services/i18n/translations.g.dart';
import '../services/push_notifications/service.dart';

class AppBootstrapConfig {
  final String envFileName;
  final bool preserveNativeSplash;
  final bool skipBindingInit;

  const AppBootstrapConfig({
    this.envFileName = '.env',
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

  await dotenv.load(fileName: config.envFileName);

  await FirebaseSetup.ensureInitialized();
  await CrashReportingService.init();
  await PushNotificationsService.init();

  await Hive.initFlutter();

  await setupLocator();

  await LocaleSettings.useDeviceLocale();

  CachedQuery.instance.configFlutter(
    storage: await CachedStorage.ensureInitialized(),
    observers: [
      const QueryLoggingObserver(),
      DevtoolsObserver(),
      GlobalObserver(),
    ],
  );
}
