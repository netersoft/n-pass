import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../view/screens/error/error_screen.dart';
import '../helpers/router/navigation_helper.dart';
import '../services/di/locator.dart';
import '../services/vault/service.dart';
import 'app_navigator_observer.dart';
import 'app_route.dart';
import 'swipeable_page_route.dart';

final router = createRouter(
  navigatorKey: locator<NavigationHelper>().navigatorKey,
  vault: locator<VaultService>(),
);

GoRouter createRouter({
  required VaultService vault,
  GlobalKey<NavigatorState>? navigatorKey,
  String initialLocation = '/',
  List<NavigatorObserver>? observers,
}) => GoRouter(
  navigatorKey: navigatorKey,
  initialLocation: initialLocation,
  observers: observers ?? [AppNavigatorObserver()],
  refreshListenable: vault.unlockedListenable,
  redirect: (context, state) => vaultRedirect(
    state.matchedLocation,
    isCreated: vault.isCreated,
    isUnlocked: vault.isUnlocked,
  ),
  errorPageBuilder: (BuildContext context, GoRouterState state) => SwipeablePage(builder: (context) => ErrorScreen(state.error)),
  routes: $appRoutes,
);

/// Locations reachable while the vault is locked.
final _publicLocations = {
  const RedirectionRoute().location,
  const IntroRoute().location,
  const CreateVaultRoute().location,
  const UnlockRoute().location,
};

/// Keeps every vault screen behind the unlock screen. The create screen is
/// left alone once unlocked: it navigates by itself after offering biometrics.
String? vaultRedirect(String location, {required bool isCreated, required bool isUnlocked}) {
  if (!isUnlocked && !_publicLocations.contains(location)) {
    return isCreated ? const UnlockRoute().location : const CreateVaultRoute().location;
  }
  if (isUnlocked && location == const UnlockRoute().location) {
    return const MainRoute().location;
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
