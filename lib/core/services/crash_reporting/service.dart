import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

import '../../helpers/logging/log_helper.dart';
import '../firebase/service.dart';

abstract class CrashReportingService {
  static bool get isConfigured => FirebaseSetup.isConfigured;

  /// Wires uncaught-error reporting to Crashlytics. Assumes
  /// FirebaseSetup.ensureInitialized() already ran during bootstrap; a
  /// no-op when firebase_options.dart is still a placeholder.
  static Future<void> init() async {
    if (!isConfigured) {
      LogHelper.w(
        'CrashReportingService: firebase_options.dart is still a placeholder -- '
        'run `flutterfire configure` to enable Crashlytics. Skipping init.',
      );
      return;
    }

    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }
}
