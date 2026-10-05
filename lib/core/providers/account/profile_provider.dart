import 'dart:async';
import 'dart:io';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/mutations/account/delete_avatar.dart';
import '../../data/mutations/account/update_avatar.dart';
import '../../data/mutations/account/update_profile.dart';
import '../../data/mutations/auth/logout.dart';
import '../../data/mutations/auth/resend_email_verification.dart';
import '../../data/queries/get_current_user.dart';
import '../../helpers/router/navigation_helper.dart';
import '../../models/user_model.dart';
import '../../routes/app_route.dart';
import '../../services/api/response.dart';
import '../../services/api/service.dart';
import '../../services/di/locator.dart';
import '../../services/hive/keys.dart';
import '../../services/i18n/translations.g.dart';

part 'profile_provider.g.dart';

@riverpod
class Profile extends _$Profile {
  @override
  ProfileState build() {
    final authBox = Hive.box(HiveKeys.auth);
    final userData = authBox.get(HiveKeys.authUserData, defaultValue: null);

    return ProfileState(userData: userData);
  }

  Future<void> reload() async {
    final authBox = Hive.box(HiveKeys.auth);
    final userState = await useCurrentUser().fetch();

    if (userState.data != null) {
      unawaited(authBox.put(HiveKeys.authUserData, userState.data));
      state = state.copyWith(userData: userState.data);
    }
  }

  Future<bool> updateProfile({required String name, required String email}) async {
    state = state.copyWith(isUpdatingProfile: true);

    var response = await useUpdateProfile.mutate(UpdateProfileData(name: name, email: email));

    state = state.copyWith(isUpdatingProfile: false);

    return _applyUpdatedUser(response.data);
  }

  Future<bool> updateAvatar(File avatar) async {
    unawaited(EasyLoading.show());

    var response = await useUpdateAvatar.mutate(avatar);

    unawaited(EasyLoading.dismiss());

    return _applyUpdatedUser(response.data);
  }

  Future<bool> removeAvatar() async {
    unawaited(EasyLoading.show());

    var response = await useDeleteAvatar.mutate(null);

    unawaited(EasyLoading.dismiss());

    return _applyUpdatedUser(response.data);
  }

  Future<bool> _applyUpdatedUser(ApiResponse? result) async {
    if (result != null && result.isSuccess) {
      final authBox = Hive.box(HiveKeys.auth);
      final updatedUser = UserModel.fromJson(result.data);

      unawaited(authBox.put(HiveKeys.authUserData, updatedUser));
      state = state.copyWith(userData: updatedUser);

      return true;
    }

    if (result?.isValidationError ?? false) {
      ApiService.displayFormErrors(result?.errors ?? {});
    } else {
      unawaited(EasyLoading.showError(t.anErrorOccurred));
    }

    return false;
  }

  Future<void> resendVerificationEmail() async {
    unawaited(EasyLoading.show());

    var response = await useResendEmailVerification.mutate(null);

    unawaited(EasyLoading.dismiss());

    if (response.data?.isSuccess ?? false) {
      unawaited(EasyLoading.showSuccess(t.verificationEmailSent));
    } else {
      unawaited(EasyLoading.showError(t.anErrorOccurred));
    }
  }

  void _resetData() {
    Hive.box(HiveKeys.auth)
      ..delete(HiveKeys.authUserData)
      ..delete(HiveKeys.authToken);
  }

  final _navigationHelper = locator<NavigationHelper>();

  Future<void> logout() async {
    unawaited(EasyLoading.show());

    await useLogout.mutate(null);

    unawaited(EasyLoading.dismiss());

    _resetData();

    unawaited(EasyLoading.showSuccess(t.loggedOutWithSuccess));

    _navigationHelper.pushReplacement(const MainRoute().location);
  }
}

class ProfileState {
  final UserModel? userData;
  final bool isUpdatingProfile;

  const ProfileState({this.userData, this.isUpdatingProfile = false});

  ProfileState copyWith({UserModel? userData, bool? isUpdatingProfile}) => ProfileState(
    userData: userData ?? this.userData,
    isUpdatingProfile: isUpdatingProfile ?? this.isUpdatingProfile,
  );
}
