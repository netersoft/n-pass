import 'dart:async';

import 'package:hive_ce_flutter/hive_flutter.dart';

import '../../data/queries/get_current_user.dart';
import '../../models/user_model.dart';
import '../../services/hive/keys.dart';

abstract class AuthHelper {
  static final authBox = Hive.box(HiveKeys.auth);

  static String? getToken() => authBox.get(HiveKeys.authToken, defaultValue: null);

  static UserModel? getUserData() => authBox.get(HiveKeys.authUserData, defaultValue: null);

  static bool isUserLogged() => getToken() != null && getUserData() != null;

  static bool isUserNotLogged() => !isUserLogged();

  static Future<void> reloadUserData() async {
    if (getToken() == null) return;

    var userState = await useCurrentUser().fetch();

    if (userState.data != null) {
      unawaited(authBox.put(HiveKeys.authUserData, userState.data));
    }
  }
}
