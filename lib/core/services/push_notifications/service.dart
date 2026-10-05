import 'package:firebase_messaging/firebase_messaging.dart';

import '../../helpers/logging/log_helper.dart';
import '../firebase/service.dart';

/// Runs a Firebase-initialized isolate for background/terminated-state FCM
/// messages. Must stay top-level (not a class member) and keep the
/// `vm:entry-point` pragma -- the Flutter engine looks this function up by
/// name in a separate isolate that never runs `main()`.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await FirebaseSetup.ensureInitialized();

  LogHelper.i('FCM background message received: ${message.messageId}');
}

/// Thin wrapper around FirebaseMessaging -- a no-op when firebase_options.dart
/// is still a placeholder, same gating as CrashReportingService/AnalyticsService.
///
/// This only wires the SDK (permission, handlers, token). Registering the
/// token with the backend is the caller's responsibility -- see
/// AppLifecycleLayer and the auth providers, which already send device info
/// to `/user-devices` and now include `fcmToken` from [getToken] there.
abstract class PushNotificationsService {
  static bool get isConfigured => FirebaseSetup.isConfigured;

  static Future<void> init() async {
    if (!isConfigured) {
      LogHelper.w(
        'PushNotificationsService: firebase_options.dart is still a placeholder -- '
        'run `flutterfire configure` to enable push notifications. Skipping init.',
      );
      return;
    }

    await FirebaseMessaging.instance.requestPermission();

    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(alert: true, badge: true, sound: true);

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Android shows no system banner for a foreground message on its own
    // (unlike iOS, which honours setForegroundNotificationPresentationOptions
    // above) -- add flutter_local_notifications here if a project needs a
    // heads-up banner while the app is open.
    FirebaseMessaging.onMessage.listen((message) {
      LogHelper.i('FCM foreground message received: ${message.messageId}');
    });

    // Fires when the user taps a notification and the app was already
    // running in the background. Route to the relevant screen here (e.g.
    // via NavigationHelper) once notification payloads carry a target route.
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      LogHelper.i('FCM notification opened app: ${message.messageId}');
    });

    // Same as onMessageOpenedApp, but for a cold start (app was terminated).
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      LogHelper.i('FCM notification launched app: ${initialMessage.messageId}');
    }
  }

  static Future<String?> getToken() async {
    if (!isConfigured) return null;

    return FirebaseMessaging.instance.getToken();
  }
}
