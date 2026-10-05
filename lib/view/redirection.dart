import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers/navigation/redirection_provider.dart';
import 'themes/app_colors.dart';
import 'themes/app_theme.dart';

/// First route: picks the intro, vault creation or unlock screen right away.
/// Shows the same background as the native splash, so the hand-off is
/// seamless.
class Redirection extends ConsumerStatefulWidget {
  const Redirection({super.key});

  @override
  RedirectionState createState() => RedirectionState();
}

class RedirectionState extends ConsumerState<Redirection> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FlutterNativeSplash.remove();
      ref.read(redirectionProvider.notifier).redirect(ref);
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(redirectionProvider);
    return ColoredBox(
      color: AppTheme.pickColor(light: AppTheme.primaryColor, dark: AppColors.raisinBlack),
      child: Center(child: Image.asset('assets/images/launcher/splash_logo.png', width: 360)),
    );
  }
}
