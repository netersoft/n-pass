import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/mutations/auth/social.dart';
import '../../helpers/device/device_info_helper.dart';
import '../../services/api/service.dart';
import '../../services/auth/config.dart';
import '../../services/i18n/translations.g.dart';
import 'login_provider.dart';

part 'google_auth_provider.g.dart';

@riverpod
class GoogleAuth extends _$GoogleAuth {
  @override
  GoogleAuthState build() => const GoogleAuthState();

  final GoogleSignIn _google = GoogleSignIn.instance;
  bool _initialized = false;

  Future<void> initializeIfNeeded() async {
    if (!_initialized) {
      await _google.initialize(
        clientId: Platform.isAndroid
            ? (kDebugMode ? AuthConfig.googleAuthAndroidDebugClientId : AuthConfig.googleAuthAndroidReleaseClientId)
            : AuthConfig.googleAuthIosClientId,
        serverClientId: AuthConfig.googleAuthWebClientId,
      );
      _initialized = true;
    }
  }

  Future<({bool success, String? ticket})> googleSignIn() async {
    unawaited(EasyLoading.show());

    await initializeIfNeeded();

    try {
      final GoogleSignInAccount account = await _google.authenticate(
        scopeHint: <String>['email'],
      );

      var googleAuth = account.authentication;

      if (googleAuth.idToken != null) {
        var response = await useSocialAuth.mutate(
          SocialAuthMutationParams(
            SocialAuthProvider.google,
            SocialAuthData(
              token: googleAuth.idToken,
              deviceName: await DeviceInfoHelper.getName(),
            ),
          ),
        );

        final result = response.data;

        unawaited(EasyLoading.dismiss());

        if (result != null && result.isSuccess) {
          final Map<String, dynamic> data = result.data;

          if (data['two_factor'] == true) {
            return (success: false, ticket: data['ticket'] as String?);
          }

          await persistToken(data['token']);

          return (success: true, ticket: null);
        }

        if (result?.isValidationError ?? false) {
          ApiService.displayFormErrors(result?.errors ?? {});
        } else {
          unawaited(EasyLoading.showError(t.unableToLogin));
        }
      } else {
        unawaited(EasyLoading.dismiss());
      }
    } catch (e) {
      unawaited(EasyLoading.dismiss());
    }

    return (success: false, ticket: null);
  }
}

class GoogleAuthState {
  final bool isLoading;

  const GoogleAuthState({this.isLoading = false});

  GoogleAuthState copyWith({bool? isLoading}) => GoogleAuthState(isLoading: isLoading ?? this.isLoading);
}
