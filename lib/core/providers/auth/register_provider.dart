import 'dart:async';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/mutations/auth/register.dart';
import '../../helpers/device/device_info_helper.dart';
import '../../services/api/service.dart';
import '../../services/i18n/translations.g.dart';
import 'login_provider.dart';

part 'register_provider.g.dart';

@riverpod
class Register extends _$Register {
  @override
  RegisterState build() => const RegisterState();

  void togglePasswordVisibility() {
    state = state.copyWith(passwordVisible: !state.passwordVisible);
  }

  Future<bool> submit(
    Map<String, FormBuilderFieldState<FormBuilderField<dynamic>, dynamic>> fields,
  ) async {
    state = state.copyWith(isLoading: true);

    var response = await useRegister.mutate(
      RegisterData(
        name: fields['name']!.value,
        email: fields['email']!.value,
        password: fields['password']!.value,
        passwordConfirmation: fields['passwordConfirmation']!.value,
        deviceName: await DeviceInfoHelper.getName(),
      ),
    );

    state = state.copyWith(isLoading: false);

    final result = response.data;

    if (result != null && result.isSuccess) {
      await persistToken(result.data['token']);

      return true;
    }

    if (result?.isValidationError ?? false) {
      ApiService.displayFormErrors(result?.errors ?? {});
    } else if (result?.isRateLimited ?? false) {
      unawaited(EasyLoading.showError(t.tooManyAttemptsTryAgainLater));
    } else {
      unawaited(EasyLoading.showError(t.registrationNotSuccessful));
    }

    return false;
  }
}

class RegisterState {
  final bool isLoading;
  final bool passwordVisible;

  const RegisterState({
    this.isLoading = false,
    this.passwordVisible = false,
  });

  RegisterState copyWith({bool? isLoading, bool? passwordVisible}) => RegisterState(
    isLoading: isLoading ?? this.isLoading,
    passwordVisible: passwordVisible ?? this.passwordVisible,
  );
}
