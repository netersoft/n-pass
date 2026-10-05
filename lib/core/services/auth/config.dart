import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class AuthConfig {
  static String googleAuthIosClientId = dotenv.get(
    'APP_GOOGLE_AUTH_IOS_CLIENT_ID',
    fallback: '',
  );
  static String googleAuthIosClientIdReverse = dotenv.get(
    'APP_GOOGLE_AUTH_IOS_CLIENT_ID_REVERSE',
    fallback: '',
  );

  static String googleAuthWebClientId = dotenv.get(
    'APP_GOOGLE_AUTH_WEB_CLIENT_ID',
    fallback: '',
  );

  static String googleAuthAndroidDebugClientId = dotenv.get(
    'APP_GOOGLE_AUTH_ANDROID_DEBUG_CLIENT_ID',
    fallback: '',
  );
  static String googleAuthAndroidReleaseClientId = dotenv.get(
    'APP_GOOGLE_AUTH_ANDROID_RELEASE_CLIENT_ID',
    fallback: '',
  );

  static String appleAuthClientId = dotenv.get(
    'APP_APPLE_AUTH_CLIENT_ID',
    fallback: '',
  );

  static String appleAuthRedirectUri = dotenv.get(
    'APP_APPLE_AUTH_REDIRECT_URI',
    fallback: '',
  );
}
