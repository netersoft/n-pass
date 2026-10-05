import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../view/screens/error/error_screen.dart';
import '../helpers/router/navigation_helper.dart';
import '../services/di/locator.dart';
import 'app_navigator_observer.dart';
import 'app_route.dart';
import 'swipeable_page_route.dart';

final router = createRouter(
  navigatorKey: locator<NavigationHelper>().navigatorKey,
);

GoRouter createRouter({
  GlobalKey<NavigatorState>? navigatorKey,
  String initialLocation = '/',
  List<NavigatorObserver>? observers,
}) => GoRouter(
  navigatorKey: navigatorKey,
  initialLocation: initialLocation,
  observers: observers ?? [AppNavigatorObserver()],
  errorPageBuilder: (BuildContext context, GoRouterState state) => SwipeablePage(builder: (context) => ErrorScreen(state.error)),
  routes: $appRoutes,
);

extension GoRouterLocation on GoRouter {
  String get location {
    final RouteMatch lastMatch = routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch ? lastMatch.matches : routerDelegate.currentConfiguration;
    return matchList.uri.toString();
  }
}
