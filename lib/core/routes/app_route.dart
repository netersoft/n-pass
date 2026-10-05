import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../view/redirection.dart';
import '../../view/screens/account/edit_profile_screen.dart';
import '../../view/screens/account/profile_screen.dart';
import '../../view/screens/account/settings_screen.dart';
import '../../view/screens/auth/forgot_password_screen.dart';
import '../../view/screens/auth/login_screen.dart';
import '../../view/screens/auth/providers_screen.dart';
import '../../view/screens/auth/register_screen.dart';
import '../../view/screens/auth/reset_password_screen.dart';
import '../../view/screens/auth/two_factor_challenge_screen.dart';
import '../../view/screens/main/home_screen.dart';
import '../../view/screens/main_screen.dart';
import '../../view/screens/onboarding/intro_screen.dart';
import 'swipeable_page_route.dart';

part 'app_route.g.dart';

class RedirectionExtra {
  final List<String> routes;
  final Map<String, dynamic> params;
  const RedirectionExtra({this.routes = const [], this.params = const {}});
}

class AuthExtra {
  final bool displayBackButton;
  final bool displayPageFooter;
  const AuthExtra({this.displayBackButton = true, this.displayPageFooter = false});
}

class TwoFactorChallengeExtra {
  final String ticket;
  const TwoFactorChallengeExtra({required this.ticket});
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
    TypedGoRoute<HomeRoute>(path: 'home'),
    TypedGoRoute<SettingsRoute>(path: 'other/settings'),
    TypedGoRoute<ProfileRoute>(path: 'other/profile'),
    TypedGoRoute<EditProfileRoute>(path: 'other/profile/edit'),
    TypedGoRoute<ProvidersRoute>(path: 'auth/providers'),
    TypedGoRoute<LoginRoute>(path: 'auth/login'),
    TypedGoRoute<RegisterRoute>(path: 'auth/register'),
    TypedGoRoute<ForgotPasswordRoute>(path: 'auth/forgot-password'),
    TypedGoRoute<ResetPasswordRoute>(path: 'auth/reset-password'),
    TypedGoRoute<TwoFactorChallengeRoute>(path: 'auth/two-factor-challenge'),
  ],
)
class MainRoute extends GoRouteData with $MainRoute {
  const MainRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const MainScreen();
}

class HomeRoute extends GoRouteData with $HomeRoute {
  const HomeRoute();

  @override
  CustomTransitionPage<void> buildPage(BuildContext context, GoRouterState state) => CustomTransitionPage<void>(
    key: state.pageKey,
    child: const HomeScreen(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation, child: child),
  );
}

class SettingsRoute extends GoRouteData with $SettingsRoute {
  const SettingsRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) => SwipeablePage<void>(builder: (context) => const SettingsScreen());
}

class ProfileRoute extends GoRouteData with $ProfileRoute {
  const ProfileRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) => SwipeablePage<void>(builder: (context) => const ProfileScreen());
}

class EditProfileRoute extends GoRouteData with $EditProfileRoute {
  const EditProfileRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) => SwipeablePage<void>(builder: (context) => const EditProfileScreen());
}

class ProvidersRoute extends GoRouteData with $ProvidersRoute {
  const ProvidersRoute({this.$extra});

  final AuthExtra? $extra;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) => SwipeablePage<void>(
    builder: (context) => ProvidersScreen(extra: $extra),
  );
}

class LoginRoute extends GoRouteData with $LoginRoute {
  const LoginRoute({this.$extra});

  final AuthExtra? $extra;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) => SwipeablePage<void>(
    builder: (context) => LoginScreen(extra: $extra),
  );
}

class RegisterRoute extends GoRouteData with $RegisterRoute {
  const RegisterRoute({this.$extra});

  final AuthExtra? $extra;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) => SwipeablePage<void>(
    builder: (context) => RegisterScreen(extra: $extra),
  );
}

class ForgotPasswordRoute extends GoRouteData with $ForgotPasswordRoute {
  const ForgotPasswordRoute({this.$extra});

  final AuthExtra? $extra;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) => SwipeablePage<void>(
    builder: (context) => ForgotPasswordScreen(extra: $extra),
  );
}

class ResetPasswordRoute extends GoRouteData with $ResetPasswordRoute {
  const ResetPasswordRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) => SwipeablePage<void>(
    builder: (context) => const ResetPasswordScreen(),
  );
}

class TwoFactorChallengeRoute extends GoRouteData with $TwoFactorChallengeRoute {
  const TwoFactorChallengeRoute({required this.$extra});

  final TwoFactorChallengeExtra $extra;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) => SwipeablePage<void>(
    builder: (context) => TwoFactorChallengeScreen(extra: $extra),
  );
}
