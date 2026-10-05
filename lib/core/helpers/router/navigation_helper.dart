import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NavigationHelper {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  GoRouter? get _router {
    final ctx = navigatorKey.currentContext;
    if (ctx == null) return null;
    return GoRouter.of(ctx);
  }

  void go(String routeName, {dynamic arguments}) => _router?.go(routeName, extra: arguments);

  Future<Object?>? push(String routeName, {dynamic arguments}) => _router?.push(routeName, extra: arguments);

  void pushReplacement(String routeName, {dynamic arguments}) => _router?.pushReplacement(
    routeName,
    extra: arguments,
  );

  void goBack([Object? result]) => _router?.pop(result);

  static dynamic getExtraValue(
    BuildContext context,
    String key, {
    dynamic defaultValue,
  }) {
    final extra = GoRouterState.of(context).extra;
    if (extra is! Map) return defaultValue;

    return extra[key] ?? defaultValue;
  }
}
