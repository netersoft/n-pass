import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../view/redirection.dart';
import '../../view/screens/account/settings_screen.dart';
import '../../view/screens/main_screen.dart';
import '../../view/screens/onboarding/intro_screen.dart';
import 'swipeable_page_route.dart';

part 'app_route.g.dart';

class RedirectionExtra {
  final List<String> routes;
  final Map<String, dynamic> params;
  const RedirectionExtra({this.routes = const [], this.params = const {}});
}

@TypedGoRoute<RedirectionRoute>(path: '/')
class RedirectionRoute extends GoRouteData with $RedirectionRoute {
  const RedirectionRoute({this.$extra});

  final RedirectionExtra? $extra;

  @override
  Widget build(BuildContext context, GoRouterState state) => const Redirection();
}

@TypedGoRoute<IntroRoute>(path: '/intro')
class IntroRoute extends GoRouteData with $IntroRoute {
  const IntroRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const IntroScreen();
}

@TypedGoRoute<MainRoute>(
  path: '/main',
  routes: [
    TypedGoRoute<SettingsRoute>(path: 'settings'),
  ],
)
class MainRoute extends GoRouteData with $MainRoute {
  const MainRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const MainScreen();
}

class SettingsRoute extends GoRouteData with $SettingsRoute {
  const SettingsRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) => SwipeablePage<void>(builder: (context) => const SettingsScreen());
}
