import 'dart:async';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/mutations/auth/reset_password.dart';
import '../../services/api/service.dart';
import '../../services/i18n/translations.g.dart';

part 'reset_password_provider.g.dart';

@riverpod
class ResetPassword extends _$ResetPassword {
  @override
  ResetPasswordState build() => const ResetPasswordState();

  Future<bool> submit(
    Map<String, FormBuilderFieldState<FormBuilderField<dynamic>, dynamic>> fields,
  ) async {
    state = state.copyWith(isLoading: true);

    var response = await useResetPassword.mutate(
      ResetPasswordData(
        token: fields['token']!.value,
        email: fields['email']!.value,
        password: fields['password']!.value,
        passwordConfirmation: fields['passwordConfirmation']!.value,
      ),
    );

    state = state.copyWith(isLoading: false);

    final result = response.data;

    if (result != null && result.isSuccess) {
      return true;
    }

    if (result?.isValidationError ?? false) {
      ApiService.displayFormErrors(result?.errors ?? {});
    } else {
      unawaited(EasyLoading.showError(t.requestFailed));
    }

    return false;
  }
}

class ResetPasswordState {
  final bool isLoading;

  const ResetPasswordState({this.isLoading = false});

  ResetPasswordState copyWith({bool? isLoading}) => ResetPasswordState(isLoading: isLoading ?? this.isLoading);
}
