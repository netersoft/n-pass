import 'dart:async';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/mutations/auth/two_factor_challenge.dart';
import '../../helpers/device/device_info_helper.dart';
import '../../services/api/service.dart';
import '../../services/i18n/translations.g.dart';
import 'login_provider.dart';

part 'two_factor_challenge_provider.g.dart';

@riverpod
class TwoFactorChallenge extends _$TwoFactorChallenge {
  @override
  TwoFactorChallengeState build() => const TwoFactorChallengeState();

  void toggleUseRecoveryCode() {
    state = state.copyWith(useRecoveryCode: !state.useRecoveryCode);
  }

  Future<bool> submit(
    String ticket,
    Map<String, FormBuilderFieldState<FormBuilderField<dynamic>, dynamic>> fields,
  ) async {
    state = state.copyWith(isLoading: true);

    var response = await useTwoFactorChallenge.mutate(
      TwoFactorChallengeData(
        ticket: ticket,
        code: state.useRecoveryCode ? null : fields['code']?.value,
        recoveryCode: state.useRecoveryCode ? fields['recoveryCode']?.value : null,
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
    } else {
      unawaited(EasyLoading.showError(t.wrongVerificationCode));
    }

    return false;
  }
}

class TwoFactorChallengeState {
  final bool isLoading;
  final bool useRecoveryCode;

  const TwoFactorChallengeState({
    this.isLoading = false,
    this.useRecoveryCode = false,
  });

  TwoFactorChallengeState copyWith({bool? isLoading, bool? useRecoveryCode}) => TwoFactorChallengeState(
    isLoading: isLoading ?? this.isLoading,
    useRecoveryCode: useRecoveryCode ?? this.useRecoveryCode,
  );
}
