import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

import '../../../core/providers/auth/apple_auth_provider.dart';
import '../../../core/routes/app_route.dart';
import '../../../core/services/i18n/translations.g.dart';
import '../../themes/app_theme.dart';

class AppleAuth extends ConsumerWidget {
  const AppleAuth({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(appleAuthProvider);
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () async {
          var result = await ref.read(appleAuthProvider.notifier).appleSignIn();
          if (context.mounted && result.ticket != null) {
            unawaited(
              TwoFactorChallengeRoute(
                $extra: TwoFactorChallengeExtra(ticket: result.ticket!),
              ).push(context),
            );
          } else if (result.success && context.mounted) {
            const MainRoute().pushReplacement(context);
          }
        },
        icon: SvgPicture.asset(
          AppTheme.pickByTheme(
            light: 'assets/images/apple.svg',
            dark: 'assets/images/apple-grey.svg',
          ),
          width: 21,
        ),
        label: Text(context.t.continueWithApple),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0.3,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
