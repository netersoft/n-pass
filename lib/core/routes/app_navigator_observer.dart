import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import '../services/hive/keys.dart';

class AppNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    Hive.box(
      HiveKeys.helper,
    ).put(HiveKeys.helperCurrentRoutePath, route.settings.name);
    Hive.box(
      HiveKeys.helper,
    ).put(HiveKeys.helperPreviousRoutePath, previousRoute?.settings.name);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    Hive.box(
      HiveKeys.helper,
    ).put(HiveKeys.helperCurrentRoutePath, route.settings.name);
    Hive.box(
      HiveKeys.helper,
    ).put(HiveKeys.helperPreviousRoutePath, previousRoute?.settings.name);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {}

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {}
}
