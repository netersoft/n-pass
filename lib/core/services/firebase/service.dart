import 'package:firebase_core/firebase_core.dart';

import '../../../firebase_options.dart';

/// Shared Firebase bootstrap used by every Firebase-backed service
/// (CrashReportingService, AnalyticsService, ...). This starter ships with
/// placeholder options in firebase_options.dart (no real Firebase project),
/// so every consumer must check [isConfigured] before touching Firebase APIs
/// -- see the README's New Project Checklist for the `flutterfire configure`
/// step that replaces the placeholder.
abstract class FirebaseSetup {
  static bool get isConfigured => DefaultFirebaseOptions.currentPlatform.apiKey != DefaultFirebaseOptions.placeholderApiKey;

  static Future<void> ensureInitialized() async {
    if (!isConfigured || Firebase.apps.isNotEmpty) return;

    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  }
}
