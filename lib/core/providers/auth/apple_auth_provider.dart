import 'dart:async';
import 'dart:io';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../data/mutations/auth/social.dart';
import '../../helpers/device/device_info_helper.dart';
import '../../services/api/service.dart';
import '../../services/auth/config.dart';
import '../../services/i18n/translations.g.dart';
import '../../tools/functions/crypto_functions.dart';
import 'login_provider.dart';

part 'apple_auth_provider.g.dart';

@riverpod
class AppleAuth extends _$AppleAuth {
  @override
  AppleAuthState build() => const AppleAuthState();

  Future<({bool success, String? ticket})> appleSignIn() async {
    final rawNonce = generateNonce();
    final nonce = await sha256ofString(rawNonce);

    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: Platform.isIOS ? nonce : null,
      webAuthenticationOptions: Platform.isIOS
          ? null
          : WebAuthenticationOptions(
              clientId: AuthConfig.appleAuthClientId,
              redirectUri: Uri.parse(AuthConfig.appleAuthRedirectUri),
            ),
    );

    unawaited(EasyLoading.show());

    if (credential.identityToken != null) {
      var response = await useSocialAuth.mutate(
        SocialAuthMutationParams(
          SocialAuthProvider.apple,
          SocialAuthData(
            token: credential.identityToken,
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

    return (success: false, ticket: null);
  }
}

class AppleAuthState {
  final bool isLoading;

  const AppleAuthState({this.isLoading = false});

  AppleAuthState copyWith({bool? isLoading}) => AppleAuthState(isLoading: isLoading ?? this.isLoading);
}
