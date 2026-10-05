import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../view/screens/error/error_screen.dart';
import '../helpers/account/auth_helper.dart';
import '../helpers/router/navigation_helper.dart';
import '../services/di/locator.dart';
import '../services/firebase/service.dart';
import 'app_navigator_observer.dart';
import 'app_route.dart';
import 'swipeable_page_route.dart';

typedef AuthStateReader = bool Function();

final router = createRouter(
  navigatorKey: locator<NavigationHelper>().navigatorKey,
);

GoRouter createRouter({
  GlobalKey<NavigatorState>? navigatorKey,
  String initialLocation = '/',
  List<NavigatorObserver>? observers,
  AuthStateReader? isUserLogged,
}) => GoRouter(
  navigatorKey: navigatorKey,
  initialLocation: initialLocation,
  observers:
      observers ??
      [
        AppNavigatorObserver(),
        if (FirebaseSetup.isConfigured) FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
      ],
  redirect: (BuildContext context, GoRouterState state) => appRouteRedirect(
    state,
    isUserLogged: isUserLogged,
  ),
  errorPageBuilder: (BuildContext context, GoRouterState state) => SwipeablePage(builder: (context) => ErrorScreen(state.error)),
  routes: $appRoutes,
);

String? appRouteRedirect(
  GoRouterState state, {
  AuthStateReader? isUserLogged,
}) {
  final logged = isUserLogged?.call() ?? AuthHelper.isUserLogged();

  final authPaths = [const ProfileRoute().location];

  if (!logged && authPaths.contains(state.matchedLocation)) {
    return const ProvidersRoute().location;
  }

  return null;
}

extension GoRouterLocation on GoRouter {
  String get location {
    final RouteMatch lastMatch = routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch ? lastMatch.matches : routerDelegate.currentConfiguration;
    return matchList.uri.toString();
  }
}
