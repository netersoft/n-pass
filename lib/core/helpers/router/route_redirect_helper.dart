import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../routes/app_route.dart';

class RouteRedirectHelper {
  final BuildContext? _context;

  RouteRedirectHelper(this._context);

  static RouteRedirectHelper instance(BuildContext? context) => RouteRedirectHelper(context);

  bool listenForRedirectRequest() {
    final RedirectionExtra? arguments = ModalRoute.of(_context!)!.settings.arguments as RedirectionExtra?;
    bool hasRequests = false;

    if (arguments != null && arguments.routes.isNotEmpty) {
      for (final route in arguments.routes) {
        hasRequests = true;
        _context.push(route, extra: arguments.params);
      }
    }

    return hasRequests;
  }

  void redirectTo({List<String>? routes, Map<String, dynamic>? params}) {
    _context?.pushReplacement(
      const RedirectionRoute().location,
      extra: RedirectionExtra(routes: routes ?? [], params: params ?? {}),
    );
  }
}
