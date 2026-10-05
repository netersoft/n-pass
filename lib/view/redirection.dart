import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';

import '../core/providers/navigation/redirection_provider.dart';
import 'themes/app_colors.dart';
import 'themes/app_theme.dart';

/// Redirection screen
class Redirection extends ConsumerStatefulWidget {
  const Redirection({super.key});

  @override
  RedirectionState createState() => RedirectionState();
}

class RedirectionState extends ConsumerState<Redirection> {
  @override
  void initState() {
    super.initState();

    FlutterNativeSplash.remove();
  }

  /// Builds a FlutterSplashScreen widget with a centered Lottie animation.
  ///
  /// The splash screen has a blue background color and a duration of 2000 milliseconds.
  /// When the splash screen ends, it calls the [redirect] method of the [redirectionProvider]
  /// with the current [BuildContext].
  ///
  /// Returns a [Widget] representing the splash screen.
  /// But if you don't use animation, just return a [Container] widget like this:
  /// Container(color: isLightTheme() ? Colors.white : AppColors.raisinBlack);
  @override
  Widget build(BuildContext context) {
    ref.watch(redirectionProvider);

    return FlutterSplashScreen(
      useImmersiveMode: true,
      duration: const Duration(milliseconds: 2000),
      backgroundColor: AppTheme.pickColor(
        light: AppTheme.primaryColor,
        dark: AppColors.raisinBlack,
      ),
      splashScreenBody: Center(
        child: Lottie.asset(
          'assets/animations/logo.json',
          repeat: false,
          height: 200,
          width: 200,
        ),
      ),
      onInit: () {},
      onEnd: () {
        ref.read(redirectionProvider.notifier).redirect(ref);
      },
    );
  }
}
