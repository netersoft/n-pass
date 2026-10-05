import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../services/di/locator.dart';
import '../../services/vault/service.dart';
import '../../tools/functions/password_strength.dart';

part 'change_password_provider.g.dart';

@riverpod
class ChangePassword extends _$ChangePassword {
  @override
  ChangePasswordState build() => const ChangePasswordState();

  void setNewPassword(String password) => state = state.copyWith(strength: estimatePasswordStrength(password));

  void clearWrongPassword() {
    if (state.wrongCurrentPassword) state = state.copyWith(wrongCurrentPassword: false);
  }

  /// Returns true once the password is changed.
  Future<bool> submit(String currentPassword, String newPassword) async {
    state = state.copyWith(isSubmitting: true, wrongCurrentPassword: false);
    final ok = await locator<VaultService>().changePassword(currentPassword, newPassword);
    if (!ref.mounted) return ok;
    state = state.copyWith(isSubmitting: false, wrongCurrentPassword: !ok);
    return ok;
  }
}

class ChangePasswordState {
  final PasswordStrength strength;
  final bool wrongCurrentPassword;
  final bool isSubmitting;

  const ChangePasswordState({this.strength = PasswordStrength.veryWeak, this.wrongCurrentPassword = false, this.isSubmitting = false});

  bool get isStrongEnough => strength.index >= PasswordStrength.fair.index;

  ChangePasswordState copyWith({PasswordStrength? strength, bool? wrongCurrentPassword, bool? isSubmitting}) => ChangePasswordState(
    strength: strength ?? this.strength,
    wrongCurrentPassword: wrongCurrentPassword ?? this.wrongCurrentPassword,
    isSubmitting: isSubmitting ?? this.isSubmitting,
  );
}
