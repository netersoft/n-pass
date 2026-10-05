import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../view/redirection.dart';
import '../../view/screens/about/about_screen.dart';
import '../../view/screens/about/privacy_policy_screen.dart';
import '../../view/screens/account/backup_screen.dart';
import '../../view/screens/account/change_password_screen.dart';
import '../../view/screens/account/settings_screen.dart';
import '../../view/screens/entries/entry_detail_screen.dart';
import '../../view/screens/entries/entry_form_screen.dart';
import '../../view/screens/main_screen.dart';
import '../../view/screens/onboarding/intro_screen.dart';
import '../../view/screens/vault/create_vault_screen.dart';
import '../../view/screens/vault/unlock_screen.dart';
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

@TypedGoRoute<CreateVaultRoute>(path: '/create')
class CreateVaultRoute extends GoRouteData with $CreateVaultRoute {
  const CreateVaultRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const CreateVaultScreen();
}

@TypedGoRoute<UnlockRoute>(path: '/unlock')
class UnlockRoute extends GoRouteData with $UnlockRoute {
  const UnlockRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) => CustomTransitionPage<void>(
    key: state.pageKey,
    child: const UnlockScreen(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation, child: child),
  );
}

@TypedGoRoute<MainRoute>(
  path: '/main',
  routes: [
    TypedGoRoute<SettingsRoute>(
      path: 'settings',
      routes: [
        TypedGoRoute<ChangePasswordRoute>(path: 'password'),
        TypedGoRoute<BackupRoute>(path: 'backup'),
        TypedGoRoute<AboutRoute>(path: 'about'),
        TypedGoRoute<PrivacyPolicyRoute>(path: 'privacy'),
      ],
    ),
    TypedGoRoute<NewEntryRoute>(path: 'entries/new'),
    TypedGoRoute<EntryRoute>(
      path: 'entries/:id',
      routes: [TypedGoRoute<EditEntryRoute>(path: 'edit')],
    ),
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

class ChangePasswordRoute extends GoRouteData with $ChangePasswordRoute {
  const ChangePasswordRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) => SwipeablePage<void>(builder: (context) => const ChangePasswordScreen());
}

class BackupRoute extends GoRouteData with $BackupRoute {
  const BackupRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) => SwipeablePage<void>(builder: (context) => const BackupScreen());
}

class AboutRoute extends GoRouteData with $AboutRoute {
  const AboutRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) => SwipeablePage<void>(builder: (context) => const AboutScreen());
}

class PrivacyPolicyRoute extends GoRouteData with $PrivacyPolicyRoute {
  const PrivacyPolicyRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) => SwipeablePage<void>(builder: (context) => const PrivacyPolicyScreen());
}

class NewEntryRoute extends GoRouteData with $NewEntryRoute {
  const NewEntryRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) => SwipeablePage<void>(builder: (context) => const EntryFormScreen());
}

class EntryRoute extends GoRouteData with $EntryRoute {
  const EntryRoute({required this.id});

  final String id;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) => SwipeablePage<void>(builder: (context) => EntryDetailScreen(id: id));
}

class EditEntryRoute extends GoRouteData with $EditEntryRoute {
  const EditEntryRoute({required this.id});

  final String id;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) => SwipeablePage<void>(builder: (context) => EntryFormScreen(entryId: id));
}
