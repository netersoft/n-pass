import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/mutations/auth/forgot_password.dart';

part 'forgot_password_provider.g.dart';

@riverpod
class ForgotPassword extends _$ForgotPassword {
  @override
  ForgotPasswordState build() => const ForgotPasswordState();

  Future<bool> submit(
    Map<String, FormBuilderFieldState<FormBuilderField<dynamic>, dynamic>> fields,
  ) async {
    state = state.copyWith(isLoading: true);

    var response = await useForgotPassword.mutate(fields['email']!.value);

    state = state.copyWith(isLoading: false);

    return response.data?.isSuccess ?? false;
  }
}

class ForgotPasswordState {
  final bool isLoading;

  const ForgotPasswordState({this.isLoading = false});

  ForgotPasswordState copyWith({bool? isLoading}) => ForgotPasswordState(isLoading: isLoading ?? this.isLoading);
}
