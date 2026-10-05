// Placeholder Firebase options -- this starter ships with no real Firebase
// project. Run `flutterfire configure` to replace this file with your own
// project's generated options; it overwrites this file in place.
//
// See the README's "New Project Checklist" for the full Crashlytics setup
// step. Until you do this, CrashReportingService detects the placeholder
// values below and skips initialization instead of sending data to a
// project that doesn't exist.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const placeholderApiKey = 'REPLACE_WITH_FLUTTERFIRE_CONFIGURE';

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: placeholderApiKey,
    appId: '1:000000000000:web:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'replace-with-your-project-id',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: placeholderApiKey,
    appId: '1:000000000000:android:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'replace-with-your-project-id',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: placeholderApiKey,
    appId: '1:000000000000:ios:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'replace-with-your-project-id',
    iosBundleId: 'com.example.flutterProjectTemplate',
  );
}
