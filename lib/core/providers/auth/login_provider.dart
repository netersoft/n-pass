import 'dart:async';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/mutations/auth/login.dart';
import '../../data/queries/get_current_user.dart';
import '../../helpers/device/device_info_helper.dart';
import '../../services/api/service.dart';
import '../../services/hive/keys.dart';
import '../../services/i18n/translations.g.dart';

part 'login_provider.g.dart';

@riverpod
class Login extends _$Login {
  @override
  LoginState build() => const LoginState();

  void togglePasswordVisibility() {
    state = state.copyWith(passwordVisible: !state.passwordVisible);
  }

  Future<({bool success, String? ticket})> submit(
    Map<String, FormBuilderFieldState<FormBuilderField<dynamic>, dynamic>> fields,
  ) async {
    state = state.copyWith(isLoading: true);

    var response = await useLogin.mutate(
      LoginData(
        email: fields['email']!.value,
        password: fields['password']!.value,
        deviceName: await DeviceInfoHelper.getName(),
      ),
    );

    state = state.copyWith(isLoading: false);

    final result = response.data;

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
    } else if (result?.isRateLimited ?? false) {
      unawaited(EasyLoading.showError(t.tooManyAttemptsTryAgainLater));
    } else {
      unawaited(EasyLoading.showError(t.wrongEmailOrPassword));
    }

    return (success: false, ticket: null);
  }
}

Future<void> persistToken(String token) async {
  final authBox = Hive.box(HiveKeys.auth);

  await authBox.put(HiveKeys.authToken, token);

  final userState = await useCurrentUser().fetch();

  if (userState.data != null) {
    unawaited(authBox.put(HiveKeys.authUserData, userState.data));
  }
}

class LoginState {
  final bool isLoading;
  final bool passwordVisible;

  const LoginState({
    this.isLoading = false,
    this.passwordVisible = false,
  });

  LoginState copyWith({bool? isLoading, bool? passwordVisible}) => LoginState(
    isLoading: isLoading ?? this.isLoading,
    passwordVisible: passwordVisible ?? this.passwordVisible,
  );
}
